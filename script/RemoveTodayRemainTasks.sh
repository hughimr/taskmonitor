#!/bin/bash

#50 23 * * * 
if [ "`ls -A /disk1/stat/user/liwu/qa/taskmonitor/sourcefail`" != "" ];then 
mkdir /disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`
cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* >/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt
    
mv  /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* /disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`
echo "已将相关任务移到目录/disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`下">>/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt


sendmail_monitor -s "`date +%F`检测到未执行完的任务" -f "/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt" -t "gzliwu@91tianchen.com"
fi