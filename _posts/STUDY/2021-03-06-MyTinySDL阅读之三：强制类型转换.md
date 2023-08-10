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

显示类型转换就是在表达式中明确指定将一种类型转换为另一种类型。隐式类型转换一般是由编译器进行转换操作，显示类型转换是由程序员写明要转换成的目标类型。显示类型转换又被称为强制类型转换。

### C风格的

iOS开发过程中，经常会遇到需要进行类型转换的情况，比如取页面栈中的页面

```c++
if ([vc isKindOfClass:TestViewController.class]) {
		TestViewController *v =  (TestViewController *)vc;
}

//基本格式就是
type val = (type)(expression);
```

C语言的这种显示的强制类型转换，还是会存在很大的风险，而且强制转换语法()，随处可见，不利于使用文件检索工具定位关键代码，所以C++对这块进行了升级，如下

### C++风格的

C++提供了4个命名的强制类型转换，它们都有如下的基本形式：

```c++
type val = cast-name<type>(expression);
```

cast-name是static_cast、dynamic_cast、const_cast、reinterpret_cast中的一种。type是要转换成的新类型，expression是要被转换的数据或是表达式。

例如，老式的C风格的 double 转 int 的写法为：

```c
double scores = 95.5;
int n = (int)scores;
```

C++ 新风格的写法为：

```c++
double scores = 95.5;
int n = static_cast<int>(scores);
```

#### static_cast

文章开通部位，MyTinySDL中用到的。很像 C 语言中的旧式类型转换。

static_cast 是“静态转换”的意思，也就是在编译期间转换，转换失败的话会抛出一个编译错误。

static_cast的使用有如下几种：

1. 上面说到的自动类型转换，如short->int、int->double、const->非const、向上转型等；
2. void指针和具体类型指针之间的转换，例如`void *`转`int *`、`char *`转`void *`等；
3. 有转换构造函数或者类型转换函数的类与其它类型之间的转换，例如 double 转 Complex（调用转换构造函数）、Complex 转 double（调用类型转换函数）

不可使用的情况：

1. **两个具体类型指针之间的转换，例如`int *`转`double *`、`Student *`转`int *`等。**不同类型的数据存储格式不一样，长度也不一样，用 A 类型的指针指向 B 类型的数据后，会按照 A 类型的方式来处理数据：如果是读取操作，可能会得到一堆没有意义的值；如果是写入操作，可能会使 B 类型的数据遭到破坏，当再次以 B 类型的方式读取数据时会得到一堆没有意义的值。
2. int 和指针之间的转换。**将一个具体的地址赋值给指针变量**是非常危险的，因为该地址上的内存可能没有分配，也可能没有读写权限，恰好是可用内存反而是小概率事件。

```c++
#include <cstdlib>
#include <iostream>
using namespace std;
class Complex {
   public:
    Complex(double real = 0.0, double imag = 0.0) : m_real(real), m_imag(imag) {}

   public:
    operator double() const { return m_real; }  //类型转换函数
   private:
    double m_real;
    double m_imag;
};
int main() {
    //下面是正确的用法
    int m = 100;
    Complex c(12.5, 23.8);
    long n = static_cast<long>(m);                           //宽转换，没有信息丢失
    char ch = static_cast<char>(m);                          //窄转换，可能会丢失信息
    int *p1 = static_cast<int *>(malloc(10 * sizeof(int)));  //将void指针转换为具体类型指针
    void *p2 = static_cast<void *>(p1);                      //将具体类型指针，转换为void指针
    double real = static_cast<double>(c);                    //调用类型转换函数
    const int a = 10;
    int b = static_cast<int>(a);
    const int c = static_cast<const int>(b);

    //下面的用法是错误的
    float *p3 = static_cast<float *>(p1);  //不能在两个具体类型的指针之间进行转换
    p3 = static_cast<float *>(0X2DF9);     //不能将整数转换为float指针类型
    return 0;
}
```



#### dynamic_cast

dynamic_cast 主要用来在继承体系中的安全向下转型，是实现多态的一种方式，要借助 RTTI 进行检测，所有只有一部分能成功。（当然也允许向上转型，无条件的，不会进行任何检查自动成功）。

