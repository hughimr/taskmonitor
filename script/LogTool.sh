#!/bin/bash
#���÷�ʽ��LogTool.sh

_curTime='date +"%F %T"'


LogTool(){
    if [ ! -e taskmonitor.log  -a `pwd` != $HOME ]
    then touch taskmonitor.log
    fi
    echo "$(eval ${_curTime}) [ ��ǰ�ļ���$0 ] $*" >>taskmonitor.log

}