#!/bin/bash



scriptDir=$(pwd)
execScript="run.sh"
scriptArgs="a b c 12"


##���Ҷ�ʱ�����е�crond����
pids=$(pstree -ap |grep "[|]-crond"|cut -d ',' -f 2)


#һ��Сtrick:ȥ��args�еĶ���ո�ʹ֮���̨��ʽ����һ��
argsM=$(echo ${scriptArgs})
for _i in ${pids[*]};do
#����crond�������Ƿ��и���������ִ�У�Ҫ����args ����������һ�����б���ü��������
taskIsExist=($(pstree -apl ${_i} | grep ${scriptDir} |grep ${execScript} |grep ${argsM}))

if [ -n "${taskIsExist}" ];then
    echo "�ýű����ں�ִ̨�У�����Kill����"
    echo "��̨�������飺${taskIsExist[*]}"
    exit 1
    fi

done

##�鿴sourcefailĿ¼���Ƿ��д��ֶ�ִ�е������ڵȴ�������о�ɾ����Ȼ���ֶ�ִ��
taskFiles=($(grep -l "${scriptDir}###${execScript}###${scriptArgs}" /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* ))
if [ -n "${taskFiles}" ];then
#ɾ��sourcefailĿ¼���ҵ��������á��ļ���###�ļ�����ƥ��
LogTool "�ֶ�ִ�������������ɾ��������Ϊ��$(cat ${taskFiles[*]})"
rm ${taskFiles[*]}
fi