dynamic_cast 与 static_cast 是相对的，dynamic_cast 是“动态转换”的意思，static_cast 是“静态转换”的意思。dynamic_cast 会在程序运行期间借助 RTTI 进行类型转换，这就要求基类必须包含虚函数；static_cast 在编译期间完成类型转换，能够更加及时地发现错误。

type和expression 必须同时是指针类型或者引用类型。换句话说，dynamic_cast 只能转换指针类型和引用类型，其它类型（int、double、数组、类、结构体等）都不行。

对于指针，如果转换失败将返回 NULL；对于引用，如果转换失败将抛出`std::bad_cast`异常。

##### 1) 向上转型（Upcasting）

向上转型时，只要待转换的两个类型之间存在继承关系，并且基类包含了虚函数（这些信息在编译期间就能确定），就一定能转换成功。因为向上转型始终是安全的，所以 dynamic_cast 不会进行任何运行期间的检查，这个时候的 dynamic_cast 和 static_cast 就没有什么区别了。

「**向上转型时不执行运行期检测**」虽然提高了效率，但也留下了安全隐患，请看下面的代码：

```c++
#include <iomanip>
#include <iostream>
using namespace std;
class Base {
   public:
    Base(int a = 0) : m_a(a) {}
    int get_a() const { return m_a; }
    virtual void func() const {}

   protected:
    int m_a;
};
class Derived : public Base {
   public:
    Derived(int a = 0, int b = 0) : Base(a), m_b(b) {}
    int get_b() const { return m_b; }

   private:
    int m_b;
};
int main() {
    //情况①
    Derived *pd1 = new Derived(35, 78);
    Base *pb1 = dynamic_cast<Base *>(pd1);
    cout << "pd1 = " << pd1 << ", pb1 = " << pb1 << endl; // pd1 = 0x7f91c6c05940, pb1 = 0x7f91c6c05940
    cout << pb1->get_a() << endl; // 35
    pb1->func();
    //情况②
    int n = 100;
    Derived *pd2 = reinterpret_cast<Derived *>(&n);
    Base *pb2 = dynamic_cast<Base *>(pd2);
    cout << "pd2 = " << pd2 << ", pb2 = " << pb2 << endl; // pd2 = 0x7ffee55b4e54, pb2 = 0x7ffee55b4e54
    cout << pb2->get_a() << endl;  // 32657 输出一个垃圾值 
    pb2->func();                   ///bin/sh: line 1: 27791 Segmentation fault: 11  内存错误
    return 0;
}
```

情况①是正确的，没有任何问题。对于情况②，pd 指向的是整型变量 n，并没有指向一个 Derived 类的对象，在使用 dynamic_cast 进行类型转换时也没有检查这一点，而是将 pd 的值直接赋给了 pb（这里并不需要调整偏移量），最终导致 pb 也指向了 n。因为 pb 指向的不是一个对象，所以`get_a()`得不到 m_a 的值（实际上得到的是一个垃圾值），`pb2->func()`也得不到 func() 函数的正确地址。

> `pb2->func()`得不到 func() 的正确地址的原因在于，pb2 指向的是一个假的“对象”，它没有虚函数表，也没有虚函数表指针，而 func() 是虚函数，必须到虚函数表中才能找到它的地址。

##### 2) 向下转型（Downcasting）

向下转型是有风险的，dynamic_cast 会借助 RTTI 信息进行检测，确定安全的才能转换成功，否则就转换失败。那么，哪些向下转型是安全地呢，哪些又是不安全的呢？下面我们通过一个例子来演示：

