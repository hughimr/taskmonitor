#!/bin/bash

runInput=$1
rerunTimes=$2
resultCheck=$3 
mailTo=$4 

sh RunMain.sh "$runInput" "$rerunTimes" "$mailTo"
   
#�������ִ�н����������ʧ�ܾͰ���������д��ʧ��Ŀ¼�µ��ļ��У�������
#���澯�ʼ���ֱ���˹�����
mail_log=`pwd`/mail_log.$RANDOM
if [[ $resultCheck != "" ]]
then 
while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
        
        echo "����ű�����Ϊ��${scriptDir%/}/$execScript ${scriptArgs}">$mail_log;
        echo "������ϢΪ��">>$mail_log
        echo "ִ�н����鲻ͨ����ʧ������Ϊ $line" >>$mail_log;
        sendmail_kdb -s "�ű����н����ⲻͨ���澯" -t "$alertMailSendTo" -f "$mail_log";
        rm $mail_log;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<$resultCheck 
fi
