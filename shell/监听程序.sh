#!/bin/bash
#System Monitoring Script
while [ 1 ]
do
#本机需开启postfix或sendmail服务。
#报警邮件地址设置
MAILFROM=root@localhost
MAILTO=your_mail@163.com
#设置脚本运行间隔时间。单位（秒）。
RUNTIME=900
#内存使用率监控设置，单位 （%）
MEMTHRE=80
#流量监控设置
#要监控的网卡
ETHX=eth0
#填写大于多少MB的时候发送警报,单位（MB)
INFLOWTHREMB=50
OUTFLOWTHREMB=50
#填写大于多少KB的时候发送警报,单位（KB)
INFLOWTHREKB=8000
OUTFLOWTHREKB=8000
#TCP连接状态数量监控设置
#填写最大连接的个数
TIME_WAIT=4000
FIN_WAIT1=500
FIN_WAIT2=200
ESTABLISHED=4000
SYN_RECV=100
CLOSE_WAIT=100
CLOSING=1000
LAST_ACK=3000
#CPU使用率监控设置
#填写cpu使用率大于多少发送报警，单位（%）
CPUTHRE=60
#硬盘使用大小设置
#填写硬盘占用率，单位（%）
ROOT=80
VAR=100
USR=100
BOOT=80
#调试模式开关。（YES／NO）
DBUG=NO
# 监 控 脚 本 执 行 内 容
################################################################################
time=`date +"%Y-%m-%d %H:%M:%S"`