```c++
#include <iostream>
using namespace std;
class A {
   public:
    virtual void func() const { cout << "Class A" << endl; }

   private:
    int m_a;
};
class B : public A {
   public:
    virtual void func() const { cout << "Class B" << endl; }

   private:
    int m_b;
};
class C : public B {
   public:
    virtual void func() const { cout << "Class C" << endl; }

   private:
    int m_c;
};
class D : public C {
   public:
    virtual void func() const { cout << "Class D" << endl; }

   private:
    int m_d;
};
int main() {
    A *pa = new A();
    B *pb;
    C *pc;

    //情况①
    pb = dynamic_cast<B *>(pa);  //向下转型失败
    if (pb == NULL) {
        cout << "Downcasting failed: A* to B*" << endl;
    } else {
        cout << "Downcasting successfully: A* to B*" << endl;
        pb->func();
    }
    pc = dynamic_cast<C *>(pa);  //向下转型失败
    if (pc == NULL) {
        cout << "Downcasting failed: A* to C*" << endl;
    } else {
        cout << "Downcasting successfully: A* to C*" << endl;
        pc->func();
    }

    cout << "-------------------------" << endl;

    //情况②
    pa = new D();                //向上转型都是允许的
    pb = dynamic_cast<B *>(pa);  //向下转型成功
    if (pb == NULL) {
        cout << "Downcasting failed: A* to B*" << endl;
    } else {
        cout << "Downcasting successfully: A* to B*" << endl;
        pb->func();
    }
    pc = dynamic_cast<C *>(pa);  //向下转型成功
    if (pc == NULL) {
        cout << "Downcasting failed: A* to C*" << endl;
    } else {
        cout << "Downcasting successfully: A* to C*" << endl;
        pc->func();
    }

    return 0;
}

//Downcasting failed: A* to B*
//Downcasting failed: A* to C*
//-------------------------
//Downcasting successfully: A* to B*
//Class D
//Downcasting successfully: A* to C*
//Class D
```

这段代码中类的继承顺序为：A --> B --> C --> D。pa 是`A*`类型的指针，当 pa 指向 A 类型的对象时，向下转型失败，pa 不能转换为`B*`或`C*`类型。当 pa 指向 D 类型的对象时，向下转型成功，pa 可以转换为`B*`或`C*`类型。同样都是向下转型，为什么 pa 指向的对象不同，转换的结果就大相径庭呢？

