#!/bin/bash

#50 23 * * * 
if [ "`ls -A /disk1/stat/user/liwu/qa/taskmonitor/sourcefail`" != "" ];then 
mkdir /disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`
cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* >/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt
    
mv  /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* /disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`
echo "�ѽ���������Ƶ�Ŀ¼/disk1/stat/user/liwu/qa/taskmonitor/log/`date +%F`��">>/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt


sendmail_monitor -s "`date +%F`��⵽δִ���������" -f "/disk1/stat/user/liwu/qa/taskmonitor/log/remainTaskForMail.txt" -t "gzliwu@91tianchen.com"
fi