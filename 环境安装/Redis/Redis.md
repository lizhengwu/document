# 搭建Redis服务单机服务

-------
## 1、解压Redis包
```
tar -zxvf redis-3.2.12.tar.gz
```

我的安装环境是centerOS7 刚装的虚拟机


`make test`
 我在安装的时候报错，因为centerOS是新装的 需要init以下环境 redis 是C语言写的所以要安装C语言的依赖

`yum -y install gcc`

报找不到目录的错误
`make MALLOC=libc`

tcl 报错
`yum install tcl`

再执行
`make test`



如果报错信息如下
(file "tests/helpers/bg_complex_data.tcl" line 10)
  Killing still running Redis server 21198
`vim ../tests/integration/replication-2.tcl`
修改 after 之后的1000 为10000


make install
安装结束
--------

## 2、 在redis目录下创建文件夹

`mkdir bin etc db`

`cp ./src/mkreleasehdr.sh redis-benchmark redis-check-rdb redis-cli redis-server redis-sentinel  ./bin/`
`cp redis.conf ./etc/`

修改配置文件
1、修改为守护模式
daemonize yes
2、注释掉下面
bind 127.0.0.1 
3、置进程锁文件 选配，（目前我没去关心他是什么意思）
pidfile /home/lizhengwu/redis.pid
4、端口
port 6379
5、日志级别
loglevel debug
6、日志文件位置
logfile /home/lizhengwu/log-redis.log
7、设置数据库的数量，默认数据库为16，可以使用SELECT 命令在连接上指定数据库id
databases 16


8、save （持久化操作 Save the DB on disk）
Redis默认配置文件中提供了三个条件： 持久化配置  分别表示900秒（15分钟）内有1个更改，300秒（5分钟）内有10个更改以及60秒内有10000个更改。

save 900 1

save 300 10

save 60 10000


可以看到 Protected-mode 是为了禁止公网访问redis cache，加强redis安全的(这个设置是protected-mode 是3.2 之后加入的新特性,具体可以看Redis.conf的解释)。
protected-mode no 


------
## 3、打开防火墙
此步骤可有可无
`iptables -A INPUT -p tcp --dport 6379 -j ACCEPT`



---------
## 4、配置哨兵

`cp sentinel.conf ./etc/`

```
vi sentinel.conf

#配置主节点
sentinel monitor mymaster 127.0.0.1 6380 2

protected-mode no
#日志目录
logfile "/program/data/redis-3.2.12/log/sentinel.log"
#后台启动
daemonize yes


```





