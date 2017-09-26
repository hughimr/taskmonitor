#!/bin/bash
source /disk1/stat/user/liwu/qa/taskmonitor/bin/LogTool.sh
#set -x
#用法
USAGE(){
echo "Usage : `basename $0` -s \"XXX\" -r \"XXX\" -m \"XXX\" -e \"XXX\" -n XXX -a \"XXX XXX\""
echo "-e -m 这2个参数是必须要的。其它参数可选"
echo -e "\t-s:检查依赖数据的文件全路径\n"
echo -e "\t-r:检查结果数据的文件全路径\n"
echo -e "\t-m:出错告警信息的邮件收件人\n"
echo -e "\t-e:需要执行的脚本文件\n"
echo -e "\t-n:出错重跑次数\n"
echo -e "\t-a:传入脚本文件的执行参数\n"
echo -e "示例：\n
    1. RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" \n
    2.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -n 3  \n
    3.RunMonitor.sh -e \"test.sh\" -a \"ios 2017-04-01 \" -m \"gzliwu@91tianchen.com\" \n
    4.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" \n
    5.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" \n
    6.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" "
}

#初始化参数

#------------------------------------------------------------
##获取参数值
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
## 判断输入参数
if [[ $# -eq 0 || ${execScript} = "" || ${alertMailSendTo} = "" ]];
then
    echo "至少需要输入 -e -m 参数"
    USAGE
    exit 1
fi

scriptDir=`pwd`
rerunTimes=${rerunTimes:-1}

if [ ! -e ${scriptDir}/${execScript} ];then
    echo "目录${scriptDir}下不存在文件$execScript"
    LogTool "配置的任务检查不通过！目录${scriptDir}下不存在文件$execScript"
    exit 1
fi
LogTool "任务配置格式检查通过！配置的任务为：${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}"
#------------------------------------------------------------
if [[ ${sourceDataCheck} != "" ]]
then
##检查任务依赖数据源.如果检查失败就把数据任务写到失败目录下的文件中，待重跑.
#此处不发告警邮件
while read -r line
do
    [[ -z ${line} ]] && continue
    TestEachCondition.sh ${line} || {
        echo "依赖源数据检查不通过：失败条件为 $line" ;
        LogTool "依赖源数据检查不通过！不通过的条件为 $line" ;
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/sourcefail/task$RANDOM.`date +"%F_%T"`
            exit 1; }
done<${sourceDataCheck}
fi

cd ${scriptDir}
#------------------------------------------------------------
##执行脚本函数
#执行失败就发告警邮件
LogTool "开始执行RunMain.sh程序"
RunMain.sh "${scriptDir%/}/$execScript ${scriptArgs}" "$rerunTimes" "$alertMailSendTo"
if [ $? -eq 0 ]
then LogTool "RunMain.sh 无错误执行完毕！用户主程序 $execScript 监控执行完毕！"
else LogTool "RunMain.sh 未成功执行！一般能的。考虑是不是机器死掉了。"
fi
#------------------------------------------------------------
#检查任务执行结果。如果检查失败就把数据任务写到失败目录下的文件中，不重跑
#发告警邮件，直接人工处理。
mail_log=`pwd`/mail_log.$RANDOM
if [[ ${resultCheck} != "" ]]
then
while read -r line
do
    [[ -z ${line} ]] && continue
    sh -x TestEachCondition.sh "$line" || {
        echo "出错脚本程序为：${scriptDir%/}/$execScript ${scriptArgs}">${mail_log};
        echo "错误信息为：">>${mail_log}
        echo "执行结果检查不通过：失败条件为 $line" >>${mail_log};
        LogTool "执行结果检查不通过！不通过的条件为 $line";
        sendmail_monitor -s "脚本运行结果检测不通过告警" -t "$alertMailSendTo" -f "$mail_log";
        rm ${mail_log};
        echo "${scriptDir}###${execScript}###${scriptArgs}###${sourceDataCheck}###${rerunTimes}###${resultCheck}###${alertMailSendTo}">/disk1/stat/user/liwu/qa/taskmonitor/resultfail/task$RANDOM.`date +"%F_%T"`
        exit 1; }
done<${resultCheck}
fi

LogTool "监控程序已经全部执行完毕！cheers!"