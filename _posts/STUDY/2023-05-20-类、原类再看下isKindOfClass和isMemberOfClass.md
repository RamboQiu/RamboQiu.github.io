---
title:  "类、原类再看下isKindOfClass和isMemberOfClass"
date:   2023-05-20
desc: "响应链里面是有个方法实现查找的过程的，其中有个isa指针，我们来分析下isa指针的指向"
keywords: "isa、isKindOfClass、isMemberOfClass"
categories: [Tech, Study]
tags: []



---

> 消息转发可以看[这篇文章](https://ramboqiu.github.io/posts/iOS%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%9C%BA%E5%88%B6/)

## 原类

首先我们回顾下消息转发的这张图

![20220210-1](/assets/img/study/WX20230419-195318@2x.png){: .normal}

总结如下：

```objective-c
MyClass *my = [MyClass new];
my->isa // MyClass 对象的isa指向它的类
my->isa->isa // MyClass.metaClass 用来存储类方法的地方
my->isa->isa->isa // NSObject.metaClass 子原类的isa指向父类的原类

my->superClass // NSObject 对象的superClass指向 isa->superClass
my->superClass->superClass // nil NSObject的父类为空nil
my->superClass->isa // NSObject.metaClass
my->superClass->isa->isa // NSObject.metaClass NSObject的isa指向自己
my->superClass->isa->superClass // NSObject NSObject的父类指向NSObject
```

最终都在NSObject和NSObject.metaClass进行收尾



## kind 和 member

我们查阅下runtime的`NSObject.mm`的源码，主要看下：

```objective-c
+ (Class)class {
    return self;
}

- (Class)class {
    return object_getClass(self);
}

+ (Class)superclass {
    return self->superclass;
}

- (Class)superclass {
    return [self class]->superclass;
}

+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
        if (tcls == cls) return YES;
    }
    return NO;
}

///// objc-class.mm
Class object_getClass(id obj) {
    if (obj) return obj->getIsa();
    else return Nil;
}
```

`class`:函数返回都是当前的类

`isKindOfClass`: 

- 类方法遍历从类的原类开始，递归查找父原类是否等于目标；
- 实例方法遍历从类开始，递归查找父类是否等于目标

`isMemberOfClass`: 

- 类方法是判断自己的原类是否等于目标类
- 实例方法是判断自己的类是否为目标类



有了上面的结论，我们来看下一个例子：

```objective-c
NSObject *obj = [NSObject new];
RAMDemoObject *demoObj = [RAMDemoObject new];
Class objc = [NSObject class];
Class democ =  [RAMDemoObject class];

实例方法判断：
true, obj isKindOfClass NSObject
true, demoObj isKindOfClass NSObject
false, obj isKindOfClass RAMDemoObject
true, demoObj isKindOfClass RAMDemoObject
  
true, obj isMemberOfClass NSObject
false, demoObj isMemberOfClass NSObject
false, obj isMemberOfClass RAMDemoObject
true, demoObj isMemberOfClass RAMDemoObject
类方法判断：
true, NSObject isKindOfClass NSObject
false, RAMDemoObject isKindOfClass RAMDemoObject
true, RAMDemoObject isKindOfClass NSObject

false, NSObject isMemberOfClass NSObject
false, RAMDemoObject isMemberOfClass RAMDemoObject
false, RAMDemoObject isMemberOfClass NSObject
```



总结出来结论：

**`kind`用来判断是否是目标的子类（ 也就是 >= 目标类的情况）**

**`member`用来判断是否是目标类（也就是 == 目标类的情况）**

**类方法和实例方法的判断都是从当前self的isa指针开始，对象实例方法就是从类，类方法就是从原类**

