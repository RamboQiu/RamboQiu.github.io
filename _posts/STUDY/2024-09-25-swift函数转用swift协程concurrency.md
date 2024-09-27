---
title:  "swift函数回调改写为swift协程concurrency的async函数"
date:   2024-09-25
desc: "最低支持系统终于提到iOS13.0，可以使用swift的特性协程concurrency，来解决多接口调用的回调地狱问题。这里介绍使用协程实现两个异步线程变成同步，两个异步线程实现类似group。将回调改写成 async 函数。"
categories: [Tech, Study]
tags: [Swift, concurrency, 协程, async, await]


---

之前也写过一篇swift的[新特性文章](https://ramboqiu.github.io/posts/iOS&Swift%E6%96%B0%E7%89%B9%E6%96%B0/#%E5%B9%B6%E5%8F%91concurrencyasyncawait)，但是app最低版本没到iOS13.0，所以一直没有用到业务代码中。

理论性知识相关就不写了，这里直接上代码改造

## 异步串行改

```swift
// 两个异步方法
func helloAsync(onComplete: @escaping (Int) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        onComplete(Int(arc4random()))
    }
}

func hiAsync(onComplete: @escaping (Int) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
        onComplete(Int(arc4random()))
    }
}

// 两个异步变串行，例如请求完一个接口拿到结果在请求另一个接口

func concurrency() {
    helloAsync { [weak self] result1 in
        self?.hiAsync { result2 in
            print("1. \(result1)-\(result2)")
        }
    }
}
```

改之后

```swift
// 两个方法修改
func helloAsync() async -> Int {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let result = Int(arc4random())
            print("a. \(result)")
            continuation.resume(returning: result)
        }
    }
}
func hiAsync() async -> Int {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let result = Int(arc4random())
            print("b. \(result)")
            continuation.resume(returning: result)
        }
    }
}

var result_g = -1
func concurrency() {
    Task { // 必须要用task包裹，不然就只能在async方法中调用
        let result = await helloAsync()
        print("1. \(result)")
        let result2 = await hiAsync()
        print("2. \(result2)")

        result_g = result // 不会报错
    }
}
```



## 异步DispatchGroup改造

```swift
func concurrency() {
    // 两个异步都执行完再响应
    var r1 = -1
    var r2 = -1
    let group = DispatchGroup()
    group.enter()
    helloAsync { result1 in
        r1 = result1
        group.leave()
    }
    group.enter()
    hiAsync { result2 in
        r2 = result2
        group.leave()
    }

    group.notify(queue: .main) {
        print("2. \(r1)-\(r2)")
    }
}
```

改造后

```swift
var r1 = -1
var r2 = -1

func concurrency() {
    Task {
        await processAsync2()
    }
}

// 写法1，将hello和hi都改成2秒延迟
// print在两秒之后同时输出，说明hi没有等待hello执行完
func processAsync1() async {
    async let loadHello = helloAsync()
    async let loadHi = hiAsync()

    let hello = await loadHello
    r1 = hello // 可以这么写
    print("Done: \(hello)")
    let hi = await loadHi
    r2 = hi
    print("Done: \(hi)")
}
// 写法2
func update1(_ r: Int) {
    r1 = r
}

func update2(_ r: Int) {
    r2 = r
}

func processAsync2() async {
  	// 模拟两个接口，处理两个接口返回的值不一样的情况
    let value = await withTaskGroup(of: Any.self, returning: Any.self) { group in
        group.addTask {
            let r = await self.helloAsync()
            // self.r1 = r 不能这么写，必须抽出一个方法
            await self.update1(r)
            return r
        }
        group.addTask {
            let r = await self.hiAsync()
            await self.update2(r)
            return r
        }
        guard let first = await group.next() else {
            group.cancelAll()
            return 0
        }
        let second = await group.next() ?? 0
        group.cancelAll()
        return (first, second)

//            var result: [Any] = []
//            for await value in group {
//                result.append(value)
//            }
//            return result
    }
    if let value_ = value as? (Int, Int) {
        print("Done: \(r1) + \(r2) = \(value_.0 + value_.1)")
    }
}
```

相比来看，第一种写法比较简单



## 参考文档

https://www.bennyhuo.com/2021/10/13/swift-coroutines-02-wrap-callback/

https://www.cnswift.org/concurrency

https://juejin.cn/post/7181121378471378981

https://juejin.cn/post/7169914508360548360