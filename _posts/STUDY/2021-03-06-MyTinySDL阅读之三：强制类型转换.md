---
title:  "MyTinySDL阅读之三：强制类型转换"
date:   2021-03-06
desc: "static_cast、dynamic_cast、const_cast和reinterpret_cast"
keywords: "c"
categories: [Tech, Study]
tags: [c++,SDL]
---

allocator.h中，有段代码用到了static_cast，如下

```c++
template <class T>
T* allocator<T>::allocate()
{
  return static_cast<T*>(::operator new(sizeof(T)));
}
```

这里涉及到两个知识点：隐式类型转换和显示类型转换。首先要介绍下，什么是类型转换？

## 类型转换

数字是怎么在计算机中存储的？其实数字在计算机中都是用二进制0,1表示的，比如说int a = 3，那么它在计算机中的存储格式为00000000000000000000000000000011。负数则是以补码的形式存储。

> **数据类型转换本质为两个**
>
> **1. 窄变宽：左边补符号位**
>
> **2. 宽变窄：保留低数据**

```c
int main() {
  // 窄变宽
    char a=-1;          //1111 1111
    char b=1;            //0000 0001
    unsigned char c=1;    //0000 0001
    unsigned char d=255;    //1111 1111
    int e=a; //整形4字节，32位，符号位为1，因此左边补1111 1111 1111 1111 1111 1111 1111 1111
    printf("%d,%x\n",e,e);    
    int e=b;    //符号位为0，因此左边全补0为0000 0000 0000 0000 0000 0000 0000 0001
    printf("%d,%x\n",e,e);
    int e=c;    //无符号型符号位为0，因此左边全补0为0000 0000 0000 0000 0000 0000 0000 0001
    printf("%d,%x\n",e,e);
    int e=d;    // 同理无符号型符号为0因此给左边补0为0000 0000 0000 0000 0000 0000 1111 1111
    printf("%d,%x\n",e,e);
  // 宽变窄
  	int a=0x12345678;
    int b=0xff347890;
    char c=a; //0x78  0111 1000
    char d=b;    //0x90 1001 0000,0111 000
    printf("%d,%x\n",c,c); //120 78
    printf("%d,%x\n",d,d); //符号位为-1取反+1 -112，ffffff90
    return 0;
}
```

[C++类型转换本质](https://blog.csdn.net/king13059595870/article/details/102868848)

## 隐式类型转换

[C++类型转换](https://segmentfault.com/a/1190000016582440)

[C语言隐式类型转换](https://blog.csdn.net/hanchaoman/article/details/7827031)

隐式类型转换分三种，即算术转换、赋值转换。

### 算术转换

算术类型转换的设计原则就是尽可能避免损失精度。

具体地，有以下几条参考规则：

1. **整型提升：将小整数类型转换成较大的整数类型**。例如，如果一个运算对象的类型是long double，那么另外一个运算对象，无论它的类型是什么，都会被转换成long double。

2. **有符号类型转换为无符号类型**。类型转换一般不会改变对象内存的值，当一个有符号类型的对象转换为无符号类型时，其表示出来的值可能发生变化，例如，int a = -1 (0xff); unsigned int b = a; 则b的值为255。实用举例如下：

   ```c
   #include <stdio.h>
   #include <string.h>
   int main(void) {
       char *p = "hello";
       int a = -1;
       /*比较字符串的长度和a的大小*/
       if (strlen(p) > a) {
           printf("len > a\n");
       } else {
           printf("len < a\n"); // len < a
       }
       printf("%d\n",strlen(p)); // 5
       return 0;
   }
   ```

3. **在条件判断中，非布尔类型自动转换为布尔类型**。如果指针或算术类型的值为0，转换为false，否则转换为true。

### 赋值转换

赋值运算符**右边的**数据类型必须**转换成**赋值号**左边的**类型，若右边的数据类型的长度大于左边，则要进行截断或舍入操作。

下面用一实例说明：

```c
char ch;
int i,result;
float f;
double d;
result = ch/i + (f*d-i);
```

1. 首先计算 ch/i,ch → int型，ch/i → int型。

2. 接着计算 f\*d-i，由于最长型为double型，故f→double型，i→double型，f\*d-i→double型。

3. (ch/i) 和(f\*d-i)进行加运算，由于f\*d-i为double型，故ch/i→double型，ch/i+(f\*d-i)→double型。

4. 由于result为int型，故ch/i + (f*d-i)→double→int，即进行截断与舍入，最后取值为整型。

#### 溢出的思考

假设int是8bit，最大值就是255，如果两个数相加，就可能出现超过255，这就是溢出，如何检测溢出：

```c
if(a > INT_MAX - b) {
    printf("overflow\n");
}
```

溢出总结：

- 选择合适的数据类型，当数据较大可能会超出short int的范围时，就不该选择short int，而应该选择int等所表示范围更大的类型。
- 在设计上尽量回避溢出。例如，要计算两个整数的平均值，我们想到的方法可能是(a+b)/2，但是这样却有溢出的风险，我们可以换一种方式：a-(a-b)/2，这种方式就回避了溢出的问题。

## 显示类型转换





## 类、struct类型转换

oc的block实现原理里面有个很典型的struct类型转换

