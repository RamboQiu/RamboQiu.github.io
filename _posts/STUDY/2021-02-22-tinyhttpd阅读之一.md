---
title:  "tinyhttpd阅读之一"
date:   2021-02-22
desc: "tinyhttpd 是一个简易的 http 服务器，支持CGI。代码量少，非常容易阅读，十分适合网络编程初学者学习的项目。"
keywords: "c"
categories: [Tech, Study]
tags: [c,tinyhttpd]
---

## 介绍

github上搜tinyhttpd，靠前的就两个项目：[EZLippi-Tinyhttpd](https://github.com/EZLippi/Tinyhttpd) 、 [cbsheng-tinyhttpd](https://github.com/cbsheng/tinyhttpd)

我这里就是下载了第二个cbsheng的，因为他注释比较多，哈哈。

该项目很适合初学者进行学习研究，所以废话不多说，把项目clone下来，进行debug吧。[RamboQiu](https://github.com/RamboQiu)/**[tinyhttpd-Tutorial](https://github.com/RamboQiu/tinyhttpd-Tutorial)**

##先把程序跑起来

```shell
tinyhttpd-Tutorial|master⚡ ⇒ make
tinyhttpd-Tutorial|master⚡ ⇒ ./httpd
httpd running on port 49535
```

![index](/assets/img/study/screenshot-20210223-103437.png){: .normal}

输入blue颜色，点击提交，噶，一片空白，原因是mac系统的perl命令的文件路径错了。

进入color.cgi将/usr/local/bin/perl 改为/usr/bin/perl即可

```diff
-#!/usr/local/bin/perl -Tw
+#!/usr/bin/perl -Tw
```

重新编译运行

![WechatIMG98](/assets/img/study/WechatIMG98.png){: .normal}

## Debug

c项目头疼的就是没有直观的像是xcode一样的直接debug的能力，需要自己去集成。

项目源码猜测的是使用lldb或事gdb的形式进行调试的，因为没有看到.vscode或是cmakefile。这几种调试方式区别具体见：[从开源项目重学C语言-vscode配置](https://ramboqiu.github.io/posts/%E4%BB%8E%E5%BC%80%E6%BA%90%E9%A1%B9%E7%9B%AE%E9%87%8D%E5%AD%A6C%E8%AF%AD%E8%A8%80-vscode%E9%85%8D%E7%BD%AE/)

>  引用：建议源码阅读顺序： main -> startup -> accept_request -> execute_cgi, 通晓主要工作流程后再仔细把每个函数的源码看一看。

![screenshot-20210222-162445](/assets/img/study/screenshot-20210222-162445.png){: .normal}



## 相关配合资源下载

tlpi全称The Linux Program Interface，有中英文书籍，见[百度网盘](https://pan.baidu.com/s/1SFgcmrcai3BhtRcc27z0dA) 密码: 24qj

