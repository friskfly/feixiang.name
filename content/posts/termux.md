---
title: "玩一玩Termux"
date: 2017-11-12T09:22:36+08:00
---

Termux是一款Android上的Linux环境终端模拟器，可以在上面安装各种linux 命令行软件 python、golang、nodejs...
[项目github主页](https://github.com/termux)

安装app后，首先安装 openssh,  `pkg install openssh` 搭建ssh服务。 [https://termux.com/ssh.html](https://termux.com/ssh.html), 安装完之后执行 `sshd` 即可启动一个ssh server, 默认端口 `8022`，就下来就可以用电脑ssh连接手机了。 Termux sshd 不支持密码登录，所以得把你的PC上的id_rsa.pub 写入到 Termux的 ~/.ssh/authorized_keys 中，如果没有的话用 ssh-keygen 生成一个。 复制到手机比较麻烦，我这里先通过QQ传到手机，在termux上执行 `termux-setup-storage` 可以让termux访问手机存储，找到QQ的目录 `Tencent` 下面的接收文件目录。 cat id_rsa.pub > ~/.ssh/authorized_keys 即可访问，例  `ssh 192.168.1.3  -p 8022`。

连上了ssh，就是发挥你想象力的时候了。

如果要随时随地远程访问可以配合使用 autossh + 反向连接 http://www.cnblogs.com/eshizhan/archive/2012/07/16/2592902.html

能访问后改成清华软件源可以软件包下载速度: https://mirror.tuna.tsinghua.edu.cn/help/termux/

习惯zsh的可以安装ohmyzsh https://github.com/Cabbagec/termux-ohmyzsh