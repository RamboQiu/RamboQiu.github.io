---
title:  "NSInvocation的巧妙用法"
date:   2021-08-25
desc: "NSInvocation是苹果工程师们提供的一个高层的消息转发系统，它是一个命令对象，可以给任意OC对象类型发送消息（Swift不支持）。有关NSInvocation的相关介绍这里不做赘述，网上很多文章，这里主要记录下他的几种项目中的灵活用法。"
keywords: "消息转发"
categories: [Tech, Study]
tags: [消息转发]
---

[iOS消息转发机制](https://ramboqiu.github.io/posts/iOS%E6%B6%88%E6%81%AF%E8%BD%AC%E5%8F%91%E6%9C%BA%E5%88%B6/)中介绍，Objective-C 是动态语言，所有的消息都是在 Runtime 进行派发的。

```c
OBJC_EXPORT void objc_msgSend(void /* id self, SEL op, ... */ ) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);
```

`objc_msgSend`是 C 函数，苹果不提倡我们直接使用该函数来向对象消息。

## performSelector

```objc
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;
```

- [在 ARC 场景下 performSelector 可能会造成内存泄漏](https://link.jianshu.com?t=http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown)

  ```objc
  //#pragma clang diagnostic push
  //#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      if (data.cellCustomSEL) {
        	// warning: PerformSelector may cause a leak because its selector is unknown
          [self performSelector:data.cellCustomSEL withObject:cell withObject:data];
      }
  //#pragma clang diagnostic pop
  ```

- `performSelector` 至多接收 2 个参数，如果参数多余 2 个，我们就无法使用 `performSelector` 来向对象发送消息了。

- performSelector 限制参数类型为 id，以标量数据(int double NSInteger 等)为参数的方法使用 performSelector 调用会出现各种各样诡异的问题

## NSInvocation

### 场景一 注册某一类方法或是模块为多方提供统一调用

#### 场景介绍

[见Demo](https://github.com/RamboQiu/RAMUtil/tree/master/RAMUtilDemo/RAMUtilDemo/RAMTestUI/NRPC)

多个客户端需要调用同一个服务的多个能力，每个客户端都要跟服务器制定一套自己的沟通协议，但是调用是服务的能力其实都是同一个，如下图

![screenshot-20210825-150727](/assets/img/study/screenshot-20210825-150727.png){: .normal}

导致代码复用性极差，改版后如下：

![screenshot-20210825-151338](/assets/img/study/screenshot-20210825-151338.png){: .normal}

其中的关键技术用的就是NSInvocation来实现的。

首先我们要整合多个客户端，定义用同一套协议，不能各自为营。

其次就是对于协议能够调用到正确的Native模块中。

#### 实战

##### 定义层

假设我们定义协议如下：

```json
{
  "handlerName": "bridge_share",
  "data": {
    "type": "wechat"
  }
}
```

桥接类我们这样设计：

1. 公共父类`BridgeModule`，所有的需要与客户机沟通的能力或是模块都需要继承至`BridgeModule`来实现。

2. 定义标准规范方法

   ```objc
   - (void)bridge_share:(id)data nativeBidgeResponseCallback:(Callback)responseCallback
   ```

##### 使用层

先总结

>1. 中继器注册所有桥接类和类中的方法
>2. 客户机开始调用，我们能够拿到`handlerName=bridge_share`
>3. 通过`handlerName`我们就能根据第一步在中继器中找到我们需要执行`NSInvocation`的类和方法了

1. 中继器注册所有桥接类和类中的方法

   使用runtime方法获取所有继承至`BridgeModule`的类和方法
   
   ```objc
   gMessageModuleClassMap = [NSMutableDictionary new];
   
   int count = objc_getClassList(NULL,0);
   NSMutableArray * moduleClasses = [NSMutableArray new];
   Class *classes = (Class *)malloc(sizeof(Class) * count);
   objc_getClassList(classes, count);
   
   for (int i = 0; i < count; i++) {
       if ([BridageModule class] == class_getSuperclass(classes[i])) {
           [moduleClasses addObject:classes[i]];
       }
   }
   free(classes);
   
   for (Class moduleClass in moduleClasses) {
       unsigned int count;
       
       Method *methodList = class_copyMethodList(moduleClass, &count);
       for (unsigned int i = 0; i < count; i++) {
           Method method = methodList[i];
           NSString *methodName = NSStringFromSelector(method_getName(method));
           if ([methodName hasSuffix:@":nativeBidgeResponseCallback:"]) {
               NSArray *components = [methodName componentsSeparatedByString:@":"];
               NSString *messageName = components.firstObject;
               if (messageName.length > 0) {
                   [gMessageModuleClassMap setObject:moduleClass forKey:messageName];
               }
           }
       }
       free(methodList);
   }
   ```
   
   这样之后`gMessageModuleClassMap`中就保存着我们定义的协议`handlerName`和要执行他的类

2. 客户机开始调用，我们能够拿到`handlerName=bridge_share`

   ```objc
   Class moduleClass = gMessageModuleClassMap[handlerName];
   BridgeModule *nativeModule = [[moduleClass alloc] init];
   NSString *methodString = [NSString stringWithFormat:@"%@%@", handlerName, @":nativeBidgeResponseCallback:"];
   SEL selector = NSSelectorFromString(methodString);
   ```

3. 通过`handlerName`我们就能根据第一步在中继器中找到我们需要执行`NSInvocation`的类和方法了

   ```objc
   NSMethodSignature *signature = [nativeModule methodSignatureForSelector:selector];
   if (!signature) {
       return NO;
   }
   
   id requestData = message.data;
   NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
   invocation.target = nativeModule;
   [invocation setSelector:selector];
   [invocation setArgument:&requestData atIndex:2];
   
   if (message.callback) {
       Block_copy((__bridge void *)message.callback);
       [invocation setArgument:&message.callback atIndex:3];
   }
   [invocation invoke];
   ```



### 场景二 block

有关block使用NSInvocation，问题是如何获得block的MethodSignature，block并没有selector，我们可以通过获取block的编码的Signature来使用`-[NSMethodSignature signatureWithObjCTypes:]`

其中[Clang官方文档](https://link.segmentfault.com/?url=http%3A%2F%2Fclang.llvm.org%2Fdocs%2FBlock-ABI-Apple.html)和[stackoverflow](https://link.segmentfault.com/?url=http%3A%2F%2Fstackoverflow.com%2Fquestions%2F9048305%2Fchecking-objective-c-block-type)都有获取block的函数编码的讲解。

[iOS的lua热修复详解](https://ramboqiu.github.io/posts/iOS%E7%9A%84lua%E7%83%AD%E4%BF%AE%E5%A4%8D%E8%AF%A6%E8%A7%A3/)的热修复中，block的方法替换采用的是[CTObjectiveCRuntimeAdditions](https://github.com/ebf/CTObjectiveCRuntimeAdditions)的解法

```objc
struct CTBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;	// NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    CTBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    CTBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    CTBlockDescriptionFlagsIsGlobal = (1 << 28),
    CTBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    CTBlockDescriptionFlagsHasSignature = (1 << 30)
};
typedef int CTBlockDescriptionFlags;



@interface SpaBlockDescription : NSObject

@property (nonatomic, readonly) CTBlockDescriptionFlags flags;
@property (nonatomic, readonly) NSMethodSignature *blockSignature;
@property (nonatomic, readonly) unsigned long int size;
@property (nonatomic, readonly) id block;

- (id)initWithBlock:(id)block;
@end
  
  
@implementation SpaBlockDescription

- (id)initWithBlock:(id)block
{
    if (self = [super init]) {
        _block = block;
        
        struct CTBlockLiteral *blockRef = (__bridge struct CTBlockLiteral *)block;
        _flags = blockRef->flags;
        _size = blockRef->descriptor->size;
        
        if (_flags & CTBlockDescriptionFlagsHasSignature) {
            void *signatureLocation = blockRef->descriptor;
            signatureLocation += sizeof(unsigned long int);
            signatureLocation += sizeof(unsigned long int);
            
            if (_flags & CTBlockDescriptionFlagsHasCopyDispose) {
                signatureLocation += sizeof(void(*)(void *dst, void *src));
                signatureLocation += sizeof(void (*)(void *src));
            }
            
            const char *signature = (*(const char **)signatureLocation);
            _blockSignature = [NSMethodSignature signatureWithObjCTypes:signature];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@", [super description], _blockSignature.description];
}

@end
```



[Demo工程中用的如下](https://github.com/RamboQiu/RAMUtil/blob/master/RAMUtilDemo/RAMUtilDemo/RAMTestUI/NSInvocation%2BBlock.m)

```objc

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;     // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        // void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        // const char *signature;                         // IFF (1<<30)
        void* rest[1];
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

static const char *__BlockSignature__(id blockObj)
{
    struct Block_literal_1 *block = (__bridge void *)blockObj;
    struct Block_descriptor_1 *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    int offset = 0;
    if(block->flags & BLOCK_HAS_COPY_DISPOSE)
        offset += 2;
    return (char*)(descriptor->rest[offset]);
}

// NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:__BlockSignature__(block)]];
// invocation.target = block;
```





### 场景三 热修复中的消息转发

以这个[iOS的lua热修复详解](https://ramboqiu.github.io/posts/iOS%E7%9A%84lua%E7%83%AD%E4%BF%AE%E5%A4%8D%E8%AF%A6%E8%A7%A3/)为例子，先简单介绍先热修复中方法修复原理：

热修复核心逻辑，方法替换，将需要热修的方法实现指向`_objc_msgForward`，原实现指向我们新定义的`sel`

![](/assets/img/study/screenshot-20210825-162930.png){: .normal}

然后hook`forwardInvocation`，使他指向我们实现的方法。

```objc
static void replaceMethod(Class klass, SEL sel)
{
    if (klass == nil || sel == nil) {
        return ;
    }
    SEL originSelector = spa_originForSelector(sel);
    Method targetMethod = class_getInstanceMethod(klass, sel);
    if (targetMethod) {
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        class_addMethod(klass, originSelector, method_getImplementation(targetMethod), typeEncoding);
        spa_swizzleForwardInvocation(klass);
        // We use forwardInvocation to hook in.
        class_replaceMethod(klass, sel, spa_getMsgForwardIMP(klass, sel), typeEncoding);
        
        [[SpaClass replacedClassMethods] addObject:@{@"class":NSStringFromClass(klass), @"sel":NSStringFromSelector(sel)}];
    }
}

static void spa_swizzleForwardInvocation(Class klass)
{
    NSCParameterAssert(klass);
    // get origin forwardInvocation impl, include superClass impl，not NSObject impl, and class method to kClass
    SEL originForwardSelector = NSSelectorFromString(SPA_ORIGIN_FORWARD_INVOCATION_SELECTOR_NAME);
    if (![klass instancesRespondToSelector:originForwardSelector]) {
        Method originalMethod = class_getInstanceMethod(klass, @selector(forwardInvocation:));
        IMP originalImplementation = method_getImplementation(originalMethod);
        class_addMethod(klass, NSSelectorFromString(SPA_ORIGIN_FORWARD_INVOCATION_SELECTOR_NAME), originalImplementation, "v@:@");
        
    }
    // If there is no method, replace will act like class_addMethod.
    class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__SPA_ARE_BEING_CALLED__, "v@:@");
}

static void __SPA_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation)
```







## 参考文档

[NSInvocation 调用Block](https://segmentfault.com/a/1190000004141249)

[Block-ABI-Apple](https://clang.llvm.org/docs/Block-ABI-Apple.html)
