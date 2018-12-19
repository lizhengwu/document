


----------

 Mysql下载
 https://dev.mysql.com/downloads
 Mysql for Mac 安装教程
 https://www.cnblogs.com/silverlaw/p/7857949.html
 
 
 
 
 ==============================Maven 安装步骤
 
 1、下载 Maven(下载地址：https://maven.apache.org/download.cgi), 并解压到某个目录。例如/Users/rainy/apache-maven-3.3.3

2、打开Terminal,输入以下命令，设置Maven classpath

$ vi ~/.bash_profile
1
3、添加下列两行代码，之后保存并退出Vi：

export M2_HOME=/Users/rainy/apache-maven-3.3.3
export PATH=$PATH:$M2_HOME/bin
1
2
4、输入命令以使bash_profile生效

$ source ~/.bash_profile
1
5、输入mvn -v查看Maven是否安装成功