#!/bin/bash
#检查执行结果条件是否满足
resultCheck=$1

while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
       echo "执行结果检查不通过：失败条件为 $line" ;
       echo "${scriptDir}###${execScript}###${scriptArgs}###${resultCheck}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`;
       exit 1; }
done<$resultCheck