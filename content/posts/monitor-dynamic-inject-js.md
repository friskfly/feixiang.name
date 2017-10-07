---
title: 监控动态创建的script标签
date: 2016-04-12 17:36:55
tags:
---
动态创建script标签很常用，比如jsonp、amd 等等技术都会用到， 有时候我们会希望能够监控和拦截动态创建的script标签。
下面提供了一种代理document.createElement的方法来监控。

```js
var _createElement = document.createElement
var __define_src = function(script){
  var src
  Object.defineProperty(script,'src',{
    get : function(){
      return src
    },
    set : function(s){
      src = s
      script.setAttribute('src',s)
    }
  })

  var _setAttribute = script.setAttribute
  script.setAttribute = function(){
    var args = Array.prototype.slice.call(arguments)
    if(args[0] === 'src'){
      //do something here
      console.log('setAttribute',args[1])
    }
    _setAttribute.apply(script,args)
  }
}

document.createElement = function(tagName){
  var dom
  dom = _createElement.call(document,tagName)
  if(tagName.toLowerCase() === 'script'){
    __define_src(dom)
  }
  return dom
}

```

上面的代码加载完后，就可以监控到 script.src 或者 script.setAttribute 两种方式加载的JS了

```js
var script = document.createElement('script')
script.src = 'http://s11.cnzz.com/z_stat.php?id=1256295486&web_id=1256295486'
script.setAttribute('src','https://s11.cnzz.com/z_stat.php?id=1256295486&web_id=1256295486')
```