#内存监控部分
NULL=/dev/null
MEM=`free -m |grep Mem |awk '{print $3/$2*100}'`
MEMB=`free -m |grep Mem |awk '{print $2,$4+$6+$7}'|awk '{print $1,$1-$2}'| awk '{print $2/$1*100}'`
memuse=`free -m|grep "buffers/cache"|awk '{print $3}'`
memtotal=`free -m|grep "Mem"|awk '{print $2}'`
memory=`echo "$memuse/$memtotal*100"|bc -l|cut -d. -f1`
MA=`expr $memory \> $MEMTHRE `
if [ $MA -eq 1 ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:70warning
$time MEM内存警告，当前内存占用率为$MEM %，大于$MEMTHRE %.
EOF
fi
MB=`expr $MEMB \> $MEMTHRE`
if [ $MB -eq 1 ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time MEMB内存警告，当前内存占用率为$MEMB %，大于$MEMTHRE %
EOF
fi


#流量监控部分
FLOWA=/tmp/.flow
ifconfig $ETHX |grep "RX byte" |awk '{print $2" "$6}' |awk -Fbytes: '{print "INPUT "$2"OUTPUT "$3}'\ > $FLOWA
INPUTA=`cat $FLOWA |awk '{print $2}'`
OUTPUTA=`cat $FLOWA |awk '{print $4}'`
sleep 1
ifconfig $ETHX |grep "RX byte" |awk '{print $2" "$6}' |awk -Fbytes: '{print "INPUT "$2"OUTPUT "$3}'\ > $FLOWA
INPUTB=`cat $FLOWA |awk '{print $2}'`
OUTPUTB=`cat $FLOWA |awk '{print $4}'`
INPUTC=`echo "$INPUTB-$INPUTA" | bc`
OUTPUTC=`echo "$OUTPUTB-$OUTPUTA"| bc`
INPUTMBA=`echo "$INPUTC/1024"|bc`
OUTPUTMBA=`echo "$OUTPUTC/1024"|bc`
INMBF=/tmp/.inputMB
OUTMBF=/tmp/.outputMB
echo `echo "scale=4;$INPUTMBA/1024"|bc`MB > $INMBF
echo `echo "scale=4;$OUTPUTMBA/1024"|bc`MB > $OUTMBF
INMB=`cat $INMBF |awk '{print $1}'`
OUTMB=`cat $OUTMBF |awk '{print $1}'`
if [ $INPUTMBA -gt 1024 ] ; then
if [ $INMB -gt $INFLOWTHREMB ] ;then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 流量警告，当前流量异常，请登录服务器查看。当前速率$INMB MB/秒,大于$INFLOWTHREMB MB/秒。
EOF
fi
if [ $OUTMB -gt $OUTFLOWTHREMB ] ;then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 流量警告，当前流量异常，请登录服务器查看。当前速率$OUTMB MB/秒 大于$OUTFLOWTHREMB MB/秒。
EOF
fi
else
INKBF=/tmp/.inputKB
OUTKBF=/tmp/.outputKB
echo $INPUTMBA KB > $INKBF
echo $OUTPUTMBA KB > $OUTKBF
INKB=`cat $INKBF |awk '{print $1}'`
OUTKB=`cat $OUTKBF |awk '{print $1}'`
if [ $INKB -gt $INFLOWTHREKB ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 流量警告，当前流量异常，请登录服务器查看。$INKB KB/秒 大于$INFLOWTHREKB KB/秒。
EOF
fi
if [ $OUTKB -gt $OUTFLOWTHREKB ] ;then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 流量警告，当前流量异常，请登录服务器查看。当前速率$OUTKB KB/秒大于$INFLOWTHREKB KB/秒。
EOF
fi
fi
#连接数
tcpfile=/tmp/.tcp
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}' >$tcpfile
grep TIME_WAIT $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "TIME_WAIT 0 " >> $tcpfile
fi
grep FIN_WAIT1 $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "FIN_WAIT1 0 " >> $tcpfile
fi
grep FIN_WAIT2 $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "FIN_WAIT2 0 " >> $tcpfile
fi
grep CLOSE_WAIT $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "CLOSE_WAIT 0 " >> $tcpfile
fi
grep LAST_ACK $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "LAST_ACK 0 " >> $tcpfile
fi
grep SYN_RECV $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "SYN_RECV 0 " >> $tcpfile
fi
grep CLOSING $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "CLOSING 0 " >> $tcpfile
fi
grep ESTABLISHED $tcpfile > $NULL
if [ $? -eq 1 ] ; then
echo "ESTABLISHED 0 " >> $tcpfile
fi
TIME_WAITV=`grep TIME_WAIT $tcpfile | awk '{print $2}'`
FIN_WAIT1V=`grep FIN_WAIT1 $tcpfile | awk '{print $2}'`
FIN_WAIT2V=`grep FIN_WAIT2 $tcpfile | awk '{print $2}'`
ESTABLISHEDV=`grep ESTABLISHED $tcpfile | awk '{print $2}'`
SYN_RECVV=`grep SYN_RECV $tcpfile | awk '{print $2}'`
CLOSINGV=`grep CLOSING $tcpfile | awk '{print $2}'`
CLOSE_WAITV=`grep CLOSE_WAIT $tcpfile | awk '{print $2}'`
LAST_ACKV=`grep LAST_ACK $tcpfile | awk '{print $2}'`
if [ $ESTABLISHEDV -gt $ESTABLISHED ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前ESTABLISHED连接数异常，请登录服务器查看。当前连接数为$ESTABLISHEDV个,大于$ESTABLISHED个
EOF
fi
if [ $SYN_RECVV -gt $SYN_RECV ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前SYN_RECV连接数异常，请登录服务器查看。当前连接数为$SYN_RECVV个，大于$SYN_REC个。
EOF
fi
if [ $CLOSE_WAITV -gt $CLOSE_WAIT ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前CLOSE_WAIT连接数异常，请登录服务器查看。当前连接数为$CLOSE_WAITV个，大于$CLOSE_WAIT个。
EOF
fi
if [ $CLOSINGV -gt $CLOSING ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前CLOSING连接数异常，请登录服务器查看。当前连接数为$CLOSINGV个,大于$CLOSING个。
EOF
fi
if [ $LAST_ACKV -gt $LAST_ACK ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前LAST_ACK连接数异常，请登录服务器查看。当前连接数为$LAST_ACKV个，大于$LAST_ACK个。
EOF
fi
if [ $TIME_WAITV -gt $TIME_WAIT ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前TIME_WAIT连接数异常，请登录服务器查看。当前连接数为$TIME_WAITV个，大于$TIME_WAIT个。
EOF
fi
if [ $FIN_WAIT1V -gt $FIN_WAIT1 ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前FIN_WAIT1连接数异常，请登录服务器查看。当前连接数为$FIN_WAIT1V个，大于$FIN_WAIT1个。
EOF
fi
if [ $FIN_WAIT2V -gt $FIN_WAIT2 ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 连接数警告，当前FIN_WAIT2连接数异常，请登录服务器查看。当前连接数为$FIN_WAIT2V个，大于$FIN_WAIT2个。
EOF
fi
DISKF=/tmp/.disk
df -h > $DISKF
grep var $DISKF > $NULL
if [ $? -eq 1 ] ; then
echo "/dev/sda1 20G 1.6G 17G 0% /var" >> $DISKF
fi
grep usr $DISKF > $NULL
if [ $? -eq 1 ] ; then
echo "/dev/sda1 20G 1.6G 17G 0% /usr" >> $DISKF
fi
grep boot $DISKF > $NULL
if [ $? -eq 1 ] ; then
echo "/dev/sda1 20G 1.6G 17G 0% /boot" >> $DISKF
fi
BOOTV=`cat $DISKF | grep boot | awk '{print $5}'|awk -F% '{print $1}'`
VARV=`cat $DISKF | grep var | awk '{print $5}'|awk -F% '{print $1}'`
USRV=`cat $DISKF | grep usr | awk '{print $5}'|awk -F% '{print $1}'`
grep VolGroup $DISKF > $NULL
if [ $? -eq 0 ] ;then
ROOTV=`cat $DISKF | sed -n '3p' |awk '{print $4}'|awk -F% '{print $1}'`
else
ROOTV=`cat $DISKF | sed -n '2p'|awk '{print $5}'|awk -F% '{print $1}'`
fi
if [ $ROOTV -gt $ROOT ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 磁盘使用警告，您监控的 / 分区已经大于你设置的数值$ROOT %，详情登陆系统查看，目前使用率为$ROOTV %.
EOF
fi
if [ $VARV -gt $VAR ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 磁盘使用警告，您监控的 /var 分区已经大于你设置的数值$VAR %，详情登陆系统查看，目前使用率为$VARV %.
EOF
fi
if [ $BOOTV -gt $BOOT ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 磁盘使用警告，您监控的 /boot 分区已经大于你设置的数值 $BOOT %，详情登陆系统查看，目前使用率为$BOOTV %.
EOF
fi
if [ $USRV -gt $USR ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 磁盘使用警告，您监控的 /usr 分区已经大于你设置的数值$USR %，详情登陆系统查看，目前使用率为$USRV %.
EOF
fi
CPURATE=`top -b -n 1 |grep Cpu | awk '{print $2}' |awk -F. '{print $1}'`
CB=`expr $CPURATE \> $CPUTHRE`
if [ $CB -eq 1 ] ; then
sendmail -t <<EOF
from: $MAILFROM
to:$MAILTO
subject:67warning
$time 使用警告，您监控的CPU使用率，已经超过您设置的限额$CPUTHRE %,当前CPU使用率为$CPURATE .
EOF
fi
DBUGS=YES
if [ "$DBUGS" == "$DBUG" ] ; then
echo " "'== 内 存 ==' ;echo \ ;
echo " "当前程序占用内存为 $MEMB % ,总占用内存为 $MEM % ; echo \ ;
echo " "'== 流 量 =='; echo \ ;
YA=`wc -l $INMBF > /dev/null 2>&1 ; echo $?`
if [ $YA -eq 1 ] ; then
echo 0 > $INMBF
fi
IN=`expr $INMB \> $INFLOWTHREMB >$NULL; echo $? ` 2> $NULL
if [ $IN -eq 1 ] ; then
echo " "当前输入流量为 $INMB MB/秒 .;
echo " "当前输入流量为 $INKB KB/秒 .;
fi
YB=`wc -l $OUTMBF > /dev/null 2>&1 ; echo $?`
if [ $YB -eq 1 ] ; then
echo 0 > $OUTMBF
fi
OUT=`expr $OUTMB \> $OUTFLOWTHREMB >$NULL ; echo $?` 2> $NULL
if [ $OUT -eq 1 ] ; then
echo " "当前输出流量为 $OUTMB MB/秒。 ;
echo " "当前输出流量为 $OUTKB KB/秒。 ; echo \ ;
fi
echo " "'== 连接数 ==' ; echo \ ;
echo " "当前TIME_WAIT" " 连接数为 $TIME_WAITV 个。
echo " "当前FIN_WAIT1" " 连接数为 $FIN_WAIT1V 个。
echo " "当前FIN_WAIT2" " 连接数为 $FIN_WAIT2V 个。
echo " "当前CLOSE_WAIT" " 连接数为 $CLOSE_WAITV 个。
echo " "当前ESTABLISHED"" 连接数为 $ESTABLISHEDV 个。
echo " "当前SYN_RECV" " 连接数为 $SYN_RECVV 个。
echo " "当前LAST_ACKV" " 连接数为 $LAST_ACKV 个。
echo " "当前CLOSING" " 连接数为 $CLOSINGV 个。; echo \ ;
echo " "'== CPU使用率 ==' ; echo \ ;
echo " "当前CPU 进程使用率为 $USERATE . ;echo \ ;
echo " "'== 磁盘使用率 ==' ; echo \ ;
echo " "当前" "/" "分区," "使用率为 $ROOTV %.
echo " "当前/var 分区， 使用率为 $VARV %.
echo " "当前/boot分区， 使用率为 $BOOTV %.
echo " "当前/usr 分区， 使用率为 $USRV %.
exit
fi
sleep $RUNTIME
done