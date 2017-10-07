---
title: 简易的基于iptables和nginx访问日志屏蔽爬虫的方法
date: 2016-04-20 11:15:27
tags:
---

最近网站数据总是被人爬取，一天爬取几百万次,还会经常换ip。写了个简单粗暴的shell脚本，根据nginx访问日志，分析出最像爬虫的ip，然后用iptable来封掉这个ip。

```bash
/sbin/iptables -nvL INPUT | awk '{if(NR>2)print $8}' > /dev/shm/nginx_iptable_list
# 列出当前封禁ip的名单,写到 /dev/shm/nginx_iptable_list 中
# /dev/shm是一个tmpfs基于内存的文件系统，有利于加快速度
# iptables -n 表示用数字形式显示ip地址和端口号，不然会用hostname来显示
# iptables -v 显示详细的调试信息
# iptables -L INPUT 列出INPUT，不指定则列出所有  这里我们封杀爬虫只需要INPUT就行
# awk NR是特殊变量,这边用来过滤掉数据前两行
```

```bash
tail -n 100000 /var/log/nginx/access.log | grep  -i -v -E '(192.168.*)|(127.0.0.1)' | awk '{print $1}' | sort | uniq -c | sort -rn | awk '{if($1>'1000')print $2}' | sort | uniq > /dev/shm/nginx_ip_to_ban_pre
# 这里用了简单粗暴的方法分析出最近100000万次请求，同一个ip访问超过1000次的ip。
# grep -i 忽略大小写  -v 取反，表示选择不匹配的  -E 正则表达式
# '(192.168.*)|(127.0.0.1)' 表示内网的过滤掉，不参与筛选
```
注意：这里需要根据自己网站的访问情况自己去写筛选规则，最好根据网站用户行为去分析，像这样直接按ip访问次数的容易误杀。有的运营商一个出口ip有好多人在用。

```bash
sort /dev/shm/nginx_iptable_list /dev/shm/nginx_ip_to_ban_pre | uniq -u > /dev/shm/nginx_ip_to_ban
#筛选出要屏蔽的ip
```

```bash
/sbin/iptables -nvL INPUT | awk '$1 <= 100 {print $8}' | sort | uniq > /dev/shm/nginx_ip_to_unban
for ip in `cat /dev/shm/nginx_ip_to_unban`;
do echo $ip && /sbin/iptables -D INPUT -p tcp --dport 80 -s $ip -j DROP;
done
#筛选pkts小于100的条目，解除封锁  防止长期误杀
```


```bash
/sbin/iptables -Z
# iptables 计数清零
```

```bash
for ip in `cat /dev/shm/nginx_ip_to_ban`;
do /sbin/iptables -I INPUT -p tcp --dport 80 -s $ip -j DROP;
done
# 封锁要屏蔽的ip
```
