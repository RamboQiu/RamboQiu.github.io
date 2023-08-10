---
title:  "学习别人的编码技巧之-SDWebImage"
date:   2021-09-01
desc: "如题"
keywords: "SDWebImage"
categories: [Tech, Study]
tags: [SDWebImage]
---

## 分类添加弱引用属性

```objc
- (SDOperationsDictionary *)sd_operationDictionary {
    @synchronized(self) {
        SDOperationsDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
        if (operations) {
            return operations;
        }
        operations = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operations;
    }
}
```

查阅API，还有以下方法

```objc
+ (NSMapTable<KeyType, ObjectType> *)strongToStrongObjectsMapTable;
+ (NSMapTable<KeyType, ObjectType> *)weakToStrongObjectsMapTable; // entries are not necessarily purged right away when the weak key is reclaimed
+ (NSMapTable<KeyType, ObjectType> *)strongToWeakObjectsMapTable;
+ (NSMapTable<KeyType, ObjectType> *)weakToWeakObjectsMapTable;// entries are not necessarily purged right away when the weak key or object is reclaimed
```



## 主线程安全调用宏

```objc
#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
#endif

#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_sync(dispatch_get_main_queue(), block);\
    }

#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }
```

使用`dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)`来判断当前是否在主线程



