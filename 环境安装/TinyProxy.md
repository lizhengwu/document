##TinyProxy
由于行内访问外网需要走代理，为了方便测试，在公司环境要搭建一个代理服务器，此服务器与nginx不一样
环境centerOS7  
参考文章  https://blog.csdn.net/zhongliangtang/article/details/81327636


如果yum 找不到包就更新
yum install -y epel-release
yum update -y
yum -y install tinyproxy
yum install vim -y

分别测试yum -y upgrade 和yum -y update
update 连内核都更新了，upgrade 只更新安装包


修改Allow 和Port 
还有ConnectPort  这个参数尽量去掉，因为这个会限制访问的实际端口。

service tinyproxy start

