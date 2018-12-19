# Nginx

背景：

​	在做某银行的项目时，由于各种原因，需要我们自己搭建一个nginx服务器，来做163邮件的反向代理。Nginx是一款高性能的Web和反向代理服务器，也是一个IMAP/POP3/SMTP代理服务器，在高连接并发情况下，Nginx是Apache服务器的不错的代替品。



准备

1) nginx-1.8.1.tar.gz

2) 模块包：nginx_tcp_proxy_module-master.zip

3) 依赖包：zlib-1.2.8.tar.gz    openssl-1.0.2e.tar.gz  pcre-8.37.tar



## 安装

 1)首先创建nginx用户

groupadd -g 2000 nginx 

useradd -u 2000 -g nginx -d  /home/nginx nginx  -m 

 

将所需要的包上传到安装目录并赋予相应的权限，以下以/home/nginx为例：

su - nginx   (用nginx用户安装）

2)安装pcre PCRE作用是让Nginx支持Rewrite功能；

  mkdir  pcre

  tar -xvf   pcre-8.37.tar  解压安装包；

  cd   pcre-8.37              进入安装包目录；

 ./configure --prefix=/nginx/pcre   

执行make & make install                     编译与安装；

3) 安装zlib

  mkdir   zlib

  tar -zxvf   zlib-1.2.8.tar.gz   解压安装包；

  cd   zlib-1.2.8             进入安装包目录；

 ./configure --prefix=/nginx/zlib  

 执行make & make install                     编译与安装；

 

4) 安装openssl

  mkdir   openssl

  tar -zxvf   openssl-1.0.2e.tar.gz   解压安装包；

  cd   openssl-1.0.2e           进入安装包目录；

 ./config --prefix=/nginx/openssl

 执行make & make install                     编译与安装；



4)安装nginx

  mkdir   nginx

  tar -zxvf   nginx-1.8.1.tar.gz   解压安装包；

  unzip unzip nginx_tcp_proxy_module-master.zip 解压第三方补丁包；

  cd   nginx-1.8.1                    进入安装包目录；

patch -p1 < /nginx/nginx_tcp_proxy_module-master/tcp.patch  执行TCP第三方补丁包；

 ./configure --help               可以预先查看 每个参数的含义 ；

知道参数的含义后，执行命令: 

./configure --with-mail

​            --with-mail_ssl_module 

​            --with-http_gzip_static_module

​            --with-http_stub_status_module

​            --with-http_ssl_module

​            --with-openssl=/nginx/openssl-1.0.2e

​            --with-pcre=/nginx/pcre-8.37

​            --with-zlib=/nginx/zlib-1.2.8

​            --add-module=/nginx/nginx_tcp_proxy_module-master

​            --prefix=/nginx/nginx

执行make & make install                      编译与安装；

安装完毕；



**nginx的常用命令**

/**nginxPath**/sbin/nginx             启动nginx；

 /**nginxPath**/sbin/nginx  -t         检查配置文件nginx的正确性

/**nginxPath**/sbin/nginx  -s reload   重新载入配置文件；

/**nginxPath**sbin/nginx  -s reopen   重新启动nginx；

/**nginxPath**/sbin/nginx  -s stop     停止nginx；





## lua 脚本