在《[C++ RTTI机制下的对象内存模型](https://yqlab.me/archives/54.html)》中，可以知道虚函数存在时对象的真实内存模型，并且也了解到，每个类都会在内存中保存一份类型信息，编译器会将存在继承关系的类的类型信息使用指针“连接”起来，从而形成一个继承链（Inheritance Chain），也就是如下图所示的样子：

![img](/assets/img/study/1-1F220145TLW.jpg){: .normal}

当使用 dynamic_cast 对指针进行类型转换时，程序会先找到该指针指向的对象，再根据对象找到当前类（指针指向的对象所属的类）的类型信息，并从此节点开始沿着继承链向上遍历，如果找到了要转化的目标类型，那么说明这种转换是安全的，就能够转换成功，如果没有找到要转换的目标类型，那么说明这种转换存在较大的风险，就不能转换。

对于本例中的情况①，pa 指向 A 类对象，根据该对象找到的就是 A 的类型信息，当程序从这个节点开始向上遍历时，发现 A 的上方没有要转换的 B 类型或 C 类型（实际上 A 的上方没有任何类型了），所以就转换败了。对于情况②，pa 指向 D 类对象，根据该对象找到的就是 D 的类型信息，程序从这个节点向上遍历的过程中，发现了 C 类型和 B 类型，所以就转换成功了。

总起来说，dynamic_cast 会在程序运行过程中遍历继承链，如果途中遇到了要转换的目标类型，那么就能够转换成功，如果直到继承链的顶点（最顶层的基类）还没有遇到要转换的目标类型，那么就转换失败。对于同一个指针（例如 pa），它指向的对象不同，会导致遍历继承链的起点不一样，途中能够匹配到的类型也不一样，所以相同的类型转换产生了不同的结果。

从表面上看起来 dynamic_cast 确实能够向下转型，本例也很好地证明了这一点：B 和 C 都是 A 的派生类，我们成功地将 pa 从 A 类型指针转换成了 B 和 C 类型指针。但是<font color=red>**从本质上讲，dynamic_cast 还是只允许向上转型**</font>，因为它只会向上遍历继承链。造成这种假象的根本原因在于，派生类对象可以用任何一个基类的指针指向它，这样做始终是安全的。本例中的情况②，pa 指向的对象是 D 类型的，pa、pb、pc 都是 D 的基类的指针，所以它们都可以指向 D 类型的对象，dynamic_cast 只是让不同的基类指针指向同一个派生类对象罢了。

#### const_cast

const_cast 比较好理解，它用来去掉表达式的 const 修饰或 volatile 修饰。换句话说，const_cast 就是用来将 const/volatile 类型转换为非 const/volatile 类型。

下面我们以 const 为例来说明 const_cast 的用法：

```c++
#include <iostream>
using namespace std;
int main() {
    const int n = 100;
    int *p = const_cast<int *>(&n);
    *p = 234;
    cout << "n = " << n << endl; // n = 100
    cout << "*p = " << *p << endl; // *p = 234
    int m = n;
    cout << "m = " << m << endl; // m = 100
    return 0;
}
```

`&n`用来获取 n 的地址，它的类型为`const int *`，必须使用 const_cast 转换为`int *`类型后才能赋值给 p。由于 p 指向了 n，并且 n 占用的是栈内存，有写入权限，所以可以通过 p 修改 n 的值。

为什么通过 n 和 *p 输出的值不一样呢？**这是因为 C++ 对常量的处理更像是编译时期的`#define`，是一个值替换的过程，代码中所有使用 n 的地方在编译期间就被替换成了 100**。换句话说，第 8 行代码被修改成了下面的形式：

cout<<"n = "<<100<<endl;

这样以来，即使程序在运行期间修改 n 的值，也不会影响 cout 语句了。

使用 const_cast 进行强制类型转换可以突破 C/C++ 的常数限制，修改常数的值，因此有一定的危险性；但是你如果这样做的话，基本上会意识到这个问题，因此也还有一定的安全性。

#### reinterpret_cast

reinterpret 是“重新解释”的意思，顾名思义，reinterpret_cast 这种转换仅仅是对二进制位的重新解释，不会借助已有的转换规则对数据进行调整，非常简单粗暴，所以风险很高。

reinterpret_cast 可以认为是 static_cast 的一种补充，一些 static_cast 不能完成的转换，就可以用 reinterpret_cast 来完成，例如两个具体类型指针之间的转换、int 和指针之间的转换（有些编译器只允许 int 转指针，不允许反过来）。

下面的代码代码演示了 reinterpret_cast 的使用：

```c++
#include <iostream>
using namespace std;
class A {
   public:
    A(int a = 0, int b = 0) : m_a(a), m_b(b) {}

   private:
    int m_a;
    int m_b;
};
int main() {
    //将 char* 转换为 float*
    char str[] = "string";
    float *p1 = reinterpret_cast<float *>(str);
    cout << *p1 << endl;  //1.83194e+25
    //将 int 转换为 int*
    int *p = reinterpret_cast<int *>(100);
    //将 A* 转换为 int*
    p = reinterpret_cast<int *>(new A(25, 96));
    cout << *p << endl;        // 25
    cout << *(p + 1) << endl;  // 96

    return 0;
}
```

可以想象，用一个 float 指针来操作一个 char 数组是一件多么荒诞和危险的事情，这样的转换方式不到万不得已的时候不要使用。将`A*`转换为`int*`，使用指针直接访问 private 成员刺穿了一个类的封装性，更好的办法是让类提供 get/set 函数，间接地访问成员变量。



## 类、struct类型转换

oc的block实现原理里面有个很典型的struct类型转换





## 内存对象模型

```c++
class A{
protected:
    int a1;
public:
    virtual int A_virt1();
    virtual int A_virt2();
    static void A_static1();
    void A_simple1();
};
class B{
protected:
    int b1;
    int b2;
public:
    virtual int B_virt1();
    virtual int B_virt2();
};
class C: public A, public B{
protected:
    int c1;
public:
    virtual int A_virt2();
    virtual int B_virt2();
};
```

![2020-07-19-111318](/assets/img/study/2020-07-19-111318.jpg){: .normal}