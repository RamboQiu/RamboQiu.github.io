---
title:  "MyTinySDL阅读之一：vscode运行调试"
date:   2021-02-24
desc: "STL（Standard Template Library,标准模板类）是C++语言内置的一个基础模板集合，包含了各种常用的存储数据的模板类及相应的操作函数。STL最初是由惠普实验室（Hewett-Packard Labs）开发，并与1998年被定为国际标准，正式成为C++语言的标准库。MyTinySDL自己简单的实现一套此标准库。"
keywords: "c"
categories: [Tech, Study]
tags: [c++,SDL]
---

## 如何优雅的使用vscode进行debug

下载最新的[MyTinySTL-Tutorial](https://github.com/RamboQiu/MyTinySTL-Tutorial)源码，我已经将.vscode文件夹上传了，配置好了可以进行调试，选中Test/test.cpp文件，然后点击运行tab里面的运行即可。

![screenshot-20210304-175148](/assets/img/study/screenshot-20210304-175148.png){: .normal}

详细教学文档见：[Using Clang in Visual Studio Code](https://code.visualstudio.com/docs/cpp/config-clang-mac)

tasks.json

```json
{
    "tasks": [
        {
            "type": "cppbuild",
            "label": "运行test.cpp",
            "command": "/usr/bin/clang++",
            "args": [
                "-std=c++11",
                "-stdlib=libc++",
                "-g",
                "${file}",
                "-o",
                "${fileDirname}/${fileBasenameNoExtension}"
            ],
            "options": {
                "cwd": "${workspaceFolder}"
            },
            "problemMatcher": [
                "$gcc"
            ],
            "group": "build",
            "detail": "调试器生成的任务。"
        }
    ],
    "version": "2.0.0"
}
```

Launch.json

```json
{
    // 使用 IntelliSense 了解相关属性。 
    // 悬停以查看现有属性的描述。
    // 欲了解更多信息，请访问: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(lldb) 启动",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "运行test.cpp"
        }
    ]
}
```

