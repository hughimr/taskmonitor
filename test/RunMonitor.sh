#!/bin/bash
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
#set -x
#�÷�
USAGE(){
echo "Usage : `basename $0` -s \"XXX\" -r \"XXX\" -m \"XXX\" -e \"XXX\" -n XXX -a \"XXX XXX\""
echo "-e -m ��2�������Ǳ���Ҫ�ġ�����������ѡ"
echo -e "\t-s:����������ݵ��ļ�ȫ·��\n"
echo -e "\t-r:��������ݵ��ļ�ȫ·��\n"
echo -e "\t-m:����澯��Ϣ���ʼ��ռ���\n"
echo -e "\t-e:��Ҫִ�еĽű��ļ�\n"
echo -e "\t-n:�������ܴ���\n"
echo -e "\t-a:����ű��ļ���ִ�в���\n"
echo -e "ʾ����\n
    1. RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" \n
    2.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -n 3  \n
    3.RunMonitor.sh -e \"test.sh\" -a \"ios 2017-04-01 \" -m \"gzliwu@91tianchen.com\" \n
    4.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" \n
    5.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" \n
    6.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" "
}

#��ʼ������

#------------------------------------------------------------
##��ȡ����ֵ
while getopts "s:r:m:e:n:a:" options
do
    case ${options} in
    s) sourceDataCheck=$OPTARG;;
    r) resultCheck=$OPTARG;;
    m) alertMailSendTo=$OPTARG;;
    e) execScript=$OPTARG;;
    n) rerunTimes=$OPTARG;;
    a) scriptArgs=$OPTARG;;
    \?) USAGE && exit 1;;
    esac
done

#------------------------------------------------------------
## �ж��������
if [[ $# -eq 0 || ${execScript} = "" || ${alertMailSendTo} = "" ]];
then
    echo "������Ҫ���� -e -m ����"
    USAGE
    exit 1
fi

scriptDir=`pwd`
rerunTimes=${rerunTimes:-1}

if [ ! -e ${scriptDir}/${execScript} ];then
    echo "Ŀ¼${scriptDir}�²������ļ�$execScript"
    LogTool "���õ������鲻ͨ����Ŀ¼${scriptDir}�²������ļ�$execScript"
    exit 1
fi
LogTool "�������ø�ʽ���ͨ�������õ�����Ϊ��${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}"
#------------------------------------------------------------
if [[ ${sourceDataCheck} != "" ]]
then
##���������������Դ.������ʧ�ܾͰ���������д��ʧ��Ŀ¼�µ��ļ��У�������.
#�˴������澯�ʼ�
while read -r line
do
    [[ -z ${line} ]] && continue
    TestEachCondition.sh ${line} || {
        echo "����Դ���ݼ�鲻ͨ����ʧ������Ϊ $line" ;
        LogTool "����Դ���ݼ�鲻ͨ������ͨ��������Ϊ $line" ;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
            exit 1; }
done<${sourceDataCheck}
fi

cd ${scriptDir}
#------------------------------------------------------------
##ִ�нű�����
#ִ��ʧ�ܾͷ��澯�ʼ�
LogTool "��ʼִ��RunMain.sh����"
RunMain.sh "${scriptDir%/}/$execScript ${scriptArgs}" "$rerunTimes" "$alertMailSendTo"
if [ $? -eq 0 ]
then LogTool "RunMain.sh �޴���ִ����ϣ��û������� $execScript ���ִ����ϣ�"
else LogTool "RunMain.sh δ�ɹ�ִ�У�һ���ܵġ������ǲ��ǻ��������ˡ�"
fi
#------------------------------------------------------------
#�������ִ�н����������ʧ�ܾͰ���������д��ʧ��Ŀ¼�µ��ļ��У�������
#���澯�ʼ���ֱ���˹�����
mail_log=`pwd`/mail_log.$RANDOM
if [[ ${resultCheck} != "" ]]
then
while read -r line
do
    [[ -z ${line} ]] && continue
    sh -x TestEachCondition.sh "$line" || {
        echo "����ű�����Ϊ��${scriptDir%/}/$execScript ${scriptArgs}">${mail_log};
        echo "������ϢΪ��">>${mail_log}
        echo "ִ�н����鲻ͨ����ʧ������Ϊ $line" >>${mail_log};
        LogTool "ִ�н����鲻ͨ������ͨ��������Ϊ $line";
        sendmail_monitor -s "�ű����н����ⲻͨ���澯" -t "$alertMailSendTo" -f "$mail_log";
        rm ${mail_log};
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<${resultCheck}
fi

LogTool "��س����Ѿ�ȫ��ִ����ϣ�cheers!"