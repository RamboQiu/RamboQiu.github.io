---
title:  "iOS的OC和Swift混编经验总结"
date:   2023-02-20
desc: "现如今Swift开发在新起的项目中使用居多。大厂使用的都是OC和Swift的混编技术，但是在混编中滥用Swift会导致包大小的增长过大。这里总结一部分工作中碰到的混编经验。"
keywords: "Swift, iOS, OC, 混编"
categories: [Tech, Study]
tags: []

---



## 1. Swift调用OC的方法进行命名优化

```objective-c
- (void)testSomeClass:(id<SomeClass>)obj;
- (void)testOtherClass:(id<OtherClass>)obj;
```

上面的OC方法在Swift中进行调用会合并成同一个

```swift
Class().test(_ obj:)
```

在Swift中会主动帮你进行重命名的优化，上面两个OC方法，方法名中的test**SomeClass**和参数类型**SomeClass**重复了，Swift就会主动进行优化。

但是优化的形式不是固定的。

```objective-c
@interface RAMXXXTest: XXXTest
- (BOOL)isCaseTest
@end
```

在swift中进行调用就变成了

```swift
if test.isCase() {}
```



## 2. Swift中使用load和initialize

+load和+initialize是OC中常用的两个方法，在Swift3.0之后的版本中使用会报错

```swift
Method 'load()' defines Objective-C class method 'load', which is not permitted by Swift
Method 'initialize()' defines Objective-C class method 'initialize', which is not permitted by Swift
```

所以，如果想在 Swift 类中使用这两个方法，则需要求助于 Objective-C，使用变通的方法。

在OC环境中实现Swift类的分类，并实现load和initialize方法调用swift的方法实现。

如下代码所示：

```swift
// swift
class Monitor: NSObject {
    @objc class func swiftLoad() {
        // do something
        print("swift load")
    }

    @objc class func swiftInitialize() {
        // do something
        print("swift initialize")
    }
}
```

```objective-c
// Objective-C
@implementation Monitor (Private)

+ (void)load {
    [self swiftLoad];
}

+ (void)initialize {
    [self swiftInitialize];
}

@end
```

由于这两个方法是 NSObject 类中声明的，所以我们的 Swift 类必须继承自 NSObject 或其子类。另外，我们也可以不用上面这么麻烦地去定义 `swiftLoad/swiftInitialize` 方法，而是所有操作直接在 Objective-C 代码中完成。

开源库`SwiftLoad`也是使用了此方式进行的。

## 3. Swift方法交换

### 传统方法

在Swift中实现方法交换必须满足一下条件

1. 包含swizzle方法的类需要继承自NSObject
1. 需要swizzle的方法必须有动态属性（dynamic attribute）

```swift
 class Father: NSObject {
       @objc dynamic func makeMoney() {
           print("make money")
       }
   }
   extension Father {
       static func swizzle() {
           let originSelector = #selector(Father.makeMoney)
           let swizzleSelector = #selector(Father.swizzle_makeMoney)
           let originMethod = class_getInstanceMethod(Father.self, originSelector)
           let swizzleMethod = class_getInstanceMethod(Father.self, swizzleSelector)
           method_exchangeImplementations(originMethod!, swizzleMethod!)
       }
       @objc func swizzle_makeMoney() {
           print("have a rest and make money")
       }
   }
   Father.swizzle()
   var tmp = Father()
   tmp.makeMoney() //  have a rest and make money
   tmp.swizzle_makeMoney() // make money
```

### 使用`@_dynamicReplacement(for: )`实现

```swift
class Father {
   dynamic func makeMoney() {
       print("make money")
   }
}
extension Father {
   @_dynamicReplacement(for: makeMoney())
   func swizzle_makeMoney() {
       print("have a rest and make money")
   }
}
Father().makeMoney() // have a rest and make money
```

### 实现原理

method swizzling都是利用runtime类获取selector的实现，来动态改变。Swift通过OC的Runtime特性来实现。

在Swift中使用dynamic属性来标记方法，是该方法只在运行期进行编译，以达到动态派发。



## 4. Swift中使用关联对象

