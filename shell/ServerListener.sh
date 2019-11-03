#!/bin/bash
#System Monitoring Script
NULL=NULL
MAILFROM=root@localhost
MAILTO=your_mail@163.com





## 检查存储空间

DISKF=./diskSpace_temp
df -h > $DISKF
# 检查跟目录磁盘占比
PERCENT='9[0-9]%'


CURRENT_ROOT=`cat $DISKF | grep -P $PERCENT | awk '{print $5}'|awk -F% '{print $1}'`

if [ -z "$CURRENT_ROOT"  ] ; then
else
	echo "空间不足"
EOF
fi
## 检查CPU 




## 检查硬盘容量



## 检查应用名称
# APP_NAMES=(zabbix java Google)
# PROCESS_COUNT=0
# ALIAVE=1
# for i in ${APP_NAMES[@]}
# 	#statements
# do
# 	echo $i
# 	PROCESS_COUNT=`ps -ef |grep $i | grep -v 'grep' |wc -l `
# 	echo $PROCESS_COUNT
# 	if [ $ALIAVE -lt $PROCESS_COUN   ] 
# 	then
# 		echo  "$i 进程不存在"	;
# 	else
# 		echo "哈哈哈";
# 	EOF
# 	fi
# 	# echo "111111"
# done
