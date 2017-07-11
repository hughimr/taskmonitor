任务监控系统实现的功能：
    1.监控数据源。如果不通过，任务本次不运行，进入待运行任务列表
    2.由于网络、hive、集群等问题导致任务执行失败，自动重跑，同时发送告警邮件。不需要人工干预重跑。
    3.监控任务执行结果。如果不通过，直接发送告警邮件供人工处理（此处不会自动重跑）。
    4.每半小时启动进程运行数据源不通过的待执行任务列表（按任务进入队列的先后顺序执行）。
自定义功能：  
    1.可以主动设置重跑次数。
    2.监控数据源和监控任务执行结果，两个参数可选（也就是说可以直接运行脚本，错误重跑）。
    
监控条件的格式：
条件按照数据的存放位置分类书写。初步有以下五种形式（目前只支持hive数据的检查）：
--ddb：
--hive：检查hive某个表或者分区的记录数是否大于0
    格式为：hive##database.table_name##分区信息（如果不是分区表就为空）
    例：
        hive##gzkdb.kdb_order_buy_detail##ds=''date +%F -d "-1 day"''
        hive##gzkdb.kdb_order_buy_detail##
        hive##gzkdb.kdb_order_buy_detail##ds<=''date +%F -d "-1 day"'' and ds>=''date +%F -d "-10 day"''
--oracle：
--mysql：
--file：


监控程序使用方法：
 RunMonitor.sh -s "XXX" -r "XXX" -m "XXX" -e "XXX" -d XXX -n XXX -a "XXX XXX"
-e -m 这2个参数是必须要的。其它参数可选
	-s:检查依赖数据的文件全路径

	-r:检查结果数据的文件全路径

	-m:出错告警信息的邮件收件人

	-e:需要执行的脚本文件

	-n:出错重跑次数


	-a:传入脚本文件的执行参数

示例：

    1. RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" \n
    2.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -n 3  \n
    3.RunMonitor.sh -e \"test.sh\" -a \"ios 2017-04-01 \" -m \"gzliwu@91tianchen.com\" \n
    4.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" \n
    5.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" \n
    6.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" 

稍后大家配置定时任务的时候用这种形式：
30 07 * * * (/bin/bash -lc 'cd /disk1/stat/user/liwu/qa/qa230083;RunMonitor.sh  -e "test.sh" -m "gzliwu@91tianchen.com" 1>>run.log 2>>run.err') 