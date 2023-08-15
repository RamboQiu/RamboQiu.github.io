---
title:  "接入EMAS解决TBJSONModel冲突的问题"
date:   2023-07-19
desc: "IMS物联网库，IMSThingCapability和IMSDeviceCenter依赖的AKTBJSONModel，同EMAS相关的三大功能，奔溃分析，性能分析，远程日志中依赖的TBJSONModel存在静态资源冲突的问题，利用取巧的方式，修改目标冲突的podspec，来达到避免问题的解决方案。"
keywords: "pod、IMS、EMAS"
categories: [Tech, Study]
tags: []

---

## **EMAS接入**

集成阿里云平台在很大程度上能够完成项目上的一站式需求能力，可以节省大量的人力成本去自研





## AKTBJSONModel依赖**问题描述**

接入EMAS三大功能，奔溃分析，性能分析，远程日志

![EMAS功能](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/3ad73333-774a-46e5-8fba-07b26b416fb1-20230815195946530.png){: .normal}

Podfile分别引入的SDK的为AlicloudCrash、AlicloudAPM、AlicloudTLog，再三个库都依赖了TBJSONModel.framework二进制资源包。

但是IMS物联网库，IMSThingCapability和IMSDeviceCenter依赖的AKTBJSONModel其实就是TBJSONModel，如下图：

![冲突的依赖的Podfile.lock文件](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/1b7b1e2b-f172-450d-958d-217b5ae8837a.jpg){: .normal}

![错误的静态资源](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/c56e9029-cbec-4d7c-b878-ecf3570ed9ac.jpg){: .normal}

导致在pod install的时候碰到二进制资源冲突的问题，如下图：

![pod install报错](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/8b9b4791-2e11-43c0-95c3-167b1157832d.png){: .normal}

反馈给阿里云同学，IMS物联网同学给出的修复结论：

1. 他们内部已经在推送修改，但是涉及50多个库，还有修改完官方文档的更新，明确的修复完成时间没有确定。
2. 尝试将对应版本的IMS两个库的静态资源下载，进行本地集成。

## **解决方案**

### **修改IMS相关依赖的AKTBJSONModel**

从Podfile.lock文件中知道，仅需修改两个库IMSThingCapability和IMSDeviceCenter两个库

pod install原理，为查找aliyun-aliyun-specs文件夹中对应版本资源，如：

pod IMSThingCapability, '1.9.0'

查找的是~/.cocoapods/repos/aliyun-aliyun-specs/Specs/IMSThingCapability/1.9.0

![~/.cocoapods/repos/aliyun-aliyun-specs/Specs/IMSThingCapability/1.9.0](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/87043bd54c3b4ec2975b3f088df9cb420019.png){: .normal}

翻看此podspec

![IMSThingCapability.podspec](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/f0514cf422484674a90b9f92332409000019.png){: .normal}



### **修改EMAS相关依赖的TBJSONModel**

修改涉及四个库AliHACore、AliHAProtocol、RemoteDebugChannel、TRemoteDebugger四个库

```
- AliHACore (10.0.3.6):
    - AliHALogEngine (>= 10.0.2)
    - AliHAProtocol (>= 10.0.2.1)
    - TBJSONModel
    - TBRest (>= 1.0.0.18)


- AliHAProtocol (10.0.3):
    - TBJSONModel


- RemoteDebugChannel (10.0.4.5):
    - AliHAProtocol (>= 10.0.0.3)
    - AliHASecurity
    - AliyunOSSiOS
    - TBJSONModel
    - TBRest (>= 1.0.0.18)
    - ZipArchive

- TRemoteDebugger (10.0.6.6):
    - AliHALogEngine (>= 10.0.6)
    - AliHAMethodTrace (>= 1.0.1.2)
    - AliHAProtocol (>= 10.0.0.5)
    - AliHASecurity (>= 10.0.4)
    - AliRemoteDebugInterface (>= 0.0.1.2)
    - TBJSONModel
    - TBRest (>= 1.0.0.18)
```

操作也是同上面提到的IMS那样，找到对应版本的库，进行如下操作，并解决编译问题



### **开始手动安装**

#### **IMS**

##### **IMS下载资源**

查找到需要安装的版本的podspec，将其copy下来，放到本地库中，并做修改：

1. 修改AKJSONModel为 s.dependency 'TBJSONModel', '~> 0.1.15'
2. 下载s.source指向的资源，实际就是s.vendored_frameworks和s.resources

![IMSThingCapability.podspec](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/22fb5c799c634b4e97e883eab6e602e20019.png){: .normal}

最后文件结构如下：

![最终文件结构](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/a2cc60d5243c46a09da2143ea40babc40019.png){: .normal}

再重复操作IMSDeviceCenter，并上传远程仓库。

将源指向本地资源或是codeup仓库

pod install

**编译执行，测试配网流程，无问题**

#### **EMAS**

##### **EMAS下载资源和本地集成**

资源详细见 https://github.com/RamboQiu/EMAS

本地集成如下：

上面为依赖了TBJSONModel的库，需要改成AKTBJSONModel

下面的为奔溃分析、APM和远程日志SDK

![EMAS相关依赖](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/2f68d78506a94392bd48a3394c3ee96e0019.png)

### **替代方案**

1. 崩溃分析目前集成有腾讯的Bugly，纯在有部分崩溃捕捉不到的情况，尝试使用Facebook的Fabric。
2. APM性能监控相关，尝试使用友盟埋点进行，无大盘。
3. 远程日志，使用push能力制作静默推送用户出发上报SLS。

## **主要问题和收益**

### **问题**

IMS版本大概一个月一个版本，后续如果物联网那边一直没有解决此问题，IMS SDK的更新需要从原有的直接修改podfile的版本，改成如上述方案的方式进行更新。

**从原自动方式，变成手动方式，容易发生在人为操作的手动失误上引起的问题。**

替代方案中，目前就崩溃分析Fabric相对成熟，有大盘可看，另外能力缺乏较大。

### **收益**

EMAS能力两端统一使用，对于管理更方便。

EMAS的平台型能力更强，对于数据正好的平台可视化做的较完善。

IMS那边已经在推进改动，后续改造完成，可以做平滑迁移。



## **EMAS接入进展**

8.1 完成接入

### **奔溃分析**

![img](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/b5b625b7143d488b86633252f16fb4550019.png)

### **性能分析**

![img](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/b4cd7939d72b4c87b778fb8c1f400a890019.png)

### **远程日志**

![img](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/7de59de1b4c94098bdf7af7134dfdf540019.png)

![img](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/12764f5d498d4e598ca8de92d319ad2b0019.png)







## **其他**

1. 接入AlicloudCrash奔溃分析，会碰到FBRetainCycleDetector的问题，按官方提供方案进行解决https://help.aliyun.com/document_detail/448230.html

2. RemoteDebugProtocol.h头文件引入了其他module的头文件#import <TBJSONModel/TBJSONModel.h>导致的问题

![img](/assets/img/study/2023-07-19-接入EMAS解决TBJSONModel冲突的问题.assets/4b047b23ca8e40119ff2da479183bbb50019.png)

https://stackoverflow.com/questions/27776497/include-of-non-modular-header-inside-framework-module

