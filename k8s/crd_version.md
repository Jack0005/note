# Versions in CustomResourceDefinitions

# 调大kubelet日志级别

curl -k  -X PUT   -H  'Authorization: Bearer kubeletpassword'  https://localhost:10250/debug/flags/v -d "1"

# 解决的问题

* 如何在 [CustomResourceDefinitions](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#customresourcedefinition-v1beta1-apiextensions)中添加版本
* 如何标识CustomResourceDefinitions的稳定性
* 如何通过API含义之间的转换，将API升级到一个新版本
* 如何从一个版本升级到另一个版本

# 开始之前

# 概览

CustomResourceDefinition API提供了晚上的工作机制，用于引入和升级CustomResourceDefinition到新的版本。

## 使用

* CustomResourceDefinition的字段`spec.versions`指定版本

## 添加新版本须知

* 指定版本转换策略
* 如果使用webhooks进行转换，创建和部署用于版本转换的[Webhook conversion](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/#webhook-conversion)
* 在CustomResourceDefinition中更新带有`served:true`属性的  `.spec.versions`列表添加一个新版本。设置`spec.conversion`字段，指定转换策略。如果使用webhooks进行转换，在`spec.conversion.webhookClientConfig`中配置webhook

## 迁移已经存在的对象到新版本

* [upgrade existing objects to a new stored version](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/#upgrade-existing-objects-to-a-new-stored-version) 

## 移除旧版本

* 确保所有的client都迁移到了新版本： kube-apiserver的日志能够看到那些clients依然使用旧版本
* 在`spec.versions`的旧版本中指定`served:false`。如果依然有用户使用旧版本，会报尝试访问旧版本资源的错误，可以通过修改`served:true`进行恢复，然后继续整改使用旧版本资源的clients
* 确保版本转换已经完成，[upgrade of existing objects to the new stored version](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/#upgrade-existing-objects-to-a-new-stored-version) 
  * 确认CustomResourceDefinition的`spec.versions`中新版本设置为`stored:true`
  * 确认CustomResourceDefinition中的`status.storedVersions`中不再列出旧版本
* 从CustomResourceDefinition的`spec.versions`移除旧版本
* 下掉版本转换webhooks中对旧版本的版本转换

# 指定多个版本

* CustomResourceDefinition的`versions `支持自定义资源的多个版本。

* 不同的版本有不同的schemas，并且有conversion webhooks在版本之间进行转换。

* Webhook conversions 遵循[Kubernetes API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)。

* 其他，请参照 [API change documentation](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api_changes.md) 

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
  - name: v1beta1
    # Each version can be enabled/disabled by Served flag.
    served: true
    # One and only one version must be marked as the storage version.
    storage: true
    # A schema is required
    schema:
      openAPIV3Schema:
        type: object
        properties:
          host:
            type: string
          port:
            type: string
  - name: v1
    served: true
    storage: false
    schema:
      openAPIV3Schema:
        type: object
        properties:
          host:
            type: string
          port:
            type: string
  # The conversion section is introduced in Kubernetes 1.13+ with a default value of
  # None conversion (strategy sub-field set to None).
  conversion:
    # None conversion assumes the same schema for all versions and only sets the apiVersion
    # field of custom resources to the proper value
    strategy: None
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
```

创建资源后，可通过http接口访问资源，`/apis/example.com/v1beta1` and `/apis/example.com/v1`

### 版本优先级

忽略CustomResourceDefinition内的版本定义顺序，高优先级版本的资源会被kubectl优先使用。

优先级通过版本的`name`字段决定：

* 版本号
* 稳定性(GA, Beta, or Alpha)
* 稳定性内部的顺序

版本优先级排序的算法和k8s项目的版本排序算法相同。

版本命名示例如下：

```shell
v+{数字，必选}+{稳定性（ga\beta\alpha），可选}+{数字，可选}
```

排序算法

* 入口遵循k8s 版本算法
* 数字部分从大到下，优先级以此降低
* 如果第一个数字后面有beta、alpha，按照数字进行排序；如果相同的数字后没有beta、alpha，则默认是GA阶段
* 不符合上述格式的字符串将按字母顺序排序，数字部分不会得到特殊处理。数字部分排序不遵循k8s版本排序。

排序示例：

```yaml
- v10
- v2
- v1
- v11beta2
- v10beta3
- v3beta1
- v12alpha1
- v11alpha2
- foo1
- foo10
```



## Webhook conversion

* FEATURE STATE:** `Kubernetes v1.16 [stable]`
* beta since 1.15
* alpha since 1.13
* CustomResourceWebhookConversion 特性必须被打开，对于多数集群的beta特性，是默认打开的

conversion设置为none的crd，修改对象时，仅修改对应version的对象，不改变其他版本的。

 API server支持webhook conversions，进行版本之间的转换。

版本转换的场景：

* 自定义资源被请求的版本，不同于存储的版本
* 监听资源的版本不同存储版本
* 自定义资源PUT请求版本不同于存储版本

### Write a conversion webhook server

实现可参考[custom resource conversion webhook server](https://github.com/kubernetes/kubernetes/tree/v1.15.0/test/images/crd-conversion-webhook/main.go)

webhook处理api servers发送的ConversionReview请求，通过ConversionResponse返回转换后的结果。请求中包含一组自定义资源，转换过程不包含资源对象的顺序。

示例server端的实现代码是可被其他版本资源重用的。多数相同的代码在[framework file](https://github.com/kubernetes/kubernetes/tree/v1.15.0/test/images/crd-conversion-webhook/converter/framework.go) 中，只有一个不同版本之间的转换函数[one function](https://github.com/kubernetes/kubernetes/blob/v1.15.0/test/images/crd-conversion-webhook/converter/example_converter.go#L29-L80)需要实现。

另外，示例server中没有添加clientAuth认证，如果需要参考 [authenticate API servers](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#authenticate-apiservers)

#### Permissible mutations

 conversion webhook不能转换metadata中除了labels和annotations之外的属性。尝试改变 `name`, `UID` `namespace` 将将被拒绝并返回失败，其他的改变也将被忽略。

### Deploy the conversion webhook service[ ](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/#deploy-the-conversion-webhook-service)

 conversion webhook 的部署方式和 [admission webhook example service](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/#deploy_the_admission_webhook_service)相同。

以下内容假设已经在default namespace中部署了一个名为example-conversion-webhook-server的service，通过路径/crdconvert接收流量。

### Configure CustomResourceDefinition to use conversion webhooks

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
  - name: v1beta1
    # Each version can be enabled/disabled by Served flag.
    served: true
    # One and only one version must be marked as the storage version.
    storage: true
    # Each version can define it's own schema when there is no top-level
    # schema is defined.
    schema:
      openAPIV3Schema:
        type: object
        properties:
          hostPort:
            type: string
  - name: v1
    served: true
    storage: false
    schema:
      openAPIV3Schema:
        type: object
        properties:
          host:
            type: string
          port:
            type: string
  conversion:
    # a Webhook strategy instruct API server to call an external webhook for any conversion between custom resources.
    strategy: Webhook
    # webhook is required when strategy is `Webhook` and it configures the webhook endpoint to be called by API server.
    webhook:
      # conversionReviewVersions indicates what ConversionReview versions are understood/preferred by the webhook.
      # The first version in the list understood by the API server is sent to the webhook.
      # The webhook must respond with a ConversionReview object in the same version it received.
      conversionReviewVersions: ["v1","v1beta1"]
      clientConfig:
        service:
          namespace: default
          name: example-conversion-webhook-server
          path: /crdconvert
        caBundle: "Ci0tLS0tQk...<base64-encoded PEM bundle>...tLS0K"
  # either Namespaced or Cluster
  scope: Namespaced
  names:
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>
    plural: crontabs
    # singular name to be used as an alias on the CLI and for display
    singular: crontab
    # kind is normally the CamelCased singular type. Your resource manifests use this.
    kind: CronTab
    # shortNames allow shorter string to match your resource on the CLI
    shortNames:
    - ct
```

### Contacting the webhook

* api servers根据webhookClientConfig中的配置访问webhook
* Conversion webhooks可以通过url或者服务引用的方式进行调用，并且可选的配置CA进行校验TLS

### URL

* url是标准的格式`scheme://host:port/path`

* `host`不能指向集群内的运行的服务；通过指定`service`字段来使用service。因为host可能需要通过外部的DNS进行解析。host也可以设置为ip地址。
* 另外，使用localhost和127.0.0.1作为host是有风险的，除非在每一个调用该hook的apiserver所在的主机都部署该hook。
* The scheme must be "https"; the URL must begin with "https://".
* 验证
  * 不允许使用用户认证或简单的auth认证（"user:password@"）
  * 不允许使用Fragments ("#...")和query parameters ("?...")

url hook配置，TLS certificate使用系统信任的根证书，所以没有指定caBundle

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
...
spec:
  ...
  conversion:
    strategy: Webhook
    webhook:
      clientConfig:
        url: "https://my-webhook.example.com:9443/my-webhook-path"
```



### Service Reference

webhookClientConfig 中包含`service`字段执行一个service，用于访问conversion webhook。

* 如果webhook在集群内部署，应该使用sevice代替url
* 必须配置namespace和sevice name
* 端口，可选，默认443
* 路径，可选，默认/

示例如下：

```yaml
apiVersion: apiextensions.k8s.io/v1b
kind: CustomResourceDefinition
...
spec:
  ...
  conversion:
    strategy: Webhook
    webhook:
      clientConfig:
        service:
          namespace: my-service-namespace
          name: my-service-name
          path: /my-path
          port: 1234
        caBundle: "Ci0tLS0tQk...<base64-encoded PEM bundle>...tLS0K"
```

## Webhook request and response

### Request

webhook接受Post请求

* Content-Type: application/json
* apiextensions.k8s.io接口将ConversionReview序列化为json作为body

CustomResourceDefinition 中通过字段conversionReviewVersions指定webhook可接受的版本信息。

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
...
spec:
  ...
  conversion:
    strategy: Webhook
    webhook:
      conversionReviewVersions: ["v1", "v1beta1"]
```

* api server发送ConversionReview请求，获取conversionReviewVersions字段中支持的版本。如果没有api server支持的版本，则自定义资源定义将不被允许。
* 如果apiserver请求一个旧的conversion webhook configuration，不支持api server发送的ConversionReview中的任何版本，则访问webhook将失败。

### Response

Webhooks 响应

* 状态码 200
* `Content-Type: application/json`
* body：`ConversionReview` ，json序列化

转换成功，响应：

- `uid`, copied from the `request.uid` sent to the webhook
- `result`, set to `{"status":"Success"}`
- `convertedObjects`, containing all of the objects from `request.objects`, converted to `request.desiredVersion`

```json
{
  "apiVersion": "apiextensions.k8s.io/v1",
  "kind": "ConversionReview",
  "response": {
    # must match <request.uid>
    "uid": "705ab4f5-6393-11e8-b7cc-42010a800002",
    "result": {
      "status": "Success"
    },
    # Objects must match the order of request.objects, and have apiVersion set to <request.desiredAPIVersion>.
    # kind, metadata.uid, metadata.name, and metadata.namespace fields must not be changed by the webhook.
    # metadata.labels and metadata.annotations fields may be changed by the webhook.
    # All other changes to metadata fields by the webhook are ignored.
    "convertedObjects": [
      {
        "kind": "CronTab",
        "apiVersion": "example.com/v1",
        "metadata": {
          "creationTimestamp": "2019-09-04T14:03:02Z",
          "name": "local-crontab",
          "namespace": "default",
          "resourceVersion": "143",
          "uid": "3415a7fc-162b-4300-b5da-fd6083580d66"
        },
        "host": "localhost",
        "port": "1234"
      },
      {
        "kind": "CronTab",
        "apiVersion": "example.com/v1",
        "metadata": {
          "creationTimestamp": "2019-09-03T13:02:01Z",
          "name": "remote-crontab",
          "resourceVersion": "12893",
          "uid": "359a83ec-b575-460d-b553-d859cedde8a0"
        },
        "host": "example.com",
        "port": "2345"
      }
    ]
  }
}
```

转换失败，响应：

- `uid`, copied from the `request.uid` sent to the webhook
- `result`, set to `{"status":"Failed"}`

```json
{
  "apiVersion": "apiextensions.k8s.io/v1",
  "kind": "ConversionReview",
  "response": {
    "uid": "<value from request.uid>",
    "result": {
      "status": "Failed",
      "message": "hostPort could not be parsed into a separate host and port"
    }
  }
}
```



## Writing, reading, and updating versioned CustomResourceDefinition objects

### 写入

* 自定义资源写入时，按照指定存储版本存储
* 存储版本改变时，已经保存的不会自动改变；新创建和更新的资源对象，会保存为新版本
* 可能存在持久化为一个不再支持的版本

### 读取

* 读取资源对象时，需要执行资源对象的版本
* 如果指定的版本不同于持久化的版本，k8s会返回你请求版本的资源对象。但是持久化在磁盘的资源对象既不会改变也不会转换成其他格式
* 可以请求任何版本的资源对象，只要当前仍在使用中

### Previous storage versions



## Upgrade existing objects to a new stored version