[直接看代码演示](https://nshipster.com/swift-objc-runtime/)

```swift
extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }

    var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }

        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
}
```



## 5. OC中的@class

Swift混编中，引用到的一个OC类中，用的是向前申明的类，并且这个类没有在桥接文件中，就会出现报错

`Type '' cannot conform to protocol '' because it has requirements that cannot be satisfied`

```objective-c
@class TestClass
@protocol ObjProtocol <NSObject>
- (void)testFunc:(TestClass *)arg;
@end
```

尝试在swift中使用`ObjProtocol`就会报错

```swift
@objc class SwiftClass: NSObject, ObjProtocol { }
```



## 6. Swift中消息通知的使用方式

在Swift中使用通知，通知命名没有想OC那样轻松，只需要一个字符串就能搞定。

```swift
Notification.Name("myNoti")
```

可使用如下两种方式进行扩展

### 1. 使用extension扩展Notification.Name

```swift
extension Notification.Name {
	static let myNoti = Notification.Name("myNoti")
}

NotificationCenter.default.post(name: .myNoti, object: nil)
```

### 2. 使用Enum定义自己的通知名称

```swift
enum NotificationNames: String {
	case myNoti
	var nameValue: String {
		return "RAM" + rawVlue
	}
	var notiName: Notification.Name {
		return Notification.Name(nameValue)
	}
}
```

再定义一个自定义的post函数，方便调用。

```swift
func post(_ name: NotificationNames, object myObj: AnyObject? = nil) {
	NotificationCenter.default.post(name: name.myNoti, object: myObj)
}
```

使用起来就简单了

```swift
NotificationCenter.default.post(name: .myNoti, object: nil)
```



## 7. 可变类型容器转换

`NSMutableDictionary`在swift中不会默认的将它转化为`[[AnyHashable: Any]]`,所以在Swift中需要使用OC的容器类型。建议在混编环境下，使用不可变容器。

```swift
// 赋值
let headers: NSMutableDictionary = NSMutableDictionary()
if let tmp = responseHeader as? [String: Any] {
	_ = tmp.map { multi.setValue($0.value, forKey: $0.key) }
  response.headers = headers
}

// 取值
if let responseHeaders = response.headers as? [AnyHashable: Any] {
  model.responseHeaders = responseHeaders
}
```



## 8. Weak Strong

```swift
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
        // 这里就是代表了strong的含义
        guard let self = self else { return }
        self.elapsedTime += 1
}
```





## OC方法在Swift中的使用表

### 常用函数相关

| OC                                                           | Swift                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| NSMutableArray的方法removeObjectsInArray:<br />`objects = @[@"str1",@"str1"]` <br />`[tt removeObjectsInArray:objects];`<br /> | 可以使用高阶函数filter<br />`tt.filter { value in !objects.contains(value) }` |
| respond和perform                                             | `let selector = NSSelectorFromString("testFunc")`<br />`if self.obj?.responds(to: selector) == true`<br />`self.obj?.perform(selector)` |
|                                                              |                                                              |

### 语法相关

| OC                                    | Swift                                                        |
| ------------------------------------- | ------------------------------------------------------------ |
| block当做函数入参                     | 需要是用@escaping，代表逃逸闭包                              |
| switch显示贯穿，需要每个case结尾break | 隐式贯穿，不需要加break                                      |
| @weakify @strongify                   | [weak self]<br />                                            |
| 判空                                  | 使用 guard let aa = aa else { return }的方式                 |
| 类型转化                              | 使用 guard let aa = aa as? SomeClass else { return }的方式   |
| 懒加载                                | lazy var obj: Object = { return Object() }() 只执行一次的懒加载 |
| delloc                                | deinit                                                       |
| 枚举初始LogLevel level = 1            | LogLevel(rawValue: 1)                                        |
| C语言宏                               | 没有宏，要使用let或是函数                                    |







## 参考文章

[Awesome-tips](https://awesome-tips.gitbook.io/ios/yu-yan/swift/content-1)

[Swift & the Objective-C Runtime](https://nshipster.com/swift-objc-runtime/)

[Swift 5使用method swizzling](https://juejin.cn/post/6844904084177321997)

[Objective-C-Method-Swizzling](https://link.juejin.cn?target=http%3A%2F%2Fyulingtianxia.com%2Fblog%2F2017%2F04%2F17%2FObjective-C-Method-Swizzling%2F)

[Apple: using objective-c runtime features in Swift](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fusing_objective-c_runtime_features_in_swift)

[Swift 5 之后 "Method Swizzling"？](https://juejin.cn/post/6844903901599105032): 介绍了 `@_dynamicReplacement(for: )`和`连环Hook`的场景

