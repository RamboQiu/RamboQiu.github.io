---
title:  "鸿蒙next第一课-arkTS基础语法篇"
date:   2024-11-13
desc: "本文主要是作为iOS开发，会用swift语言编程的基础上，对鸿蒙学习理解的记录文章"
categories: [Tech, Study]
tags: [鸿蒙, arkTS]


---

## 官方教程

官方教程详细见[ArkTS语言介绍](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/introduction-to-arkts-V5)。

## 简介

首先一点，HarmonyOS Next不是Android，不是一定要Android同学去适配。他的编程语言ArkTS是基于TypeScript改的。所以说，前端同学去学习可能在语法上更有优势。

做为一个iOS开发同学，swift的语法在很大程度上，和ts也挺接近的，所以学习起来难度不是很大，下面记录下差异部分，以增加对ArkTS语法的理解。

## 工程目录结构

见[文章](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/start-with-ets-stage-V5)

## 和Swift语法对比

### 函数返回表示

```ts
// swift
function test() -> String {
	return "name"
}
// ArkTS
function test(): string {
  return "name"
}
```

### 可选类型

```ts
// swift
function add(left: number?, right: number?) -> number? {
	guard let left, right else { return nil }
	return left + right
}
// ArkTS
function add(left?: number, right?: number): number | undefined {
  if (left != undefined && right != undefined) {
    return left + right;
  }
  return undefined;
}
```

### 声明式UI描述

这个使用和swift的`JKSwiftExtension`很像，就不多介绍

### button事件的绑定

```ts
Button('add counter')
  .onClick(() => {
    this.counter += 2;
  })

// 不使用箭头的方式,需要使用bind this。
myClickHandler(): void {
  this.counter += 2;
}
...
Button('add counter')
  .onClick(this.myClickHandler.bind(this))
// 使用箭头的方式,不需要使用bind this。
fn = () => {
  console.info(`counter: ${this.counter}`)
  this.counter++
}
...
Button('add counter')
  .onClick(this.fn)
```



### struct和class

见[文章](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs/faqs-arkui-284-V5)

struct只在自定义组件中使用@Component 装饰的struct 就是自定义组件，自定义组件和class是两个概念，自定义组件没有类型，也不能等同于class。

struct也就是主要用来表示UI组件的。不能有继承关系。

struct详细见[自定义组件](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-create-custom-components-V5)



### [生命周期](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-page-custom-components-lifecycle-V5)

区分entry和component的生命周期。

页面生命周期，即被@Entry装饰的组件生命周期，提供以下生命周期接口：

- [onPageShow](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#onpageshow)：页面每次显示时触发一次，包括路由过程、应用进入前台等场景。
- [onPageHide](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#onpagehide)：页面每次隐藏时触发一次，包括路由过程、应用进入后台等场景。
- [onBackPress](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#onbackpress)：当用户点击返回按钮时触发。

组件生命周期，即一般用@Component装饰的自定义组件的生命周期，提供以下生命周期接口：

- [aboutToAppear](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#abouttoappear)：组件即将出现时回调该接口，具体时机为在创建自定义组件的新实例后，在执行其build()函数之前执行。
- [onDidBuild](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#ondidbuild12)：组件build()函数执行完成之后回调该接口，不建议在onDidBuild函数中更改状态变量、使用animateTo等功能，这可能会导致不稳定的UI表现。
- [aboutToDisappear](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-custom-component-lifecycle-V5#abouttodisappear)：aboutToDisappear函数在自定义组件析构销毁之前执行。不允许在aboutToDisappear函数中改变状态变量，特别是@Link变量的修改可能会导致应用程序行为不稳定。



## 其他知识点

### build

[build函数见](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-create-custom-components-V5#build%E5%87%BD%E6%95%B0)

### 装饰器

装饰器实现原理要去看TS的内容，见[文章](https://www.typescriptlang.org/docs/handbook/decorators.html)

#### @component

@Component装饰器仅能装饰struct关键字声明的数据结构。struct被@Component装饰后具备组件化的能力，需要实现build方法描述UI，一个struct只能被一个@Component装饰。@Component可以接受一个可选的bool类型参数。@Component可以接受一个可选的bool类型参数。

#### @Entry

@Entry装饰的自定义组件将作为UI页面的入口。在单个UI页面中，最多可以使用@Entry装饰一个自定义组件。@Entry可以接受一个可选的[LocalStorage](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-localstorage-V5)的参数