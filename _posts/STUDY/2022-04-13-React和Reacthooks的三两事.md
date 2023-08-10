---
title:  "React和React hooks的三两事"
date:   2022-04-13
desc: "终端程序员的移动端开发没法避开去了解学习前端知识，随着前端框架的日积月累，已经将移动端技术远远的甩在了脑后，各厂使用的技术也都是跨端技术，业务代码大量的都是使用前端编码实现，其中react的hooks（useState、useEffect、useContext和useRef）就大量应用在跨端技术weex中，我们有必要了解下react和react hooks"
keywords: "React hooks, useState, useEffect, useContext, useRef"
categories: [Tech, Study]
tags: []



---

> 前端入门的上一篇可以看：[向恐龙解释现代JavaScript](https://ramboqiu.github.io/posts/%E5%89%8D%E7%AB%AF%E5%B0%8F%E7%99%BD%E5%85%A5%E9%97%A8-%E5%90%91%E6%81%90%E9%BE%99%E8%A7%A3%E9%87%8A%E7%8E%B0%E4%BB%A3JavaScript/)

在了解React hooks之前，我们有必要了解下React的基础支持。

React 是由 Facebook 开源的一个JS 库，采用声明式的JSX语法来描述界面元素，**高效且灵活**的用于构建用户界面的 JavaScript 库，并使用单项数据流来管理页面的状态。

2013年，React发布之初主要是开发Web页面；

2015年，Facebook推出了ReactNative，用于开发移动端跨平台；（虽然目前Flutter非常火爆，但是还是有很多公司在使用 ReactNative）；

2017年，Facebook推出ReactVR，用于开发虚拟现实Web应用程序；（随着5G的普及，VR也会是一个火爆的应用场景

## 1. React NPM包

开发 React 必须依赖这三个库:

- `react`: 包含 react 所必须的核心代码。包括JSX、类组件、函数组件、hooks、context、ref等在内的React特性，它定义了这些特性的语法细节和使用方式，但是不负责这些特性的具体实现
- `react-dom`: react渲染不同平台所需要的核心代码，是React渲染器的一种实现，负责在不同的宿主载体上实现各种React特性。react-dom主要负责实现的是浏览器中的React特性。react-native则是实现iOS和Android上的react特性
- `babel`: 将 jsx 转换成React代码工具，下面会讲到。

## 2. JSX

JSX：是 **J**ava**S**cript **X**ML的缩写。JSX 不是标准的 JS 语法，是React团队创造出来的 JS 的语法扩展，本质是一种语法糖。脚手架中内置了babel用来解析该语法,jsx创建元素最终会被被解析过成

```react
React.createElement('要创建的标签名', {id或类名}, '标签内容')
```

来看些例子，例子摘自[React官方文档](https://zh-hans.legacy.reactjs.org/docs/introducing-jsx.html)

```jsx
// 在 JSX 中嵌入表达式
const name = 'Josh Perez';
const element = <h1>Hello, {name}</h1>;

function formatName(user) {
  return user.firstName + ' ' + user.lastName;
}

const user = {
  firstName: 'Harper',
  lastName: 'Perez'
};

const element = (
  <h1>
    Hello, {formatName(user)}!
  </h1>
);

// JSX 也是一个表达式
function getGreeting(user) {
  if (user) {
    return <h1>Hello, {formatName(user)}!</h1>;
  }
  return <h1>Hello, Stranger.</h1>;
}

// JSX 中指定属性
const element = <a href="https://www.legacy.reactjs.org"> link </a>;
const element = <img src={user.avatarUrl}></img>;
// 假如一个标签里面没有内容，你可以使用 /> 来闭合标签，就像 XML 语法一样：
const element = <img src={user.avatarUrl} />;

// JSX 标签里能够包含很多子元素:
const element = (
  <div>
    <h1>Hello!</h1>
    <h2>Good to see you here.</h2>
  </div>
);

// JSX 防止注入攻击
const title = response.potentiallyMaliciousInput;
const element = <h1>{title}</h1>;// 直接使用是安全的：
```



### JSX 表示对象

JSX本质是一种语法糖，在前端开发的build阶段，Babel 会把 JSX 转译成一个名为 `React.createElement()` 函数调用。

以下两种示例代码完全等效：

```react
const element = (
  <h1 className="greeting">
    Hello, world!
  </h1>
);
```

```react
const element = React.createElement(
  'h1',
  {className: 'greeting'},
  'Hello, world!'
);
```

 `React.createElement()` 会预先执行一些检查，以帮助你编写无错代码，但实际上它创建了一个这样的对象：

```react
// 注意：这是简化过的结构
const element = {
  type: 'h1',
  props: {
    className: 'greeting',
    children: 'Hello, world!'
  }
};
```

这些对象被称为 “React 元素”。React 元素是构成React应用的最小砖块，它们描述了你希望在屏幕上看到的内容。React 通过读取这些对象，然后使用它们来构建 DOM 以及保持随时更新。

## 3. React是如何渲染元素的

使用ReactDOM渲染React元素时，**需要一个挂载节点，这个挂载节点需要事先在HTML文件中定义好**。

假设你的 HTML 文件某处有一个 `<div>`：

```react
<div id="root"></div>
```

我们将其称为“根” DOM 节点，因为该节点内的所有内容都将由 React DOM 管理。

仅使用 React 构建的应用通常只有单一的根 DOM 节点。如果你在将 React 集成进一个已有应用，那么你可以在应用中包含任意多的独立根 DOM 节点。

想要将一个 React 元素渲染到根 DOM 节点中，只需把它们一起传入 [`ReactDOM.createRoot()`](https://zh-hans.legacy.reactjs.org/docs/react-dom-client.html#createroot)：

```react
const root = ReactDOM.createRoot(
  document.getElementById('root')
);
const element = <h1>Hello, world</h1>;
root.render(element);
// 或是
ReactDOM.render(element, document.getElementById('root'));
```

### 更新已渲染的元素

React 元素是[不可变对象](https://en.wikipedia.org/wiki/Immutable_object)。一旦被创建，你就无法更改它的子元素或者属性。一个元素就像电影的单帧：它代表了某个特定时刻的 UI。

根据我们已有的知识，更新 UI 唯一的方式是创建一个全新的元素，并将其传入 `root.render()`。

考虑一个计时器的例子：



```react
const root = ReactDOM.createRoot(
  document.getElementById('root')
);

function tick() {
  const element = (
    <div>
      <h1>Hello, world!</h1>
      <h2>It is {new Date().toLocaleTimeString()}.</h2>
    </div>
  );
  root.render(element);}

setInterval(tick, 1000);
```

这个例子会在 [`setInterval()`](https://developer.mozilla.org/en-US/docs/Web/API/WindowTimers/setInterval) 回调函数，每秒都调用 [`root.render()`](https://zh-hans.legacy.reactjs.org/docs/react-dom.html#render)。

React 只更新它需要更新的部分。React DOM 会将元素和它的子元素与它们之前的状态进行比较，并只会进行必要的更新来使 DOM 达到预期的状态。

## 4. 组件&Props

通过JSX，可以将页面的渲染逻辑和其他UI逻辑（绑定事件处理器、状态变更、拉取数据等）封装到一个独立的单元中，我们称为“组件”。组件允许你将UI拆分成独立、可复用的代码片段，并对每个片段进行独立的构思。在概念上，组件类似JavaScript 函数，它接收唯一带有数据的 “props”参数（代表属性）对象与并返回一个 用于描述页面展示内容的React 元素。

### 定义组件

定义组件最简单的方式就是编写 JavaScript 函数：

```react
// 函数组件
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}
```

你同时还可以使用 [ES6 的 class](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Classes) 来定义组件：

```react
// 定义类组件时，需要继承React.Component
class Welcome extends React.Component {
  // 必须定义一个render()函数，并返回用于描述页面展示内容的React元素
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```

上述两个组件在 React 里是等效的。

> **注意：** **组件名称必须以大写字母开头。**
>
> React 会将以小写字母开头的组件视为原生 DOM 标签。例如，`<div />` 代表 HTML 的 div 标签，而 `<Welcome />` 则代表一个组件，并且需在作用域内使用 `Welcome`。

### 渲染组件

之前，我们遇到的 React 元素都只是 DOM 标签：

```react
const element = <div />;
```

不过，React 元素也可以是用户自定义的组件：

```react
const element = <Welcome name="Sara" />;
```

当 React 元素为用户自定义组件时，它会将 JSX 所接收的属性（attributes）以及子组件（children）转换为单个对象传递给组件，这个对象被称之为 “props”。

例如，这段代码会在页面上渲染 “Hello, Sara”：

```react
function Welcome(props) {  
  return <h1>Hello, {props.name}</h1>;
}

const root = ReactDOM.createRoot(document.getElementById('root'));
const element = <Welcome name="Sara" />;root.render(element);
```

让我们来回顾一下这个例子中发生了什么：

1. 我们调用 `root.render()` 函数，并传入 `<Welcome name="Sara" />` 作为参数。
2. React 调用 `Welcome` 组件，并将 `{name: 'Sara'}` 作为 props 传入。
3. `Welcome` 组件将 `<h1>Hello, Sara</h1>` 元素作为返回值。
4. React DOM 将 DOM 高效地更新为 `<h1>Hello, Sara</h1>`。

### Props 是只读性

组件无论是使用[函数声明还是通过 class 声明](https://zh-hans.legacy.reactjs.org/docs/components-and-props.html#function-and-class-components)，都绝不能修改自身的 props。来看下这个 `sum` 函数：

```react
function sum(a, b) {
  return a + b;
}
```

这样的函数被称为[“纯函数”](https://en.wikipedia.org/wiki/Pure_function)，因为该函数不会尝试更改入参，且多次调用下相同的入参始终返回相同的结果。

相反，下面这个函数则不是纯函数，因为它更改了自己的入参：

```react
function withdraw(account, amount) {
  account.total -= amount;
}
```

React 非常灵活，但它也有一个严格的规则：

**所有 React 组件都必须像纯函数一样保护它们的 props 不被更改。**

## 5. State和生命周期

上面我们介绍了props，并强调是不可变的。当组件内部需要存储一些随着时间变化的状态时，我们就需要向组件添加state。state和props都是用来存储组件的状态，单是state是私有的、可变的，且完全受控于当前组件的。

**只有类组件才支持State，State改变会触发组件的重新渲染，一般需要结合类组件的生命周期函数一起使用。**

### 向类组件添加state

```react
class Clock extends React.Component {
  constructor(props) {
    super(props);
    // 在类组件的构造器中初始化state，这里注意除了构造函数之外，其他所有地方都不允许对this.state进行直接赋值
    this.state = {date: new Date()};
  }

  componentDidMount() {
    // 在组件第一次被加载到页面上时，开始一个定时任务
    this.timerID = setInterval(
      () => this.tick(),
      1000
    );
  }

  componentWillUnmount() {
    // 在组件被销毁时，清除定时任务
    clearInterval(this.timerID);
  }

  tick() {    
    // 通过setState更新state
    this.setState({ date: new Date() });  
  }
  render() {
    return (
      <div>
        <h1>Hello, world!</h1>
        <!-- 从state中读取当前的时间 -->
        <h2>It is {this.state.date.toLocaleTimeString()}.</h2>
      </div>
    );
  }
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<Clock />);
```

### 正确地使用 State

关于 `setState()` 你应该了解三件事：

### 不要直接修改 State

例如，此代码不会重新渲染组件：

```react
// Wrong
this.state.comment = 'Hello';
```

而是应该使用 `setState()`:

```react
// Correct
this.setState({comment: 'Hello'});
```

构造函数是唯一可以给 `this.state` 赋值的地方。

### State 的更新可能是异步的

出于性能考虑，React 可能会把多个 `setState()` 调用合并成一个调用。

因为 `this.props` 和 `this.state` 可能会异步更新，所以你不要依赖他们的值来更新下一个状态。

例如，此代码可能会无法更新计数器：

```react
// Wrong
this.setState({
  counter: this.state.counter + this.props.increment,
});
```

要解决这个问题，可以让 `setState()` 接收一个函数而不是一个对象。这个函数用上一个 state 作为第一个参数，将此次更新被应用时的 props 做为第二个参数：

```react
// Correct
this.setState((state, props) => ({
  counter: state.counter + props.increment
}));
```

上面使用了[箭头函数](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions)，不过使用普通的函数也同样可以：

```react
// Correct
this.setState(function(state, props) {
  return {
    counter: state.counter + props.increment
  };
});
```

### State 的更新会被合并

当你调用 `setState()` 的时候，React 会把你提供的对象合并到当前的 state。

例如，你的 state 包含几个独立的变量：

```react
  constructor(props) {
    super(props);
    // state 包含两个独立的变量：
    this.state = {  posts: [], comments: [] };
  }
```

然后你可以分别调用 `setState()` 来单独地更新它们：

```react
  componentDidMount() {
    fetchPosts().then(response => {
      // 下面代码执行后会保留完整的this.state.comments，并将this.state.posts完全替换
      this.setState({ posts: response.posts });
    });

    fetchComments().then(response => {
      this.setState({ comments: response.comments });
    });
  }
```

这里的合并是浅合并，所以 `this.setState({comments})` 完整保留了 `this.state.posts`， 但是完全替换了 `this.state.comments`。

### 数据是单向的向下流动的

不管是父组件或是子组件都无法知道某个组件是有状态的还是无状态的，并且它们也并不关心它是函数组件还是 class 组件。

这就是为什么称 state 为局部的或是封装的的原因。除了拥有并设置了它的组件，其他组件都无法访问。

组件可以选择把它的 state 作为 props 向下传递到它的子组件中：

```react
<FormattedDate date={this.state.date} />

function FormattedDate(props) {
  return <h2>It is {props.date.toLocaleTimeString()}.</h2>;
}

class Parent extends React.Component {
  constructor(props) {
    super(props);
    this.state = { date: new Date() }
  }
  render() {
    // 父组件把自己的state座位props传递给子组件
    return <FormattedDate date={this.state.date} />
  }
}
```

这通常会被叫做“自上而下”或是“单向”的数据流。任何的 state 总是所属于特定的组件，而且从该 state 派生的任何数据或 UI 只能影响树中“低于”它们的组件。

## 6. 事件处理

React 元素的事件处理和 DOM 元素的很相似，但是有一点语法上的不同：

- React 事件的命名采用小驼峰式（camelCase），而不是纯小写。
- 使用 JSX 语法时你需要传入一个函数作为事件处理函数，而不是一个字符串。

例如，传统的 HTML：

```html
<button onclick="activateLasers()"> Activate Lasers </button>
```

在 React 中略微不同：

```react
<button onClick={activateLasers}>  Activate Lasers </button>
```

定义事件，我们的写法是这样的

```react
// 这样写是对的
handleClick = () => { console.log('this is:', this); };
// 这样写是错误的
handleClick() { console.log('this is:', this); }
```

` = () => `的写法是为我们做了`this`的绑定。

完整的写法如下：

```react
class LoggingButton extends React.Component {
   constructor(props) {
    super(props);
    // 为了在回调中使用 `this`，这个绑定是必不可少的
    this.handleClick = this.handleClick.bind(this);
  } 
  handleClick() { console.log('this is:', this);  };  
  render() {
    return (
      <button onClick={this.handleClick}>
        Click me
      </button>
    );
  }
}
```

使用解法之后

```react
class LoggingButton extends React.Component {
  // 此语法确保 `handleClick` 内的 `this` 已被绑定。 
  handleClick = () => { console.log('this is:', this); }; 
  render() {
    return (
      <button onClick={this.handleClick}>
        Click me
      </button>
    );
  }
}

class LoggingButton extends React.Component {
  handleClick() {
    console.log('this is:', this);
  }

  render() {
    // 此语法确保 `handleClick` 内的 `this` 已被绑定。
    return (
      <button onClick={() => this.handleClick()}>
        Click me
      </button>
    );
  }
}
```

## 7. 条件渲染

### if

```react
function UserGreeting(props) {
  return <h1>Welcome back!</h1>;
}

function GuestGreeting(props) {
  return <h1>Please sign up.</h1>;
}

function Greeting(props) {
  const isLoggedIn = props.isLoggedIn;
  // 可以使用条件语句if
  if (isLoggedIn) {
    return <UserGreeting />;
  }
  return <GuestGreeting />;
}

const root = ReactDOM.createRoot(document.getElementById('root')); 
// Try changing to isLoggedIn={true}:
root.render(<Greeting isLoggedIn={false} />);

```



### 变量

```react
function LoginButton(props) {
  return (
    <button onClick={props.onClick}>
      Login
    </button>
  );
}

function LogoutButton(props) {
  return (
    <button onClick={props.onClick}>
      Logout
    </button>
  );
}
class LoginControl extends React.Component {
  constructor(props) {
    super(props);
    this.handleLoginClick = this.handleLoginClick.bind(this);
    this.handleLogoutClick = this.handleLogoutClick.bind(this);
    this.state = {isLoggedIn: false};
  }

  handleLoginClick() {
    this.setState({isLoggedIn: true});
  }

  handleLogoutClick() {
    this.setState({isLoggedIn: false});
  }

  render() {
    const isLoggedIn = this.state.isLoggedIn;
    let button;
    // 它将根据当前的状态来渲染 <LoginButton /> 或者 <LogoutButton />。同时它还会渲染上一个示例中的 <Greeting />
    if (isLoggedIn) {
      button = <LogoutButton onClick={this.handleLogoutClick} />;
    } else {
      button = <LoginButton onClick={this.handleLoginClick} />;
    }

    return (
      <div>
        <Greeting isLoggedIn={isLoggedIn} />
        {button}
      </div>
    );
  }
}

const root = ReactDOM.createRoot(document.getElementById('root')); 
root.render(<LoginControl />);
```

### 与运算符 &&

之所以能这样做，是因为在 JavaScript 中，`true && expression` 总是会返回 `expression`, 而 `false && expression` 总是会返回 `false`。

因此，如果条件是 `true`，`&&` 右侧的元素就会被渲染，如果是 `false`，React 会忽略并跳过它。

```react
function Mailbox(props) {
  const unreadMessages = props.unreadMessages;
  return (
    <div>
      <h1>Hello!</h1>
      {unreadMessages.length > 0 &&
        <h2> You have {unreadMessages.length} unread messages. </h2>
      }
    </div>
  );
}

const messages = ['React', 'Re: React', 'Re:Re: React'];

const root = ReactDOM.createRoot(document.getElementById('root')); 
root.render(<Mailbox unreadMessages={messages} />);
```

请注意，[falsy 表达式](https://developer.mozilla.org/en-US/docs/Glossary/Falsy) 会使 `&&` 后面的元素被跳过，但会返回 falsy 表达式的值。在下面示例中，render 方法的返回值是 `<div>0</div>`。

```react
render() {
  const count = 0;  return (
    <div>
      {count && <h1>Messages: {count}</h1>}    </div>
  );
}
```

### 三目运算符 ?:

```react
render() {
  const isLoggedIn = this.state.isLoggedIn;
  return (
    <div>
      The user is <b>{isLoggedIn ? 'currently' : 'not'}</b> logged in.    </div>
  );
}
```



### 阻止组件渲染 return null

```react
function WarningBanner(props) {
  if (!props.warn) {    return null;  }
  return (
    <div className="warning">
      Warning!
    </div>
  );
}

class Page extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showWarning: true};
    this.handleToggleClick = this.handleToggleClick.bind(this);
  }

  handleToggleClick() {
    this.setState(state => ({
      showWarning: !state.showWarning
    }));
  }

  render() {
    return (
      <div>
        <WarningBanner warn={this.state.showWarning} />        <button onClick={this.handleToggleClick}>
          {this.state.showWarning ? 'Hide' : 'Show'}
        </button>
      </div>
    );
  }
}

const root = ReactDOM.createRoot(document.getElementById('root')); 
root.render(<Page />);
```

## 8. Hooks

以 `use` 开头的函数被称为 **Hook**。`useState` 是 React 提供的一个内置 Hook。你可以在 [React API 参考](https://zh-hans.react.dev/reference/react) 中找到其他内置的 Hook。你也可以通过组合现有的 Hook 来编写属于你自己的 Hook。

Hook 比普通函数更为严格。你只能在你的组件（或其他 Hook）的 **顶层** 调用 Hook。如果你想在一个条件或循环中使用 `useState`，请提取一个新的组件并在组件内部使用它。

### useState

```react
import { useState } from 'react';

export default function MyApp() {
  const [count, setCount] = useState(0);

  function handleClick() {
    setCount(count + 1);
  }

  return (
    <div>
      <h1>Counters that update together</h1>
      <MyButton count={count} onClick={handleClick} />
      <MyButton count={count} onClick={handleClick} />
    </div>
  );
}

function MyButton({ count, onClick }) {
  return (
    <button onClick={onClick}>
      Clicked {count} times
    </button>
  );
}
```

当你点击按钮时，`onClick` 处理程序会启动。每个按钮的 `onClick` prop 会被设置为 `MyApp` 内的 `handleClick` 函数，所以函数内的代码会被执行。该代码会调用 `setCount(count + 1)`，使得 state 变量 `count` 递增。新的 `count` 值会被作为 prop 传递给每个按钮，因此它们每次展示的都是最新的值。这被称为“状态提升”。通过向上移动 state，我们实现了在组件间共享它。

### useRef

seRef和useState可以说是一对孪生兄弟

需要注意的是useRef声明的变量,需要通过.current才能访问它的值(是不是跟vue3中的某个语法好像...).

我们同时使用ref,state声明变量,对他俩++并在页面展示对应值的变化(同时可以对比一下 与上面普通变量的区别)

在weex中，调用端上export出来给前端使用的方法就需要用到useRef，原来上就是调用到全局的函数，**具体可以看这篇文章**

```react
// 使用 react hooks
import { useState, useRef, useEffect } from 'react';

export default function Home() {
  // 用来调用前端方法的react useRef hook
  const testRef = useRef();

  const onRamboClick = () => {
    // 前端调用端上export出来的方法
    testRef.current.test({ param: 'value' });// native通过export暴露给前端调用的方法
  };

  return (
    <div className={styles.app} 
			// div的点击事件
			onClick={ () => { onRamboClick(); }
			}>
      <laoqiutest 
        src='from'
        ref={testRef} // 前端调用端上export出来的方法
      >自定义标签测试</laoqiutest>
    </div>
  );
}
```



### useEffect

你之前可能已经在 React 组件中执行过数据获取、订阅或者手动修改过 DOM。我们统一把这些操作称为“副作用”，或者简称为“作用”。

`useEffect` 就是一个 Effect Hook，给函数组件增加了操作副作用的能力。它跟 class 组件中的 `componentDidMount`、`componentDidUpdate` 和 `componentWillUnmount` 具有相同的用途，只不过被合并成了一个 API。（我们会在[使用 Effect Hook](https://zh-hans.legacy.reactjs.org/docs/hooks-effect.html) 里展示对比 `useEffect` 和这些方法的例子。）

```react
import React, { useState, useEffect } from 'react';
function Example() {
  const [count, setCount] = useState(0);

  // 相当于 componentDidMount 和 componentDidUpdate: 
  useEffect(() => {    
    // 使用浏览器的 API 更新页面标题   
    document.title = `You clicked ${count} times`; 
  });
  
  return (
    <div>
      <p>You clicked {count} times</p>
      <button onClick={() => setCount(count + 1)}>
        Click me
      </button>
    </div>
  );
}
```

总结如下

```react
useEffect(()=>{

//我会在页面初始化完成执行一次
//页面每更新一次我就会执行一次
})

useEffect(()=>{

//我只会在页面初始化完成执行一次
//和componentDidMount vue中 mounted 相似
},[])

useEffect(()=>{

//我会在页面初始化完成执行一次
//当a和b的值发生变化我也会执行一次
**a,b的值必须是props或者state,否择我不会执行**
},[a,b])

useEffect(()=>{

 return ()=>{
 //我在什么时候执行呢？
 }
},[a,b])
```





## 参考文章

[React官方中文文档](https://zh-hans.legacy.reactjs.org/docs/rendering-elements.html)

https://segmentfault.com/a/1190000012921279

https://juejin.cn/post/7098297316074848263



https://juejin.cn/post/7100161517273743390

