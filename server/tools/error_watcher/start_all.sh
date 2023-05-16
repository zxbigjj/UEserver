#/bin/bash

cd /home/haojisheng
cd commserver/server/tools/error_watcher/
nohup python error_watch.py > watch.log 2>&1 &

cd /home/haojisheng
cd cehua_server/server1/server//tools/error_watcher/
nohup python error_watch.py > watch.log 2>&1 &

cd /home/haojisheng
cd cehua_server/server2/server//tools/error_watcher/
nohup python error_watch.py > watch.log 2>&1 &
