#!/bin/bash



scriptDir=$(pwd)
execScript="run.sh"
scriptArgs="a b c 12"


##查找定时任务中的crond任务
pids=$(pstree -ap |grep "[|]-crond"|cut -d ',' -f 2)


#一个小trick:去掉args中的多余空格，使之与后台形式保持一致
argsM=$(echo ${scriptArgs})
for _i in ${pids[*]};do
#查找crond任务中是否有该任务正在执行，要加上args 条件，才能一次运行比如好几天的数据
taskIsExist=($(pstree -apl ${_i} | grep ${scriptDir} |grep ${execScript} |grep ${argsM}))

if [ -n "${taskIsExist}" ];then
    echo "该脚本正在后台执行！请先Kill掉！"
    echo "后台任务详情：${taskIsExist[*]}"
    exit 1
    fi

done

##查看sourcefail目录下是否有待手动执行的任务在等待，如果有就删掉，然后手动执行
taskFiles=($(grep -l "${scriptDir}###${execScript}###${scriptArgs}" /disk1/stat/user/liwu/qa/taskmonitor/sourcefail/* ))
if [ -n "${taskFiles}" ];then
#删掉sourcefail目录下找到的任务，用“文件夹###文件名”匹配
LogTool "手动执行重跑任务过程删掉的任务为：$(cat ${taskFiles[*]})"
rm ${taskFiles[*]}
fi

