#!/bin/bash
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
runInput=$1
rerunTimes=$2
resultCheck=$3 
mailTo=$4 
LogTool "开始执行用户主程序：${runInput} "
sh RunMain.sh "${runInput}" "${rerunTimes}" "${mailTo}"
if [ $? -eq 0 ]
then LogTool "RunMain.sh 无错误执行完毕！用户主程序 ${runInput} 监控执行完毕！"
else LogTool "RunMain.sh 未成功执行！一般能的。考虑是不是机器死掉了。"
fi
#检查任务执行结果。如果检查失败就把数据任务写到失败目录下的文件中，不重跑
#发告警邮件，直接人工处理。
mail_log=`pwd`/mail_log.$RANDOM
if [[ ${resultCheck} != "" ]]
then 
while read -r line
do 
    [ -z ${line} ] && continue
    TestEachCondition.sh ${line} || {
        
        echo "出错脚本程序为：${scriptDir%/}/${execScript} ${scriptArgs}">${mail_log};
        echo "错误信息为：">>${mail_log}
        echo "执行结果检查不通过：失败条件为 $line" >>${mail_log};
        LogTool "源文件检查不通过队列任务的执行结果检查不通过：失败条件为 $line";
        sendmail_monitor -s "脚本运行结果检测不通过告警" -t "$alertMailSendTo" -f "$mail_log";
        rm ${mail_log};
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<${resultCheck}
fi
LogTool "源文件检查不通过队列任务的监控程序已经全部执行完毕！cheers!"