---
title: 关于JS函数的bind方法
date: 2016-03-24 17:09:05
---

昨天被人问到js的bind的作用是什么？

这个倒还能回答出来，bind 之后返回一个新的函数，这个函数可以保持传递的this上下文。

接着又问了，那么bind两次不同的上下文会怎样？

这个一下子就蒙了，因为平时也没这么用过，于是开始查一下资料。

首先在浏览器中测试一下。
```js
function test(){
  console.log(this.a)
}
var bind1 = test.bind({a:1}) //第一次 bind
var bind2 = bind1.bind({a:2}) // 第二次 bind
bind1()
bind2()
```
结果如下
```
1
1
```

可以看到第二次bind并没有能再改变this的值。

查一下MDN，[Function.prototype.bind()](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind) , 并没有解释bind两次会怎样。 但是他提供了一个Polyfill，可以了解下bind的实现。

```js
if (!Function.prototype.bind) {
  Function.prototype.bind = function(oThis) {
    if (typeof this !== 'function') {
      // closest thing possible to the ECMAScript 5
      // internal IsCallable function
      throw new TypeError('Function.prototype.bind - what is trying to be bound is not callable');
    }

    var aArgs   = Array.prototype.slice.call(arguments, 1),
        fToBind = this,
        fNOP    = function() {},
        fBound  = function() {
          return fToBind.apply(this instanceof fNOP
                 ? this
                 : oThis,
                 aArgs.concat(Array.prototype.slice.call(arguments)));
        };

    if (this.prototype) {
      // Function.prototype doesn't have a prototype property
      fNOP.prototype = this.prototype;
    }
    fBound.prototype = new fNOP();

    return fBound;
  };
}
```

可以看到MDN提供的polyfill的实现是`oThis`做为参数传进来，返回一个新的函数，这个时候函数是个闭包，仍然可以访问`oThis`变量，然后调用call/apply来实现指定的上下文。 这种情况下，如果bind两次，相当于闭包套闭包，不管套几层，值都是第一次保存的`this`值。 即上面polyfill的 `oThis` 变量。

光看polyfill是不够了，因为并不知道polyfill实现是不是标准。所以还是要看下规范。这里我们参考下 [ES2015文档](http://www.ecma-international.org/ecma-262/6.0/#sec-function.prototype.bind)


可以直接看到 19.2.3.2 节 NOTE 2，`If Target is an arrow function or a bound function then the thisArg passed to this method will not be used by subsequent calls to F.` 如果调用bind的是一个箭头函数或者是已经bind过的函数(bound function)，那么再次bind是不会起作用的。 可以看到规范已经定义了这样的行为产生的结果，我们可以直接记住这个结论。

但是这里值得注意的是，我们看到规范定义的bind操作 和  MDN 上提供的polyfill并不一致。polyfill没有完全实现ES2015规定的bind。

比如ES2015 规定了 bound function 的length 和 name 行为。

```
Let targetHasLength be HasOwnProperty(Target, "length").
ReturnIfAbrupt(targetHasLength).
If targetHasLength is true, then
  Let targetLen be Get(Target, "length").
  ReturnIfAbrupt(targetLen).
  If Type(targetLen) is not Number, let L be 0.
  Else,
    Let targetLen be ToInteger(targetLen).
      Let L be the larger of 0 and the result of targetLen minus the number of elements of args.
Else let L be 0.
```

这里会规定bound function 的 length 属性，应该和bind之前的length一致。

再看name 的行为

```
Let targetName be Get(Target, "name").
ReturnIfAbrupt(targetName).
If Type(targetName) is not String, let targetName be the empty string.
Perform SetFunctionName(F, targetName, "bound").
```

这里规定bound function 的name 应该走 [SetFunctionName](http://www.ecma-international.org/ecma-262/6.0/#sec-setfunctionname) 方法，而这里SetFunctionName之后的返回值应该是 bound字符串 + 空格 + 原先函数的name

```
......忽略了一些描述
prefix即bound 字符串
If prefix was passed, then
  Let name be the concatenation of prefix, code unit 0x0020 (SPACE), and name.
```

即
```js
function a(){}
var b = a.bind()
console.log(b.name)
```

结果应该是
```
bound a
```

而 MDN 的 `polyfill` 是没有实现这些细节的，所以用的时候如果依赖于这些，是要注意的。