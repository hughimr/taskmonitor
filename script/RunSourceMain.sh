#!/bin/bash
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
runInput=$1
rerunTimes=$2
resultCheck=$3 
mailTo=$4 
LogTool "��ʼִ���û�������${runInput} "
sh RunMain.sh "${runInput}" "${rerunTimes}" "${mailTo}"
if [ $? -eq 0 ]
then LogTool "RunMain.sh �޴���ִ����ϣ��û������� ${runInput} ���ִ����ϣ�"
else LogTool "RunMain.sh δ�ɹ�ִ�У�һ���ܵġ������ǲ��ǻ��������ˡ�"
fi
#�������ִ�н����������ʧ�ܾͰ���������д��ʧ��Ŀ¼�µ��ļ��У�������
#���澯�ʼ���ֱ���˹�����
mail_log=`pwd`/mail_log.$RANDOM
if [[ ${resultCheck} != "" ]]
then 
while read -r line
do 
    [ -z ${line} ] && continue
    TestEachCondition.sh ${line} || {
        
        echo "����ű�����Ϊ��${scriptDir%/}/${execScript} ${scriptArgs}">${mail_log};
        echo "������ϢΪ��">>${mail_log}
        echo "ִ�н����鲻ͨ����ʧ������Ϊ $line" >>${mail_log};
        LogTool "Դ�ļ���鲻ͨ�����������ִ�н����鲻ͨ����ʧ������Ϊ $line";
        sendmail_monitor -s "�ű����н����ⲻͨ���澯" -t "$alertMailSendTo" -f "$mail_log";
        rm ${mail_log};
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<${resultCheck}
fi
LogTool "Դ�ļ���鲻ͨ����������ļ�س����Ѿ�ȫ��ִ����ϣ�cheers!"