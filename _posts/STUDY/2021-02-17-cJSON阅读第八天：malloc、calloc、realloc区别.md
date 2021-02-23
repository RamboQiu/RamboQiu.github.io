---
title:  "cJSON阅读第八天：malloc、calloc、realloc区别"
date:   2021-02-17
desc: "oc里面经常用[[Object alloc] init]，c里面alloc来源如此"
keywords: "c"
categories: [Tech, Study]
tags: [c,cJSON,alloc]
---

```c
#define malloc  unity_malloc
#define calloc  unity_calloc
#define realloc unity_realloc
#define free    unity_free

void* unity_malloc(size_t size);
void* unity_calloc(size_t num, size_t size);
void* unity_realloc(void * oldMem, size_t size);
void unity_free(void * mem);
```

在cJSON.c的print(const cJSON * const, cJSON_bool, const internal_hooks *const)方法中

```c
/* check if reallocate is available */
if (hooks->reallocate != NULL) 
{
  printed = (unsigned char*) hooks->reallocate(buffer->buffer, buffer->offset + 1);      
}
else /* otherwise copy the JSON over to a new buffer */
{
  printed = (unsigned char*) hooks->allocate(buffer->offset + 1);
}
```

## 介绍

### C语言跟内存分配方式

1. 静态存储分配

   内存在编译 时候就已经分配好，这块内存在程序的整个运行期间都存在.例如全局变量、static变量。

2. 栈内存分配

   在执行函数时，函数内局部变量的存储单元都可以在栈上创建，函数执行结束时这些存储单元自动被释放.栈内存分配运算内置于处理器的指令集中，效率很高，但是分配的内存容量有限。

3. 堆内存分配

   亦称动态内存分配. 程序在运行的时候用malloc或new申请任意多少的内存，程序员自己负责在何时用free或delete释放内存.动态内存的生存期由用户决定，使用非常灵活，但问题也最多。

4. C语言跟内存申请相关的函数主要有 alloca、calloc、malloc、free、realloc等

### 1. malloc

```c
void* malloc(unsigned size);
```

> 见print(const cJSON * const, cJSON_bool, const internal_hooks * const) 方法，初始化buffer->buffer

在堆内存中分配一块长度为size字节的连续区域，参数size为需要内存空间的长度。此存储区中的初始值不确定。

### 2. calloc

```c
void* calloc(size_t numElements, size_t sizeOfElement);
```

与malloc相似，参数sizeOfElement为单位元素长度（例如：sizeof(int)），numElements为元素个数，即在内存中申请numElements * sizeOfElement字节大小的连续内存空间。该空间中的每一位（bit）都初始化为0。

### 3. realloc

```c
void* realloc(void* ptr, unsigned newsize);
```

使用realloc函数为ptr重新分配大小为size的一块内存空间

> 见ensure(printbuffer * const, size_t)方法的底部 if (needed > p->length) 需要的空间不够

下面是这个函数的工作流程：

1. 对ptr进行判断，如果ptr为NULL，则函数相当于malloc(new_size)，试着分配一块大小为new_size的内存，如果成功将地址返回，否则返回NULL。如果ptr不为NULL，则进入 2。
2. 查看ptr是不是在堆中，如果不是的话会抛出realloc invalid pointer异常。如果ptr在堆中，则查看new_size大小，如果new_size大小为0，则相当于free(ptr)，将ptr指向的内存空间释放掉，返回NULL。如果new_size小于原大小，则ptr中的数据可能会丢失，只有new_size大小的数据会保存；如果size等于原大小，等于什么都没有做；如果size大于原大小，则查看ptr指向的位置还有没有足够的连续内存空间，如果有的话，分配更多的空间，返回的地址和ptr相同，如果没有的话，在更大的空间内查找，如果找到size大小的空间，将旧的内容拷贝到新的内存中，把旧的内存释放掉，则返回新地址，否则返回NULL。

总结来说，就是更改以前分配区的长度。

### 4. alloca

向栈申请内存，因此无需释放。缺点是：某些系统在函数已被调用后不能增加栈帧长度，于是也就不能支持alloca 函数。尽管如此，很多软件包还是使用alloca函数，也有很多系统支持它。

## malloc、calloc、realloc 之间的区别

1. 是否会对申请的内存空间进行初始化

函数malloc不能初始化所分配的内存空间，函数calloc() 会将所分配的内存空间中的每一位都初始化为零。


2. 功能上的区别

malloc与calloc用来动态分配内存空间，而realloc则是对给定的指针所指向的内存空间进行扩大或者缩小。

## 参考文章

[malloc、calloc、realloc之间的区别](https://blog.csdn.net/cloud323/article/details/76902842)

[malloc、calloc、realloc的区别？](https://www.jianshu.com/p/718f68a092b0)

[malloc与realloc的区别](https://blog.csdn.net/wangyeqiang/article/details/8510576)