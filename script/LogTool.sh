#!/bin/bash
#���÷�ʽ��LogTool.sh

_curTime='date +"%F %T"'
if [ ! -e taskmonitor.log ]
then touch taskmonitor.log
fi

LogTool(){
    echo "$(eval ${_curTime}) [ ��ǰ�ļ���$0 ] $*" >>taskmonitor.log

}