#!/bin/bash
#条件有五种形式：
#--ddb
#--hive
#--oracle
#--mysql
#--file
#--run
#condition的形式为hive##gzkdb.kdb_order_buy_detail##ds='``date +%F -d "-1 day"'
condition=${@//\\/\\\\}
condition=${condition//\|/\\\|}
condition=${condition//\'/\\\'}
condition=${condition//\</\\\<}
condition=${condition//\>/\\\>}
source=$(eval echo ${condition}|awk -F '##' '{print $1}')

case ${source} in
    hive )  
        name=$(eval echo ${condition}|awk -F '##' '{print $2}')
        restrictions=$(eval echo ${condition}|awk -F '##' '{print $3}')
        if [[ ! -z "$restrictions" ]];then 
            result=`hive -S -e "set hive.exec.mode.local.auto=true;
                select * from $name where $restrictions limit 1;"`
        else 
            result=`hive -S -e "set hive.exec.mode.local.auto=true;
                select * from $name limit 1;"`
        fi 
        if [ -n "$result" ];then 
            exit 0
        else 
            exit 1 
        fi ;;
    oracle )
        exec_tool=$(eval echo ${condition}|awk -F '##' '{print $2}')
        table=$(eval echo ${condition}|awk -F '##' '{print $3}')
        columns=$(eval echo ${condition}|awk -F '##' '{print $4}')
        restrictions=$(eval echo ${condition}|awk -F '##' '{print $5}')
        if [[ -n "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -e "select $columns from $table where $restrictions;"`
        elif [[ -n "$restrictions" &&  -z "$columns" ]];then 
            result=`${exec_tool} -e "select * from $table where $restrictions;"`
        elif [[ -z "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -e "select $columns from $table;"`
        else
            result=`${exec_tool} -e "select * from $table;"`
        fi 
        if [ -n "$result" ];then 
            exit 0
        else 
            exit 1 
        fi ;;
    ddb )
        exec_tool=$(eval echo ${condition}|awk -F '##' '{print $2}')
        table=$(eval echo ${condition}|awk -F '##' '{print $3}')
        columns=$(eval echo ${condition}|awk -F '##' '{print $4}')
        restrictions=$(eval echo ${condition}|awk -F '##' '{print $5}')
        if [[ -n "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -s "select $columns from $table where $restrictions;"`
        elif [[ -n "$restrictions" &&  -z "$columns" ]];then 
            result=`${exec_tool} -s "select * from $table where $restrictions;"`
        elif [[ -z "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -s "select $columns from $table;"`
        else
            result=`${exec_tool} -s "select * from $table;"`
        fi 
        if [ -n "$result" ];then 
            exit 0
        else 
            exit 1 
        fi ;;
    mysql )
        exec_tool=$(eval echo ${condition}|awk -F '##' '{print $2}')
        table=$(eval echo ${condition}|awk -F '##' '{print $3}')
        columns=$(eval echo ${condition}|awk -F '##' '{print $4}')
        restrictions=$(eval echo ${condition}|awk -F '##' '{print $5}')
        if [[ -n "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -s -e "select $columns from $table where $restrictions;"`
        elif [[ -n "$restrictions" &&  -z "$columns" ]];then 
            result=`${exec_tool} -s -e "select * from $table where $restrictions;"`
        elif [[ -z "$restrictions" &&  -n "$columns" ]];then 
            result=`${exec_tool} -s -e "select $columns from $table;"`
        else
            result=`${exec_tool} -s -e "select * from $table;"`
        fi 
        if [ -n "$result" ];then 
            exit 0
        else 
            exit 1 
        fi ;;
    file )
        file_name=$(eval echo ${condition}|awk -F '##' '{print $2}')
        sep=$(eval echo ${condition}|awk -F '##' '{print $3}')
        row_number=$(eval echo ${condition}|awk -F '##' '{print $4}')
        column_number=$(eval echo ${condition}|awk -F '##' '{print $5}')
        if [ ! -e ${file_name} ];then
        exit 1
        fi 
        result=`awk -F "[$sep]" -v rn=${row_number} -v cn=${column_number} 'NR==rn{print $cn}' ${file_name}`
        if [ -n "$result" ];then 
            exit 0
        else 
            exit 1 
        fi ;;
    run )
        script=$(eval echo ${condition}|awk -F '##' '{print $2}')
        if [ ! -e ${script} ];then
        exit 1
        fi 
        bash  ${script}
        if [ $? -eq 0 ];then 
        exit 0
        else 
        exit 1
        fi ;;
        
    *) exit 1 ;;
    esac 