---
title:  "客户端熟悉前端入门：向恐龙解释现代JavaScript"
date:   2022-02-10
desc: "我的JavaScript的理论知识还是停留在大学时期学过的东西，现在接触的前端各种import，自动bulid啥的，已经发展的同移动端那么相似且更强了，通过这篇文章可以很好的熟悉现代JavaScript是如何演变过来的，翻译至Modern JavaScript Explained For Dinosaurs"
keywords: "前端, JavaScript"
categories: [Tech, Study]
tags: []
---

> 摘录并改进至文章 https://www.cnblogs.com/importsober/p/15357772.html

![20220210-1](/assets/img/study/20220210-1.png){: .normal}

## JavaScript的演进

### 第一步 手动下载并更新本地的JavaScript库

我们从一个老派的例子开始讲解，这里用到了一个三方库

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Example</title>
  <link rel="stylesheet" href="index.css">
  <script src="moment.min.js"></script>// 三方库
  <script src="index.js"></script>// 自己的库
</head>
<body>
  <h1>Hello from HTML!</h1>
</body>
</html>
```

这行`<script src="index.js"></script>`指向的是同一个目录下名为index.js的单独的一个JavaScript文件:

```javascript
// index.js
console.log("Hello from JavaScript!");
// 使用三方库能力，其中moment是三方库里面的一个全局变量，这样可以供我们使用
console.log(moment().startOf('day').fromNow());
```

用到moment这个库，那我们去要去他的官网下载资源包，如下图

![20220210-1](/assets/img/study/20220210-2.png){: .normal}

我们下载moment.min.js文件并将其放在index.html文件中，从而将moment.js添加到我们的网站中。

这就是我们以前用JavaScript的库制作网站的方法！

**好的地方是它很容易理解。**

**不好的地方是，每次库有更新时都我们要找到并下载新版本的库，替换旧文件，这很烦人。**



### 第二步 使用JavaScript的包管理器NPM

> 这个有点像移动端的pod管理器

大约从2010年开始，出现了几个相互竞争的JavaScript包管理器，它们可以帮我们从中央存储库自动下载和升级JavaScript库。Bower可以说是2013年最受欢迎的包管理器，但逐渐在2015年左右被npm超越。(值得注意的是，从2016年年底开始，yarn作为npm方式的替代品获得了很多关注，但它在内部仍然使用npm包。)

注意，npm最初是专门为node.js设计的包管理器，node.js是一个JavaScript运行时环境，运行在服务器，而不是前端。因此，很多人会困惑，为什么要用npm来管理运行在浏览器中的前端JavaScript库。

我们使用命令`npm init`会在文件目录下面生成一个`package.json`，这是npm用来保存所有项目信息的配置文件。

```json
{
  "name": "your-project-name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
```

使用`npm install moment --save`安装`moment.js`这个库

这条命令做两件事——首先，它将`moment.js`包中的所有代码下载到一个名为`node_modules`的文件夹中。其次，它会自动修改`package.json`文件以跟踪`moment.js`，使其作为项目依赖项。

```json
{
  "name": "modern-javascript-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.22.2"
  }
}
```

这样将项目共享给其他人就只需要`package.json`这个文件了，而不需要`node_modules`这个文件夹了，这个文件夹会有各方库会比较大，这和我们在github上下载的前端工程之后首先要执行`npm install`是一个道理。

这样之后我们的html就变成了

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>JavaScript Example</title>
  <script src="node_modules/moment/min/moment.min.js"></script>
  <script src="index.js"></script>
</head>
<body>
  <h1>Hello from HTML!</h1>
</body>
</html>
```

**所以这样做的好处是，现在我们可以使用npm通过命令行下载和更新我们的包。**

**不好的一点是，我们必须进入node_modules文件夹，找到每个包的位置，并手动将其包含在HTML中。**

![20220210-1](/assets/img/study/20220210-3.png){: .normal}

