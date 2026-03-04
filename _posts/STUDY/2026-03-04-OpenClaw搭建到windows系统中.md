---
title:  "OpenClaw搭建到windows系统中"
date:   2026-03-04
desc: "AI Agent，不使用就要落后。记录下部署到windows系统上的操作情况。"
categories: [Tech, Study]
tags: [OpenClaw, AI]




---

## 官方安装

[Windows安装](https://docs.openclaw.ai/install#windows-powershell)

使用命令

```shell
iwr -useb https://openclaw.ai/install.ps1 | iex
```

会碰到各种报错，需要安装nodejs，需要安装git。我当前电脑已经安装的nodejs，但是没有安装git

**官方下载（推荐）**：前往 [git-scm.com](https://git-scm.com/download/win) 下载 64-bit Git for Windows Setup。

安装完git之后，运行上面的命令。

## 报错1

```
node.exe : npm error code ENOENT
所在位置 行: 1 字符: 1
+ & "C:\Program Files\nodejs/node.exe" "C:\Program Files\nodejs/node_mo ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo : NotSpecified: (npm error code ENOENT: String) [], RemoteException
+ FullyQualifiedErrorId : NativeCommandError
```

解决方案，手动执行：`npm install -g openclaw@latest`



## 报错2

```
[*] Installing OpenClaw (openclaw@latest)...
node.exe : npm error code 3221225477
所在位置 行:1 字符: 1
+ & "C:\Program Files\nodejs/node.exe" "C:\Program Files\nodejs/node_mo ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (npm error code 3221225477:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
```

### 彻底禁用 GPU 检测（最快解决）

在 PowerShell 中执行下面这行命令。这会告诉安装程序：**“不要去碰我的显卡，直接用 CPU 模式安装。”**

PowerShell

```
$env:NODE_LLAMA_CPP_SKIP_DOWNLOAD="true"; $env:NODE_LLAMA_CPP_GPU="none"; npm install -g openclaw@latest
```

> **注意：** `openclaw` 运行 AI 模型时，CPU 模式虽然比 GPU 慢一些，但对于大多数轻量化模型来说是完全可以运行的，而且最稳定。



尝试过一下两步并不行

```
第一步：更新 Intel 驱动（最稳妥）

1. 在设备管理器中右键点击 **Intel(R) UHD Graphics 730**。
2. 选择“更新驱动程序” -> “自动搜索驱动程序”。
3. 或者去 Intel 官网下载最新的 [Intel Graphics Driver](https://www.intel.cn/content/www/cn/zh/download-center/home.html)。

第二步：设置“高性能”模式（不禁用也能生效）

你不需要禁用核显，只需强制 Node.js 使用独显：

1. 打开 Windows **设置** -> **系统** -> **屏幕** -> **图形**。
2. 点击“浏览”，找到你的 `node.exe`（通常在 `C:\Program Files\nodejs\node.exe`）。
3. 添加后点击“选项”，选择**“高性能”**（对应你的 AMD RX 640）。
```

### 最后

重新执行`iwr -useb https://openclaw.ai/install.ps1 | iex` 运行成功

然后按官方的节奏走，见[链接](https://docs.openclaw.ai/start/getting-started)

2. Run the onboarding wizard

```
openclaw onboard --install-daemon
```

The wizard configures auth, gateway settings, and optional channels. See [Onboarding Wizard](https://docs.openclaw.ai/start/wizard) for details.

3. Check the Gateway

If you installed the service, it should already be running:

```
openclaw gateway status
```

4. Open the Control UI

```
openclaw dashboard
```



## 绑定到飞书

https://docs.openclaw.ai/channels/feishu