# linux 内核模块

## 基本的信息

* 内核模块注册/注销方式

```shell
insmod hello.ko

rmmod hello.ko

modprobe
```

* 必备头文件

```c
#include <linux/module.h>
#include <linux/init.h>
```

* 必备的宏

```C
MODULE_LICENSE  	//许可证
MODULE_AUTHOR		//描述模块作者
MODULE_DESCRIPTION	//模块用途简述
MODULE_VERSION		//模块版本
MODULE_ALIAS		//模块别名
MODULE_DEVICE_TABLE	//模块支持的设备
```

* 模块注册和注销的函数

```C
//模块的注册
static int __init my_module_init_func(void){
  /* 这里是代码 */
}
module_init(my_module_init_func);

//模块注销
static void __exit my_module_exit_func(void){
  /* 这里是代码 */
}
module_exit(my_module_exit_func);
```

* 模块错误处理

```c
//方式一、错误处理时，善用goto
int __init my_init_func(void){
  int err;
  
  /* 使用指针和名称注册 */
  err = register_this(ptr1,"skull");
  if (err) goto fail_this;
  err = register_that(ptr2,"skull");
  if (err) goto fail_that;
  err = register_those(ptr3,"skull");
  if (err) goto fail_those;
  
  return 0; /*成功*/

fail_those: unregister_those(ptr3,"skull");
fail_that: unregister_that(ptr2,"skull");
fail_this: unregister_this(ptr1,"skull");
}

//方式二、执行注册时记录，然后在模块清除函数中注销

void __exit my_exit_func(void){
  unregister_those(ptr3,"skull");
  unregister_that(ptr2,"skull");
  unregister_this(ptr1,"skull"); 
  return;
}
```

* 模块初始化传参

```shell
insmod {module_name} para1=10 para2="hello"
```

```c
static int para1 = 1;
static char *para2 = "world"
module_param(para1,int,S_IRUGO);
module_param(para2,charp,S_IRUGO);

// 数组参数，其中，name:数组名称，type:数组元素的类型，num:一个整数变量，用户提供的值的个数，perm：数组长度上限值
module_param_array(name,type,num,perm);
```



## 示例程序

### 示例程序

```c
#include<linux/module.h>
#include<linux/init.h>

static int __init hello_init(void)
{
    printk(KERN_ALERT "hello world\n");
    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_ALERT "bye world\n");
    return;
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
```

### Makefile

```makefile
# 这里是Makefile
TARGET := hello
ifneq ($(KERNELRELEASE),)
	obj-m := $(TARGET).o
#	$(TARGET)-objs = hello.o  init.o
else
	KERNELDIR ?= /lib/modules/$(shell uname -r)/build
	PWD := $(shell pwd)
default:
		$(MAKE) -C $(KERNELDIR) M=$(PWD) modules
clean:
		rm -rf *.o *.mod.c *.ko *.symvers *.order *.makers *.cmd *.mod
endif
```