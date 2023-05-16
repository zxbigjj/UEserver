#!/bin/bash

DB="zc_"

IP="127.0.0.1"
PORT=4000
USERNAME="root"
TABLENAME="t_Family"  

declare -A server_mapper 
server_mapper=( [haojisheng]="game3"
                [liweiping]="game4"
                [yuanxixian]="game6"
                [suweisheng]="game7")

if [ $# -eq 0 ];then
	echo "no arguments, use server_mapper now...."
	server=`whoami`
else
	echo "have arguments, use args1 now..."
	server=$1
fi

echo "关闭服务器"
python ./shutdown_server.py

node=${server_mapper[${server}]}

DBName=${DB}${node}

# select_sql="select * from ${TABLENAME}"
# delete_sql="delete from ${TABLENAME}"

# mysql -h${IP} -P${PORT} -u${USERNAME} ${DBName} -e "${delete_sql}"
# mysql -h${IP} -P${PORT} -u${USERNAME} ${DBName} -e "${select_sql}"

echo "删除数据库开始"
drop_sql="drop database ${DBName}"
mysql -h${IP} -P${PORT} -u${USERNAME} ${DBName} -e "${drop_sql}"
echo "删除数据库结束,等待5秒重启"

sleep 5s

echo "服务器开始重启"
python ./start_server.py