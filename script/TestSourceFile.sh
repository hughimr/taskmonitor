#!/bin/bash
#���Դ�����ļ������Ƿ�����
sourceDataCheck=$1

while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
        echo "����Դ���ݼ�鲻ͨ����ʧ������Ϊ $line" ;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###$resultCheck">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
            exit 1; }
done<$sourceDataCheck
fi
