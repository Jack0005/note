# 自定义CRD

## 开始之前

* k8s master version:
  *  大于等于1.16.0，使用apiextensions.k8s.io/v1
  * 大于等于1.7.0，使用apiextensions.k8s.io/v1beta1

## 创建crd定义

* apiextensions.k8s.io/v1

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
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

*  apiextensions.k8s.io/v1beta1

```yaml
# Deprecated in v1.16 in favor of apiextensions.k8s.io/v1
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  # name must match the spec fields below, and be in the form: <plural>.<group>
  name: crontabs.stable.example.com
spec:
  # group name to use for REST API: /apis/<group>/<version>
  group: stable.example.com
  # list of versions supported by this CustomResourceDefinition
  versions:
    - name: v1
      # Each version can be enabled/disabled by Served flag.
      served: true
      # One and only one version must be marked as the storage version.
      storage: true
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
  preserveUnknownFields: false
  validation:
    openAPIV3Schema:
      type: object
      properties:
        spec:
          type: object
          properties:
            cronSpec:
              type: string
            image:
              type: string
            replicas:
              type: integer
```

## 创建crd对象

```yaml
apiVersion: "stable.example.com/v1"
kind: CronTab
metadata:
  name: my-new-cron-object
spec:
  cronSpec: "* * * * */5"
  image: my-awesome-cron-image
```

## 删除crd定义

```shell
kubectl delete -f resourcedefinition.yaml
kubectl get crontabs
```

## 指定结构化数据类型

* OpenAPI v3.0 validation中，结构化数据必须指定类型，资源创建和更新时会进行数据类型检查
* apiextensions.k8s.io/v1 强制要求定义schema
* apiextensions.k8s.io/v1beta1可选定义schema

### 结构化schema定义规则

(OpenAPI v3.0 validation)

#### 规则一

* `type`： 指定根属性
* `properties，additionalProperties`：指定对象节点属性
* `items`：指定数组节点属性
* 其他例外情况：
  * `x-kubernetes-int-or-string: true`
  * `x-kubernetes-preserve-unknown-fields: true`

#### 规则二

* 对象或者数组中元素，在`allOf、anyOf、oneOf、not`中指定的，同时还需要再在其外进行指定

#### 规则三

* 不在`allOf、anyOf、oneOf、not`中，使用`description、type、default、additionalProperties、nullable`，除了两种模式：`x-kubernetes-int-or-string: true`

#### 规则四

* 如果`metadata`被指定，只允许约束`metadata.name`和`metadata.generatename`

### 保留vs裁剪未知属性字段

