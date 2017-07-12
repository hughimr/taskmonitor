#!/bin/bash
#��3�㿪ʼÿ��30�������� 0,30 2-23 * * * 
#��/disk1/stat/user/liwu/qa/taskmonitor/sourcefail��������ִ��
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
toDoList=( `ls -t -r /disk1/stat/user/liwu/qa/taskmonitor/sourcefail` )

#ѭ������
for task_i in ${toDoList[*]}
do 
    #��ȡ����
#${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}
    scriptDir=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $1}' `
    execScript=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $2}' `
    scriptArgs=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $3}' `
    sourceDataCheck=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $4}' `
    rerunTimes=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $5}' `
    resultCheck=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $6}' `
    mailTo=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $7}' `
    
    rm /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i};
    #���Դ����,�������ͨ�������нű� 
    cd ${scriptDir}
    if [[ ${sourceDataCheck} != "" ]]
    then
    while read -r line
    do 
        [[ -z ${line} ]] && continue
        TestEachCondition.sh ${line} || {
            echo "����Դ���ݼ�鲻ͨ����ʧ������Ϊ ${line} " ;
            LogTool "����Դ���ݼ�鲻ͨ������ͨ������Ϊ ${line} ";
            echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${mailTo}">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
                exit 1; }
    done<${sourceDataCheck}
    fi
    LogTool "Դ���ݼ��ͨ������ʼ����RunSourceMain.sh����"
    nohup sh RunSourceMain.sh "${scriptDir%/}/$execScript ${scriptArgs}" "$rerunTimes" "$resultCheck" "$mailTo" &
done

