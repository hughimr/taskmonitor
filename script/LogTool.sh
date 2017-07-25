#!/bin/bash
#调用方式：LogTool.sh

_curTime='date +"%F %T"'


LogTool(){
    if [ ! -e taskmonitor.log  -a `pwd` != $HOME ]
    then touch taskmonitor.log
    fi
    echo "$(eval ${_curTime}) [ 当前文件：$0 ] $*" >>taskmonitor.log

}