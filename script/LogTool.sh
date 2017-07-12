#!/bin/bash
#调用方式：LogTool.sh

_curTime='date +"%F %T"'
if [ ! -e taskmonitor.log ]
then touch taskmonitor.log
fi

LogTool(){
    echo "$(eval ${_curTime}) [ 当前文件：$0 ] $*" >>taskmonitor.log

}