### 第三步 使用JavaScript模块绑定器（webpack）

大多数编程语言都提供了一种将代码从一个文件导入到另一个文件的方法。JavaScript最初并没有设计这个特性，因为JavaScript被设计为只能在浏览器中运行，不能访问客户端计算机的文件系统(出于安全原因)。因此，在很长一段时间里，将JavaScript代码组织到多个文件中需要使用全局共享的变量来加载每个文件。

这实际上就是我们在上面的`moment.js`例子中所做的——整个`moment.min.js`文件被加载在HTML中，它**定义了一个全局变量moment**，然后它对在`moment.min.js`之后加载的任何文件都可用(不管这些文件是否需要访问它)。

2009年，一个名为CommonJS的项目开始了，其目标是为浏览器之外的JavaScript指定一个生态系统。CommonJS对JacaScript做了模块规范，这使得JavaScript能像大多数编程语言一样跨文件导入和导出代码，而不需要求助于全局变量。node.js就是CommonJS模块规范最广为人知的实现。

```javascript
// index.js
var moment = require('moment');
console.log("Hello from JavaScript!");
console.log(moment().startOf('day').fromNow());
```

这就是node.js中模块加载的方法，因为node.js是一种服务器端语言，它可以访问计算机的文件系统。Node.js还知道每个npm模块的路径，所以不必写require('./node_modules/moment/min/moment.min.js')，你可以简单地写require('moment')。

但是直接运行会报错`require`没有定义。**浏览器不能访问文件系统，这意味着以这种方式加载模块是非常难的——加载文件必须动态完成，要么同步加载(会减慢执行速度)，要么异步加载(会有时间问题)。**

为了解决这个问题**模块绑定器**出现了。

**JavaScript模块绑定器是一种工具，它通过build(构建)步骤(这一步运行在本地，因此可以访问文件系统)来解决问题，并创建与浏览器兼容的打包好的JavaScript文件(不需要访问文件系统)。在这种情况下，我们就需要一个模块绑定器来查找所有require语句(require语法在浏览器中不支持)，并将它们替换为每个所需文件的实际内容。最终的结果是一个捆绑的JavaScript文件(没有require语句)!**

`npm install webpack webpack-cli --save-dev`安装webpack 

```json
{
  "name": "modern-javascript-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.19.1"
  },
  "devDependencies": {
    "webpack": "^4.17.1",
    "webpack-cli": "^3.1.0"
  }
}
```

这样我们就可以使用命令，将开发文件index.js，打包成我们需要的产物解读了require的main.js文件

`$ ./node_modules/.bin/webpack index.js --mode=development`

最后html就变成了

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>JavaScript Example</title>
  <script src="dist/main.js"></script>
</head>
<body>
  <h1>Hello from HTML!</h1>
