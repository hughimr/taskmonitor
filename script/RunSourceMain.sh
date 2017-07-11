#!/bin/bash

runInput=$1
rerunTimes=$2
resultCheck=$3 
mailTo=$4 

sh RunMain.sh "$runInput" "$rerunTimes" "$mailTo"
   
#检查任务执行结果。如果检查失败就把数据任务写到失败目录下的文件中，不重跑
#发告警邮件，直接人工处理。
mail_log=`pwd`/mail_log.$RANDOM
if [[ $resultCheck != "" ]]
then 
while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
        
        echo "出错脚本程序为：${scriptDir%/}/$execScript ${scriptArgs}">$mail_log;
        echo "错误信息为：">>$mail_log
        echo "执行结果检查不通过：失败条件为 $line" >>$mail_log;
        sendmail_kdb -s "脚本运行结果检测不通过告警" -t "$alertMailSendTo" -f "$mail_log";
        rm $mail_log;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<$resultCheck 
fi
