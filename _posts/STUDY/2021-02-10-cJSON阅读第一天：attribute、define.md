---
title:  "cJSON阅读第一天：attribute、define"
date:   2021-02-10
desc: "点击一看，全是不了解的知识点，一个个学习下，在oc里面也都是会用到的"
keywords: "c"
categories: [Tech, Study]
tags: [c,cJSON,attribute,define]
---

## 1. \_\_attribute\_\_ 的使用

### section used

18年写过一篇文章介绍used section的使用，见[__attribute__-used-section的简单应用](https://ramboqiu.github.io/posts/__attribute__-used-section%E7%9A%84%E7%AE%80%E5%8D%95%E5%BA%94%E7%94%A8/)

### visibility

[gcc __attribute__关键字举例之visibility](https://blog.csdn.net/starstarstone/article/details/7493144?utm_source=tuicool&utm_medium=referral)

```c
/* visibility用于设置动态链接库中函数的可见性，将变量或函数设置为hidden，则该符号仅在本so中可见，在其他库中则不可见。*/
#if (defined(__GNUC__) || defined(__SUNPRO_CC) || defined (__SUNPRO_C)) && defined(CJSON_API_VISIBILITY)
#define CJSON_PUBLIC(type)   __attribute__((visibility("default"))) type
#else
#define CJSON_PUBLIC(type) type
#endif
#endif
```

## 2. 宏的使用

- 宏后面不接任何东西

  例如，\_\_WINDOWS\_\_后面是空白的，是为了在使用的时候能够使用第二行来表示第一行

  ```c
  #if !defined(__WINDOWS__) && (defined(WIN32) || defined(WIN64) || defined(_MSC_VER) || defined(_WIN32)) /* 第一行 */
  #define __WINDOWS__
  #endif

  #ifdef __WINDOWS__ /* 第二行 */
  #endif
  ```
  
  还有的用法是：防止重复包含头文件。
  
  ```c
  #ifndef XXX
  #define XXX
  ...
  #endif
  ```





