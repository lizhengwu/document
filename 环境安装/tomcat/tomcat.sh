#!/bin/bash
# Description: start or stop the tomcat  
# Usage: tomcat [start|stop|restart|logs]  
# 
export PATH=$PATH:$HOME/bin
export BASH_ENV=$HOME/.bashrc
export USERNAME="app"

case "$1" in
start)
# startup the tomcat  
cd /usr/local/apache-tomcat-7.0.70/bin/
./startup.sh
;;
stop)
# stop tomcat  
cd /usr/local/apache-tomcat-7.0.70/bin/
./shutdown.sh
echo "Tomcat Stoped"
;;
restart)
$0 stop
$0 start
;;
logs)
# logs the tomcat  
cd /usr/local/apache-tomcat-7.0.70/logs
tail -200f catalina.out
;;
*)
echo "tomcat: usage: tomcat [start|stop|restart|logs]"
exit 1
esac
exit 0

