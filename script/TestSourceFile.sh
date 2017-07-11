#!/bin/bash
#检查源数据文件条件是否满足
sourceDataCheck=$1

while read -r line
do 
    [ -z $line ] && continue 
    TestEachCondition.sh $line || { 
        echo "依赖源数据检查不通过：失败条件为 $line" ;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###$resultCheck">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
            exit 1; }
done<$sourceDataCheck
fi
