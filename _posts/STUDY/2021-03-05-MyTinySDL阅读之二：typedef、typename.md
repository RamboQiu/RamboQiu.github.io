---
title:  "MyTinySDL阅读之二：typedef、typename"
date:   2021-03-05
desc: "源码中的第一个vector的实现中的第一个自己不是很懂的点，typedef、typename"
keywords: "c"
categories: [Tech, Study]
tags: [c++,SDL]
---

在vector.h中，刚开始就出现了大量的typedef和typename，所以，恶补了下基本知识。

```c++
// 模板类: vector 
// 模板参数 T 代表类型
template <class T>
class vector
{
  static_assert(!std::is_same<bool, T>::value, "vector<bool> is abandoned in mystl");
public:
  // vector 的嵌套型别定义
  typedef mystl::allocator<T>                      allocator_type;
  typedef mystl::allocator<T>                      data_allocator;

  typedef typename allocator_type::value_type      value_type;
  typedef typename allocator_type::pointer         pointer;
```

# typedef

下列文章大部分摘录：[C++ typedef用法小结](https://www.cnblogs.com/charley_yang/archive/2010/12/15/1907384.html)

typedef在我的最原始的理解，就是取别名，和define挺像的。

## 作用

1. 定义易于记忆的类型名
2. 简化代码

## 主要使用方式

### 1. 经典用法

C 语言提供了 **typedef** 关键字，可以使用它来为类型取一个新的名字（和宏的区别需要注意）。可以用作同时声明指针型的多个对象。例如：

- 标识符 BYTE 可作为类型 **unsigned char** 的缩写

  ```c++
  typedef unsigned char BYTE;
  BYTE b1, b2; // 同下
  unsigned char b1, b2;
  ```

- 申明多个指针的便捷方式

  ```c++
  char* pa, pb;// 这里只声明了一个指向字符变量的指针和一个字符变量
  // 利用typedef
  typedef char* PCHAR; // 一般用大写
  PCHAR pa, pb; // 可行，同时声明了两个指向字符变量的指针
  // 就是如下
  char *pa, *pb;// 相对来说没有用typedef的形式直观，尤其在需要大量指针的地方，typedef的方式更省事。
  ```

### 2. struct辅助

[C typedef](https://www.w3cschool.cn/c/c-typedef.html)

```c++
struct Books
{
   char  title[50];
   char  author[50];
};
// Books 使用
struct Books b1;
```

以前的C代码中，声明struct新对象时，必须要带上struct，即形式为： struct 结构名 对象名。

而在C++中，则可以直接写：结构名 对象名，即：Books p1;

估计某人觉得经常多写一个struct太麻烦了，于是就发明了：

```c++
typedef struct Books
{
   char  title[50];
   char  author[50];
} BOOK;
// Books 使用
Book b1; // 这样就比原来的方式少写了一个struct，比较省事，尤其在大量使用的时候
```

或许，在C++中，typedef的这种用途二不是很大，但是理解了它，对掌握以前的旧代码还是有帮助的，毕竟我们在项目中有可能会遇到较早些年代遗留下来的代码。

### 3. 多平台兼容

最常见的在OC里面，32位和64位机型，NSInteger代表不同的

```c++
#if __LP64__ || 0 || NS_BUILD_32_LIKE_64
typedef long NSInteger;
typedef unsigned long NSUInteger;
#else
typedef int NSInteger;
typedef unsigned int NSUInteger;
#endif
```

所以 ，可以用typedef来定义与平台无关的类型。当跨平台时，只要改下 typedef 本身就行，不用对其他源码做任何修改。

另外，因为typedef是定义了一种类型的新别名，不是简单的字符串替换，所以它比宏来得稳健（虽然用宏有时也可以完成以上的用途）。

### 4. 简化复杂的申明

为复杂的声明定义一个新的简单的别名。

方法是：在原来的声明里逐步用别名替换一部分复杂声明，如此循环，把带变量名的部分留到最后替换，得到的就是原声明的最简化版。

- 例子1：
  
  ```c++
  int *(*a[5])(int, char*);
  // 变量名为a，直接用一个新别名pFun替换a就可以了：
  typedef int *(*pFun)(int, char*);
  // 原声明的最简化版：
  pFun a[5];
  ```
  
- 例子2：
  
  ```c++
  void (*b[10]) (void (*)());
  // 变量名为b，先替换右边部分括号里的，pFunParam为别名一：
  typedef void (*pFunParam)();
  // 再替换左边的变量b，pFunx为别名二：
  typedef void (*pFunx)(pFunParam);
  // 原声明的最简化版：
  pFunx b[10];
  ```
  
- 例子3：
  
  ```c++
  doube(*)() (*e)[9];
  // 变量名为e，先替换左边部分，pFuny为别名一：
  typedef double(*pFuny)();
  // 再替换右边的变量e，pFunParamy为别名二
  typedef pFuny (*pFunParamy)[9];
  // 原声明的最简化版：
  pFunParamy e;
  ```

理解复杂声明可用的“右左法则”：

从变量名看起，先往右，再往左，碰到一个圆括号就调转阅读的方向；括号内分析完就跳出括号，还是按先右后左的顺序，如此循环，直到整个声明分析完。举例：

int (\*func)(int \*p);

首先找到变量名func，外面有一对圆括号，而且左边是一个\*号，这说明func是一个指针；然后跳出这个圆括号，先看右边，又遇到圆括号，这说明(\*func)是一个函数，所以func是一个指向这类函数的指针，即函数指针，这类函数具有int\*类型的形参，返回值类型是int。

int (\*func[5])(int \*);

func右边是一个[]运算符，说明func是具有5个元素的数组；func的左边有一个\*，说明func的元素是指针（注意这里的\*不是修饰func，而是修饰func[5]的，原因是[]运算符优先级比\*高，func先跟[]结合）。跳出这个括号，看右边，又遇到圆括号，说明func数组的元素是函数类型的指针，它指向的函数具有int\*类型的形参，返回值类型为int。

也可以记住2个模式：

1. type (\*)(....)函数指针
2. type (\*)[]数组指针

## 两大陷阱

### 陷阱一：和const的配合使用

记住，typedef是定义了一种类型的新别名，不同于宏，它不是简单的字符串替换。比如：

```c++
typedef char* PSTR;
int mystrcmp(const PSTR, const PSTR);
// 实际上是下面这样
int mystrcmp(char* const, char* const);
```

const PSTR实际上相当于const char\*吗？不是的，它实际上相当于char\* const。

原因在于const给予了整个指针本身以常量性，也就是形成了常量指针char* const。

简单来说，记住当const和typedef一起出现时，typedef不会是简单的字符串替换就行。

### 陷阱二：指定一个以上的存储类

typedef在语法上是一个存储类的关键字（如auto、extern、mutable、static、register等一样），虽然它并不真正影响对象的存储特性。

```c++
typedef static int INT2; //不可行,编译将失败，会提示“指定了一个以上的存储类”。
```

**以上资料出自：**http://blog.sina.com.cn/s/blog_4826f7970100074k.html 作者：赤龙

## typedef 与 #define的区别

- 通常讲，typedef要比#define要好，特别是在有指针的场合。请看例子：

  ```c++
  typedef char *pStr1;
  #define pStr2 char *;
  
  pStr1 s1, s2;
  pStr2 s3, s4;
  ```

  在上述的变量定义中，s1、s2、s3都被定义为char *，而s4则定义成了char。

  不是我们所预期的指针变量，根本原因就在于#define只是简单的字符串替换，而typedef则是为一个类型起新名字。

- 下面的代码中编译器会报一个错误，你知道是哪个语句错了吗？

  ```c++
  typedef char * pStr;
  char string[4] = "abc";
  const char *p1 = string;
  const pStr p2 = string;
  p1++;
  p2++;
  ```

  是p2++出错了。

  这个问题再一次提醒我们：typedef和#define不同，它不是简单的文本替换。

  上述代码中const pStr p2并不等于const char * p2。（而是：char * const p2）

  const pStr p2和const long x本质上没有区别，都是对变量进行只读限制，只不过此处变量p2的数据类型是我们自己定义的而不是系统固有类型而已。因此，const pStr p2的含义是：限定数据类型为char *的变量p2为只读，因此p2++错误。

# typename

下列文章大部分摘录于：[C++ typename的起源与用法](https://feihu.me/blog/2014/the-origin-and-usage-of-typename/)

```c++
template <class T>
class vector
{
  static_assert(!std::is_same<bool, T>::value, "vector<bool> is abandoned in mystl");
public:
  // vector 的嵌套型别定义
  typedef mystl::allocator<T>                      allocator_type;
```

上面是一个典型的C++模板，其实还有另一种写法

```c++
template <typename T>
class vector
```

class => typename

之前我看这个class就特别别扭，class不是类吗，像是模板T如果为int啥的，不是类啊，为什么会出现在模板里面，现在终于知道了：

C++之父Bjarne Stroustrup，在起草C++模板规范的时候，因为历史遗留很多程序都是用的class，最后妥协继续沿用而没有使用一个新的关键字。但是对很多人来说，总是不习惯`class`，因为从其本来存在的目的来说，是为了区别于语言的内置类型（int，float），用于声明一个用户自定义类型。

typename出现的真正原因是：

```c++
template <class T>
void foo() {
    T::iterator * iter;
    // ...
}

// 比如有个自定义类型
struct ContainsAnotherType {
    static int iterator;
    // ...
};

// 这么使用
foo<ContainsAnotherType>();
```

那么，`T::iterator * iter;`被编译器实例化为`ContainsAnotherType::iterator * iter;`，这是什么？前面是一个静态成员变量而不是类型，那么这便成了一个乘法表达式，只不过`iter`在这里没有定义，编译器会报错：

> error C2065: ‘iter’ : undeclared identifier

这个时候typename就出来了。

> A name used in a template declaration or definition and that is dependent on a template-parameter is assumed not to name a type unless the applicable name lookup finds a type name or the name is qualified by the keyword typename.

表达的意思即是：如果你想直接告诉编译器`T::iterator`是类型而不是变量，只需用`typename`修饰。

```c++
template <class T>
void foo() {
    typename T::iterator * iter;
    // ...
}
```

