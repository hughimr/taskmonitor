#!/bin/bash
source ./LogTool.sh

runInput=$1
rerunTimes=$2
mailTo=$3
error_log=`pwd`/error_log.$RANDOM
mail_log=`pwd`/mail_log.$RANDOM
task="bash -x -e $runInput 2>$error_log"
#���ܴ���
rerunTimes=${rerunTimes:-1}
times=1
_do_ex(){
        export PS4='at line $LINENO :' ;
        LogTool "��ʼ�� $times ��ִ���û�������...";
        eval "$1" || { 
            echo "����ű�����Ϊ��$runInput">$mail_log;
            echo "����ƻ����� $rerunTimes �Ρ�����Ϊ����� $times ִ�г���">>$mail_log;
            LogTool "�û�������� $times ��ִ�г���";
            cp $error_log /disk1/stat/user/liwu/qa/taskmonitor/log/err_log;
            LogTool "�����ļ�$error_log �Ѿ����Ƶ�Ŀ¼/disk1/stat/user/liwu/qa/taskmonitor/log/err_log ��";
            echo "����λ�ã�">>$mail_log
            grep "at line" $error_log|tail -1>>$mail_log
            echo "������ϢΪ��">>$mail_log
            tail -100 $error_log>>$mail_log;
            echo "����ϸ��Ϣ������">>$mail_log
            sendmail_monitor -s "�ű����г���澯" -t "$mailTo" -f "$mail_log" -a "$error_log";
            rm $error_log $mail_log;
            [[ $times > $rerunTimes ]] ;}||{
            echo "exec failed: $1";
            ((times++));
        _do_ex "$task" ;}
}

#ִ������ű�

_do_ex "$task"
if [ $times -eq 1 ];then
LogTool "�û�������ɹ�ִ����ϣ�cheers��"
else
LogTool "�û�������ִ�й������д��󣬴���ԭ����鿴���� $mailTo "
fi
rm $error_log ||echo "ok"