</body>
</html
```

再通过添加Webpack的配置文件`webpack.config.js`

```javascript
// webpack.config.js
module.exports = {
  mode: 'development',
  entry: './index.js',
  output: {
    filename: 'main.js',
    publicPath: 'dist'
  }
};
```

每次修改index.js文件之后只需要执行命令`$ ./node_modules/.bin/webpack`即可

现在看来，我们费这么大劲使用了webpack，感觉工作效率并没有提升太多。但这个工作流程还有一些巨大的优势。

**优点：我们不再通过全局变量加载外部脚本。任何新的JavaScript库都将使用JavaScript中的require语句添加，而不是在HTML中添加新的<script>标签。使用单个打包好的JavaScript文件通常也更有利于性能。**

还能做的：通过build能力添加更强大的功能已经自动化的热重载能力。

![20220210-1](/assets/img/study/20220210-4.png){: .normal}

### 第四步 使用转译器，引入新的语言特性

举个例子，我们现在使用的是ES2015规范编写代码，但是需要运行在不支持ES2015的低版本浏览器上，怎么办，就需要使用到转义器，将代码的新特性向低版本进行转义，比如使用Babel。

`$ npm install @babel/core @babel/preset-env babel-loader --save-dev`

然后在配置下webpack使用Babel

```javascript
// webpack.config.js
module.exports = {
  mode: 'development',
  entry: './index.js',
  output: {
    filename: 'main.js',
    publicPath: 'dist'
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  }
};
```

这样之后可以开始用JavaScript编写ES2015特性了

```javascript
// index.js
var moment = require('moment');
console.log("Hello from JavaScript!");
console.log(moment().startOf('day').fromNow());
var name = "Bob", time = "today";
// ES2015的新特性
console.log(`Hello ${name}, how are you ${time}?`);
```

再次运行webpack之后`$ ./node_modules/.bin/webpack`,打包生成的`main.js`文件

```javascript
// main.js
// ...已经被转义
console.log('Hello ' + name + ', how are you ' + time + '?');
// ...
```

**做到这，我们还能做的改进就是，去掉每次修改文件之后还需要运行webpack的的命令，做到热重载**

### 第五步 使用task runner来自动化运行各个构建步骤

新增压缩js代码的能力，新增监听代码改动的能力并自动执行webpack的能力，新增自动开启一个server运行功能的能力

```json
{
  "name": "modern-javascript-example",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    // 通过这个命令，webpack 会输出压缩后的js代码
    "build": "webpack --progress --mode=production",
    // 通过这个命令，webpack可以监测文件改动，并自动执行webpack命令
    "watch": "webpack --progress --watch",
    // 运行webpack-dev-server的npm脚本，自动启动一个服务并且在浏览器中打开一个页面使用 http://localhost:8080/的方式能够访问页面
    "server": "webpack-dev-server --open"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "moment": "^2.22.2"
  },
  "devDependencies": {
    "@babel/core": "^7.0.0",
    "@babel/preset-env": "^7.0.0",
    "babel-loader": "^8.0.2",
    "webpack": "^4.17.1",
    "webpack-cli": "^3.1.0"
  }
}
```

然后你可以使用以下脚本来运行你的开发环境代码：

`npm run server`或是`npm run start`



## 总结

简而言之，这就是现代JavaScript开发的工作流程！。我们从普通的HTML和JavaScript过渡到使用包管理器来自动下载第三方包，使用模块绑定器来创建单个脚本文件，使用转译器来使用未来的JavaScript特性，以及使用任务运行器来自动化构建过程。对初学者来说这是一种很大的转变。Web开发曾经是编程新手的一个很好的入门点，因为它非常容易启动和运行。但如今，它可能有点令人生畏，特别是因为各种工具往往会快速变化。

不过，这并不像看上去的那么糟糕。这些问题都在一步一步得以解决，特别是采用node.js生态系统作为前端工作开发这种方法。使用npm作为包管理器、node的require或import这些模块语句以及用于运行任务运行的npm脚本非常棒，它带来了一致性。与前几年前相比，这是一个大大简化了的工作流程!

对于初学者和有经验的开发人员来说，现在的框架通常会附带工具，能让开发过程更容易，这点更好！Ember有Ember-cli，它引领出Angular的Angular-cli、React的create-react-app、Vue的vue-cli等。所有这些工具都可以将您所需要的提前设置好-您所需要做的就是开始编写代码。然而，这些工具其实并没有什么神奇之处，它们只是把一切都统一化了——不过你可能经常需要对webpack、babel等做一些额外的配置。因此，正如我们在本文中所介绍的那样，理解每一部分的作用仍然非常重要。

使用现代JavaScript开发流程一开始肯定会令人沮丧，因为它不停的在快速变化。仅管有时好像是在重复造轮子，JavaScript的快速发展已经推动了诸如热加载、实时检测和时间旅行调试(time-travel debugging)等创新。对于开发人员来说，这是一个激动人心的时刻！我希望这些信息可以作为路线图，帮助您踏上征程!



![20220210-1](/assets/img/study/20220210-5.png){: .normal}