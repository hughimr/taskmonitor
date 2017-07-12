#!/bin/bash
#从3点开始每隔30分钟运行 0,30 2-23 * * * 
#从/disk1/stat/user/liwu/qa/taskmonitor/sourcefail读任务来执行
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
toDoList=( `ls -t -r /disk1/stat/user/liwu/qa/taskmonitor/sourcefail` )

#循环处理
for task_i in ${toDoList[*]}
do 
    #提取参数
#${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}
    scriptDir=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $1}' `
    execScript=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $2}' `
    scriptArgs=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $3}' `
    sourceDataCheck=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $4}' `
    rerunTimes=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $5}' `
    resultCheck=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $6}' `
    mailTo=`cat /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i}|awk -F '###' '{print $7}' `
    
    rm /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/${task_i};
    #检查源条件,如果条件通过就运行脚本 
    cd ${scriptDir}
    if [[ ${sourceDataCheck} != "" ]]
    then
    while read -r line
    do 
        [[ -z ${line} ]] && continue
        TestEachCondition.sh ${line} || {
            echo "依赖源数据检查不通过：失败条件为 ${line} " ;
            LogTool "依赖源数据检查不通过：不通过条件为 ${line} ";
            echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${mailTo}">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
                exit 1; }
    done<${sourceDataCheck}
    fi
    LogTool "源数据检查通过，开始进入RunSourceMain.sh程序"
    nohup sh RunSourceMain.sh "${scriptDir%/}/$execScript ${scriptArgs}" "$rerunTimes" "$resultCheck" "$mailTo" &
done

