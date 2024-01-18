---
title:  "github连接不上无法clone代码"
date:   2024-01-18
desc: "unable to access 'https://github.com/danielgindi/: Failed to connect to github.com port 443 after 75032 ms: Couldn't connect to server"
categories: [Tech, Study]
tags: [github]


---

## 问题

`pod install`的时候经常碰到某个三方库没法clone下来，但是自己浏览器又是能够打开

```
unable to access 'https://github.com/danielgindi/.git/': Failed to connect to github.com port 443 after 75032 ms: Couldn't connect to server
```

## 解决方式

查找网上，[找到设置的代理的方式解决](https://blog.csdn.net/zpf1813763637/article/details/128340109)

我自己电脑是有进行科学上网的，所以，找到自己本地的代码的端口

![image-20240118192726546](/assets/img/study/2024-01-18-github连接不上无法clone代码.assets/image-20240118192726546.png)

```
➜ git config --global https.proxy 127.0.0.1:17890
➜ git config --global http.proxy 127.0.0.1:17890
```



重新`pod install`，问题解决

查看代理命令

```
git config --global --get http.proxy
git config --global --get https.proxy
```

取消代理命令

```
git config --global --unset http.proxy
git config --global --unset https.proxy
```



