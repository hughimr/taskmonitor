������ϵͳʵ�ֵĹ��ܣ�
    1.�������Դ�������ͨ�������񱾴β����У���������������б�
    2.�������硢hive����Ⱥ�����⵼������ִ��ʧ�ܣ��Զ����ܣ�ͬʱ���͸澯�ʼ�������Ҫ�˹���Ԥ���ܡ�
    3.�������ִ�н���������ͨ����ֱ�ӷ��͸澯�ʼ����˹������˴������Զ����ܣ���
    4.ÿ��Сʱ����������������Դ��ͨ���Ĵ�ִ�������б������������е��Ⱥ�˳��ִ�У���
�Զ��幦�ܣ�  
    1.���������������ܴ�����
    2.�������Դ�ͼ������ִ�н��������������ѡ��Ҳ����˵����ֱ�����нű����������ܣ���
    
��������ĸ�ʽ��
�����������ݵĴ��λ�÷�����д������������������ʽ��Ŀǰֻ֧��hive���ݵļ�飩��
--ddb��
--hive�����hiveĳ������߷����ļ�¼���Ƿ����0
    ��ʽΪ��hive##database.table_name##������Ϣ��������Ƿ������Ϊ�գ�
    ����
        hive##gzkdb.kdb_order_buy_detail##ds=''date +%F -d "-1 day"''
        hive##gzkdb.kdb_order_buy_detail##
        hive##gzkdb.kdb_order_buy_detail##ds<=''date +%F -d "-1 day"'' and ds>=''date +%F -d "-10 day"''
--oracle��
--mysql��
--file��


��س���ʹ�÷�����
 RunMonitor.sh -s "XXX" -r "XXX" -m "XXX" -e "XXX" -d XXX -n XXX -a "XXX XXX"
-e -m ��2�������Ǳ���Ҫ�ġ�����������ѡ
	-s:����������ݵ��ļ�ȫ·��

	-r:��������ݵ��ļ�ȫ·��

	-m:����澯��Ϣ���ʼ��ռ���

	-e:��Ҫִ�еĽű��ļ�

	-n:�������ܴ���


	-a:����ű��ļ���ִ�в���

ʾ����

    1. RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" \n
    2.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -n 3  \n
    3.RunMonitor.sh -e \"test.sh\" -a \"ios 2017-04-01 \" -m \"gzliwu@91tianchen.com\" \n
    4.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" \n
    5.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -s \"/disk1/stat/user/liwu/qa/test/test_source\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" \n
    6.RunMonitor.sh -e \"test.sh\" -m \"gzliwu@91tianchen.com\" -r \"/disk1/stat/user/liwu/qa/test/test_result\" 

�Ժ������ö�ʱ�����ʱ����������ʽ��
30 07 * * * (/bin/bash -lc 'cd /disk1/stat/user/liwu/qa/qa230083;RunMonitor.sh  -e "test.sh" -m "gzliwu@91tianchen.com" 1>>run.log 2>>run.err') 