#!/bin/bash
source ./LogTool.sh

runInput=$1
rerunTimes=$2
mailTo=$3
error_log=`pwd`/error_log.$RANDOM
mail_log=`pwd`/mail_log.$RANDOM
task="bash -x -e $runInput 2>$error_log"
#重跑次数
rerunTimes=${rerunTimes:-1}
times=1
_do_ex(){
        export PS4='at line $LINENO :' ;
        LogTool "开始第 $times 次执行用户主程序...";
        eval "$1" || { 
            echo "出错脚本程序为：$runInput">$mail_log;
            echo "程序计划重跑 $rerunTimes 次。本次为程序第 $times 执行出错。">>$mail_log;
            LogTool "用户主程序第 $times 次执行出错";
            cp $error_log /disk1/stat/user/liwu/qa/taskmonitor/log/err_log;
            LogTool "错误文件$error_log 已经复制到目录/disk1/stat/user/liwu/qa/taskmonitor/log/err_log 下";
            echo "出错位置：">>$mail_log
            grep "at line" $error_log|tail -1>>$mail_log
            echo "错误信息为：">>$mail_log
            tail -100 $error_log>>$mail_log;
            echo "更详细信息见附件">>$mail_log
            sendmail_monitor -s "脚本运行出错告警" -t "$mailTo" -f "$mail_log" -a "$error_log";
            rm $error_log $mail_log;
            [[ $times > $rerunTimes ]] ;}||{
            echo "exec failed: $1";
            ((times++));
        _do_ex "$task" ;}
}

#执行任务脚本

_do_ex "$task"
if [ $times -eq 1 ];then
LogTool "用户主程序成功执行完毕！cheers！"
else
LogTool "用户主程序执行过程中有错误，错误原因请查看邮箱 $mailTo "
fi
rm $error_log ||echo "ok"
