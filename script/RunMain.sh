#!/bin/bash
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
        eval "$1" || { 
            echo "����ű�����Ϊ��$runInput">$mail_log;
            echo "����ƻ����� $rerunTimes �Ρ�����Ϊ����� $times ִ�г���">>$mail_log;
            echo "����λ�ã�">>$mail_log
            grep "at line" $error_log|tail -1>>$mail_log
            echo "������ϢΪ��">>$mail_log
            tail -100 $error_log>>$mail_log;
            echo "����ϸ��Ϣ������">>$mail_log
            sendmail_kdb -s "�ű����г���澯" -t "$mailTo" -f "$mail_log" -a "$error_log";
            rm $error_log $mail_log;
            [[ $times > $rerunTimes ]] ;}||{
            sleep 1200;
            echo "exec failed: $1";
            ((times++));
        _do_ex "$task" ;}
}

#ִ������ű�
_do_ex "$task"

rm $error_log
