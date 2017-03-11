#!/bin/bash
if [ "$1" = "restart" ];then
echo "restarting FNServer server"
thin stop
thin start -p 8900 -d -l access.log
fi

if [ "$1" = "stop" ];then
echo "stop FNServer server"
thin stop
fi

if [ "$1" = "start" ];then
echo "starting FNServer server"
thin start -p 8900 -d -l access.log
fi
