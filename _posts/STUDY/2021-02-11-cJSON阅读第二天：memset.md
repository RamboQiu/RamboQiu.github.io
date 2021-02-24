---
title:  "cJSON阅读第二天：memset"
date:   2021-02-11
desc: "oc里面经常用[[Object alloc] init]，c里面init来源如此"
keywords: "c"
categories: [Tech, Study]
tags: [c,cJSON,memset]

---

## 1. memset

oc里面，[[Object alloc] init]，初始化对象，其中init就是将内存地址进行初始化。比如如下的，cJSON.c文件中的cJSON_New_Item方法

```c
static cJSON *cJSON_New_Item(const internal_hooks * const hooks)
{
    cJSON* node = (cJSON*)hooks->allocate(sizeof(cJSON));// (cJSON*)malloc(sizeof(CJSON));
    if (node)
    {  /*https://www.runoob.com/cprogramming/c-function-memset.html 
    		https://www.cnblogs.com/oomusou/archive/2006/11/25/572127.html
        复制字符 '\0'（一个无符号字符）到参数 node 所指向的字符串的前 sizeof(cJSON) 个字符
        就是类似初始化内存地址的内容*/
        memset(node, '\0', sizeof(cJSON));
    }

    return node;
}
```

malloc为变量分配一块内存地址，却没对该变量设定任何初始值，所以该变量目前的值为该内存块所残留的值，虽可直接使用该变量，但并没有任何意义。

[以array为例](https://www.cnblogs.com/oomusou/archive/2006/11/25/572127.html)，当宣告完array及其大小后，第一件事情就是为array中所有element设定初始值，通常我们会用for来设定

```c
#include <stdio.h>
#include <string.h>
#define ia_size 5
int main() {
    char ia[ia_size];
    memset(ia, 'a', sizeof(ia));
    for (int i = 0; i < ia_size; i++) {
        printf("%c ", ia[i]);//a a a a a 
    }
    return 0;
}
```

> 注意：[memset不能用来初始化-1或0以外的整型数组](https://stackoverflow.com/questions/17288859/using-memset-for-integer-array-in-c)
>
> ```c
> Synopsis
> #include <string.h>
> void *memset(void *s, int c, size_t n);
> Description
> The memset() function fills the first n bytes of the memory area pointed to by s with the constant byte c.
> Return Value
> The memset() function returns a pointer to the memory area s.
> ```
>
> [用stackoverflow上的另一个说法](https://stackoverflow.com/questions/7202411/why-does-memsetarr-1-sizeofarr-sizeofint-not-clear-an-integer-array-t  )
>
> > Just change to memset (arr, -1, sizeof(arr));
> >
> > Note that for other values than 0 and -1 this would not work since memset sets the byte values for the block of memory that starts at the variable indicated by *ptr for the following num bytes.
> >
> > ```c
> > void * memset ( void * ptr, int value, size_t num );
> > ```
> >
> > And since int is represented on more than one byte, you will not get the desired value for the integers in your array.
> >
> > Exceptions:
> >
> > - 0 is an exception since, if you set all the bytes to 0, the value will be zero
> >
> > - -1 is another exception since, as Patrick highlighted -1 is 0xff (=255) in int8_t and 0xffffffff in int32_t
> >
> > The reason you got:
> >
> > ```c
> > arr[0] = -1
> > arr[1] = 255
> > arr[2] = 0
> > arr[3] = 0
> > arr[4] = 0
> > ```
> >
> > Is because, in your case, the length of an int is 4 bytes (32 bit representation), the length of your array in bytes being 20 (=5*4), and you only set 5 bytes to -1 (=255) instead of 20.
>
> int是4 bytes，如果你尝试如下：
>
> ```c
> int arr[15];
> memset(arr, 1, 6*sizeof(int));    //wrong!
> ```
>
> 输出的数字会是0x01010101 = 16843009，因为memset是按byte为单位进行初始化值的。
>
> ```c
> int ia[ia_size];
> memset(ia, 1, 2);
> ```
>
> 调试控制台输出如下：
>
> ```
> -exec p ia[0]
> (int) $4 = 257
> -exec p/t ia[0]
> (int) $6 = 0b00000000000000000000000100000001
> ```
>
> 可以很清晰的看到前两个byte被赋值为了1，而不是前两个4bytes为1。（int = 4bytes）
>
> vscode 调试工作台[使用 -exec 调用gdb命令](https://www.rt-thread.org/document/site/application-note/setup/qemu/vscode/an0021-qemu-vscode/)，[gdb调试](https://blog.csdn.net/haoel/article/details/2883)
>
> ```
> d  按十进制格式显示变量。
> u  按十六进制格式显示无符号整型。
> o  按八进制格式显示变量。
> t  按二进制格式显示变量。
> a  按十六进制格式显示变量。
> c  按字符格式显示变量。
> f  按浮点数格式显示变量。
> ```









