#!/bin/bash
#���ִ�н�������Ƿ�����
resultCheck=$1

while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
       echo "ִ�н����鲻ͨ����ʧ������Ϊ $line" ;
       echo "${scriptDir}###${execScript}###${scriptArgs}###${resultCheck}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`;
       exit 1; }
done<$resultCheck