”自定义资源定义“ 通常作为json存储在etcd中。这表示，即使在[OpenAPI v3.0 validation schema](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#validation)中，未指定schema的字段也会被持久化。然而，在k8s本身的资源中，例如pod，未指定的schema的字段，会在持久化到etcd前进行被丢掉，这种对未知属性字段的丢弃叫做”pruning“。

* apiextensions.k8s.io/v1beta1 转化为 apiextensions.k8s.io/v1时，可能缺少指定schema，也可能spec.preserveUnknownFields 是true

* apiextensions.k8s.io/v1beta1中，裁剪spec.preserveUnknownFields可以通过指定为false关闭

#### 控制pruning

* apiextensions.k8s.io/v1 中强制开启

* apiextensions.k8s.io/v1beta1中 可选spec.preserveUnknownField
  * false
  * true

#### IntOrString

```yaml
type: object
properties:
  foo:
    x-kubernetes-int-or-string: true
```

#### RawExtension

RawExtensions存储完整的k8s 对象（包含apiVersion、kind）

```yaml
type: object
properties:
  foo:
    x-kubernetes-embedded-resource: true
    x-kubernetes-preserve-unknown-fields: true
```

* x-kubernetes-embedded-resource: true

apiVersion、kind、metadata会被隐式指定和校验

## CRD多版本

[Custom resource definition versioning](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definition-versioning/)

这里在另一篇文章中描述

## 高级主题

### Finalizers

是一种允许控制器实现异步预删除的钩子。自定义对象也支持该特性。

### Validation

#### 使用

* **FEATURE STATE:** `Kubernetes v1.16 [stable]`
*  [OpenAPI v3 schemas](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject) or [validatingadmissionwebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) 中可用
* apiextensions.k8s.io/v1 中必需
* apiextensions.k8s.io/v1beta1 可选

#### 限制

* 不能使用的属性
  * definitions
  * dependencies
  * deprecated
  * discriminator
  * id
  * patternProperties
  * readOnly
  * writeOnly
  * xml
  * $ref
* uniqueItems不能设置为true
* additionalProperties 不能设置为false
* additionalProperties和properties互斥

一些字段只能在指定个性开启时设置：

* default：只能在apiextensions.k8s.io/v1 crd定义中使用；Defaulting从1.17之后处于GA，CustomResourceDefaulting从1.16处于beta阶段。

### Defaulting

* **FEATURE STATE:** `Kubernetes v1.17 [stable]`
* 在 [OpenAPI v3 validation schema](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#validation)中允许指定默认值

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        # openAPIV3Schema is the schema for validating custom objects.
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                  pattern: '^(\d+|\*)(/\d+)?(\s+(\d+|\*)(/\d+)?){4}$'
                  default: "5 0 * * *"
                image:
                  type: string
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 10
                  default: 1
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
```

Defaulting发生在以下三种情况：

* 在请求api server时，使用请求版本的默认值
* 在从etcd读取数据时，使用存储版本的默认值
* 在使用非空patchs改变准入插件之后，使用准入webhook对象版本的默认值

默认值被使用在从etcd读取数据过程中，而不是自动写回到etcd时。如果需要将默认值持久化到etcd中，需要通过API进行update请求。

除了metadata的默认值之外，所有的默认值都会被裁剪，并且必须被提供的shema校验。

metadata   x-kubernetes-embedded-resources: true的字段的默认值在创建crd定义时不会被裁剪。但是会发生在处理请求过程中。

### Publish Validation Schema in OpenAPI v2[ ](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#publish-validation-schema-in-openapi-v2)



### Additional printer columns

* 版本信息： kubenetes 1.11开始，kubectl采用服务端打印。服务端决定`kubectl get`输出哪些行。用户可在crd定义中定制打印属性。

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              cronSpec:
                type: string
              image:
                type: string
              replicas:
                type: integer
    additionalPrinterColumns:
    - name: Spec
      type: string
      description: The cron spec defining the interval a CronJob is run
      jsonPath: .spec.cronSpec
    - name: Replicas
      type: integer
      description: The number of jobs launched by the CronJob
      jsonPath: .spec.replicas
    - name: Age
      type: date
      jsonPath: .metadata.creationTimestamp
```

#### Priority

* `kubectl get` 打印的列属性，可设置优先级
* 优先级为0，标准模式下打印
* 大于0，`-o wide`模式下输出

#### Format

* 输出列属性支持
  * int32
  * int64
  * float
  * double
  * byte
  * date
  * date-time
  * password

### Subresources

* FEATURE STATE:** `Kubernetes v1.16 [stable]`
* 自定义资源支持/status和/scale子资源
* CustomResourceSubresources 在 kube-apiserver中可选关闭

```yaml
--feature-gates=CustomResourceSubresources=false
```

在定义crd定义时，status和scale子资源可选开启。

#### Status subresource[ ](https://kubernetes.io/docs/tasks/extend-kubernetes/custom-resources/custom-resource-definitions/#status-subresource)

当status子资源打开时，自定义crd的/status被暴露出来。

* 在crd内部，status和spec可以用.status和.spec的json路径表示
* 请求/status的PUT操作，会带着整个自定义资源对象，但是会忽略除了status之外的所有改变
* 请求/status的PUT操作，仅校验自定义资源的status schema
* 请求自定义资源的put、post、patch会忽略status属性值的改变
* 除了.metadat和.status的改变之外，其他任何的改变.metadata.generation都会自增
* 在 CRD OpenAPI validation schema的根中，只有以下结构被允许：
  * Description
  * Example
  * ExclusiveMaximum
  * ExclusiveMinimum
  * ExternalDocs
  * Format
  * Items
  * Maximum
  * MaxItems
  * MaxLength
  * Minimum
  * MinItems
  * MinLength
  * MultipleOf
  * Pattern
  * Properties
  * Required
  * Title
  * Type
  * UniqueItems

#### Scale subresource

当scale子资源打开时，自定义crd的/scale被暴露出来。autoscaling/v1.Scale对象被作为/scale负载发出来

开启scale子资源，需要在CustomResourceDefinition定义一下值：

* SpecReplicasPath：定义在自定义资源内部的json路径，和Scale.Spec.Replicas一致
  * 必需
  * 只能是.spec下的json路径和`.`标记
  * 如果自定义资源的SpecReplicasPath为空值，/scale的get请求返回错误
* StatusReplicasPath
  * 必需
  * 只能是.status下的json路径和`.`标记
  * 如果自定义资源的StatusReplicasPath为空值，status副本数默认值为0

* LabelSelectorPath
  * 可选
  * 必须和HPA一起工作
  * 只能是.status或.spec下的json路径和`.`标记
  * 如果LabelSelectorPath为空，/scale中status selector默认值为空字符串
  * 这个JSON路径指向的字段必须是一个字符串字段(不是一个复杂的选择器结构)，它包含一个字符串形式的序列化标签选择器。

### Categories

Categories是一个属于自定义资源的分组的链表。可以通过`kubectl get <category-name>`列出属于该分组的资源。该特性处于beta阶段，从1.10版本起对自定义资源可用。

以下例子，在CustomResourceDefinition的Categories中添加了`all`，我们可以使用`kubectl get all`输出自定义资源。

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: crontabs.stable.example.com
spec:
  group: stable.example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                cronSpec:
                  type: string
                image:
                  type: string
                replicas:
                  type: integer
  scope: Namespaced
  names:
    plural: crontabs
    singular: crontab
    kind: CronTab
    shortNames:
    - ct
    # categories is a list of grouped resources the custom resource belongs to.
    categories:
    - all
```

