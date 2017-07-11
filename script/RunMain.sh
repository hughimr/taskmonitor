#!/bin/bash
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
        eval "$1" || { 
            echo "出错脚本程序为：$runInput">$mail_log;
            echo "程序计划重跑 $rerunTimes 次。本次为程序第 $times 执行出错。">>$mail_log;
            echo "出错位置：">>$mail_log
            grep "at line" $error_log|tail -1>>$mail_log
            echo "错误信息为：">>$mail_log
            tail -100 $error_log>>$mail_log;
            echo "更详细信息见附件">>$mail_log
            sendmail_kdb -s "脚本运行出错告警" -t "$mailTo" -f "$mail_log" -a "$error_log";
            rm $error_log $mail_log;
            [[ $times > $rerunTimes ]] ;}||{
            sleep 1200;
            echo "exec failed: $1";
            ((times++));
        _do_ex "$task" ;}
}

#执行任务脚本
_do_ex "$task"

rm $error_log
