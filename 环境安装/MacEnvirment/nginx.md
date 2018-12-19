

# Nginx

背景：

​	在做大数据项目，调用外部厂商的时候，内网系统需要走代理来访问互联网上的数据厂商，在开发的时候就需要用有代理和非代理两类代码。所以为了方便开发在公司服务器搭建一个正向代理服务器。来方便开发。



准备工作：

​	在最初为了方便，在网上搜了TinyProxy的搭建（../环境类/TinyProxy.md) 这个安装过后可以直接提供代理服务，后来公司大佬说nginx也可以实现，让我改成nginx这样方便统一管理，然后就去搜索了一下nginx关于正向代理的。在这里特别要注意，java代理是先连接到代理服务器，然后再从代理服务器去connect目标服务器。现在的需求是一个端口能代理http也能代理https，代理端口只有一个，转发端口会很多，所以网上找了很久，大部分都是建议两个端口。

​	由于本人没有自己部署过nginx ，所以记录一下这次本地部署。网上的Mac的Nginx的安装方法大部分都是brew install nginx 我刚开始也是用的这种方法安装的，但是后来发现没办法新增模块，因为下载下俩的是编译好的，所以我又卸载了nginx 然后从官网上下载了一个压缩包，准备自己编译安装。







### 安装nginx

​	去官网下载你需要的版本，然后解压开，进入nginx目录。这个时候执行命令。 有新增模块的时候一定要先编译安装好依赖模块，再编译nginx

```linux
./configure --prefix=/usr/local/Cellar/nginx --with-openssl=/usr/local/Cellar/openssl/1.0.2p  --with-http_ssl_module  --add-module=../ngx_http_proxy_connect_module-master
```

--prefix ： 安装路径

--conf-path=PATH ： 设置nginx.conf配置文件的路径。nginx允许使用不同的配置文件启动，通过命令行中的-c选项。默认为prefix/conf/nginx.conf

--user=name： 设置nginx工作进程的用户。安装完成后，可以随时在nginx.conf配置文件更改user指令。默认的用户名是nobody。--group=name类似

--with-pcre ： 设置PCRE库的源码路径，如果已通过yum方式安装，使用--with-pcre自动找到库文件。使用--with-pcre=PATH时，需要从PCRE网站下载pcre库的源码（版本4.4 - 8.30）并解压，剩下的就交给Nginx的./configure和make来完成。perl正则表达式使用在location指令和 ngx_http_rewrite_module模块中。

--with-zlib=PATH ： 指定 zlib（版本1.1.3 - 1.2.5具体参考官网）的源码解压目录。在默认就启用的网络传输压缩模块ngx_http_gzip_module时需要使用zlib 。

--with-http_ssl_module ： 使用https协议模块。默认情况下，该模块没有被构建。前提是openssl与openssl-devel已安装



--add-module=PATH ： 添加第三方外部模块，如nginx-sticky-module-ng或缓存模块。每次添加新的模块都要重新编译（Tengine可以在新加入module时无需重新编译）

等等其他模块，







```
make 
make install
```





make的时候一定要去看报错，然后根据报错来解决问题，我在make的时候出现了个错，

因为我是指定的openSSl的路径，nginx默认的路径可能与我下载或者brew下来的路径有部分差异，所以我需要改一下如下部分

> >打开nginx源文件下的/usr/local/src/nginx-1.9.9/auto/lib/openssl/conf文件：
> >找到这么一段代码：
> >CORE_INCS="$CORE_INCS $OPENSSL/.openssl/include"
> >CORE_DEPS="$CORE_DEPS $OPENSSL/.openssl/include/openssl/ssl.h"
> >CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libssl.a"
> >CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libcrypto.a"
> >CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
> >修改成以下代码：
> >CORE_INCS="$CORE_INCS $OPENSSL/include"
> >CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"
> >CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libssl.a"
> >CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libcrypto.a"
> >CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
> > 然后再进行Nginx的编译安装即可





make 无错误后即可makeinstall





配置文件

server {
        ##代理日志配置 off 表示关闭日志输出
        ##access_log /home/bingchenglin/logs/nginx/access.log;
        ##文件路径可用于监控代理的接入情况
​        access_log off;
        ##配置服务端口
​        listen 6099;    
        ##DNS地址 多个DNS地址用空格隔开
​      

      server {
            ##代理日志配置 off 表示关闭日志输出
            ##access_log /logs/nginx/access.log;
            ##文件路径可用于监控代理的接入情况
            access_log off;
            ##配置服务端口
            listen 6099;    
            ##DNS地址 多个DNS地址用空格隔开
            resolver XXX.XXX.XXX.XXX; 
            proxy_connect;
            proxy_connect_allow            443 563 80 ;
            proxy_connect_connect_timeout  30s;
            proxy_connect_read_timeout     30s;
            proxy_connect_send_timeout     30s;    
            location / {
                    
                    ##环境变量通配一般不改
                    proxy_pass $scheme://$http_host$request_uri;
                    proxy_set_header Host $http_host;
                    proxy_buffers   256 4k;                         
                    proxy_max_temp_file_size 0k;                        
            } 
        }




还有部分模块的安装在 (/环境类/nginx/)下是在linux上安装邮件反向代理的文档




## 安装 ngx_http_proxy_connect_module 
模块地址 https://github.com/chobits/ngx_http_proxy_connect_module

安装方法在git上有很详细的教程。软件的作者这个图剪纸亮瞎了我的双眼，个人认为非常有助于帮助我理解

The sequence diagram of above example is as following:

```
  curl                     nginx (proxy_connect)            github.com
    |                             |                          |
(1) |-- CONNECT github.com:443 -->|                          |
    |                             |                          |
    |                             |----[ TCP connection ]--->|
    |                             |                          |
(2) |<- HTTP/1.1 200           ---|                          |
    |   Connection Established    |                          |
    |                             |                          |
    |                                                        |
    ========= CONNECT tunnel has been establesied. ===========
    |                                                        |
    |                             |                          |
    |                             |                          |
    |   [ SSL stream       ]      |                          |
(3) |---[ GET / HTTP/1.1   ]----->|   [ SSL stream       ]   |
    |   [ Host: github.com ]      |---[ GET / HTTP/1.1   ]-->.
    |                             |   [ Host: github.com ]   |
    |                             |                          |
    |                             |                          |
    |                             |                          |
    |                             |   [ SSL stream       ]   |
    |   [ SSL stream       ]      |<--[ HTTP/1.1 200 OK  ]---'
(4) |<--[ HTTP/1.1 200 OK  ]------|   [ < html page >    ]   |
    |   [ < html page >    ]      |                          |
    |                             |                          |
```









## 验证代理服务

跳过SSL验证 -k 

curl https://github.com/ -v -x 127.0.0.1:6099











本文部分转载自：https://www.jianshu.com/p/0d1445e5ecca