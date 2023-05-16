#/bin/bash

##################################################################
# auther: 刘宽 2016-09-05 
# ftp数据传输脚本
# 日志名称格式： 游戏名-日期-自定义...
# 				 例如： qz-20160905-*
# 三个参数：
# 	1，文件所在路径（必填）
#   2，日期，格式为yyyyMMdd， 例如20160905（可选，不传默认前一天，在使用自定义md5验证文件名的时候必填）
#   3，md5验证文件文件名称（可选， 如果使用， 不能省略日期）
#
# 额外配置：
#   除了两个参数除外， 还要额外配置一个日志文件格式 log_name_format
#   默认为 * ， 表示通配文件所在路径下面所有的文件
#   可修改为： log_name_format=qz-$dateStr-* （可自定义）
#
# 使用样例：
#   sendfile.sh 传递日志路径（必填） 日志生成日期（可选， 不传默认前一天， 在使用自定义md5验证文件名的时候必填）自定义md5文件名称（可选， 默认为 md5.list， 如果自定义此选项， 日志生成日期必填）
# (假设当前日期为 2016年09月09日)：
#   sendfile.sh /data/log   表示传递 /data/log 目录下所有满足通配规则的文件， 并在ftp服务器上创建一个以20160908为文件名的目录， 并将文件传输到ftp的新创建的目录下， md5验证文件名为 md5.list
#   sendfile.sh /data/log 20160901   表示传递 /data/log 目录下目录下所有满足通配规则的文件， 并在ftp服务器上创建一个以20160901为文件名的目录， 并将文件传输到ftp的新创建的目录下 md5验证文件名为 md5.list
#   sendfile.sh /data/log 20160901 mydefind.log   表示传递 /data/log 目录下目录下所有满足通配规则的文件， 并在ftp服务器上创建一个以20160901为文件名的目录， 并将文件传输到ftp的新创建的目录下 md5验证文件名为 mydefine.list
# 注意：
#   如果要自定义md5验证文件名， 日期必须填写， 不能为空， 否则会因为无法分辨参数而导致运行失败
#
##################################################################

# 传入参数
dir=$1
dateStr=$2
md5filename=$3

[ -z "$dateStr" ] && dateStr=`date -d'-1 day' +'%Y%m%d'`
[ -z "$md5filename" ] && md5filename='md5.list'

# 配置项
# host: ftp 服务器地址
host='123.56.224.67 21212'
# user 和 passwd: ftp服务的账户和密码
user='quanminyushi'
passwd='Cixo98dDvh12bE9Fbqd'
# 日志传入目录
log_name_format='*.zip'
# $1 路径 $2 日期
################################################################

# linux 下用 md5sum , mac 是 md5
md5='/usr/bin/md5sum'
#command -v $md5 >/dev/null 2>&1 || { echo >&2 "I require $md5 but it's not installed.  Aborting."; exit 1; }

# 使用脚本错误的提示方法
usage() {
	echo "$0 [log_file_path] [date] [md5filename]"
	echo "  log_file_path 必选项，需要传输的文件的路径，如 /data/log/"
	echo "  date 可选，指定日期的日志，如$dateStr"
    echo "  md5filename 可选，指定md5的文件名称"
    echo "  注意：如果自定义md5filename， date 一定不准为空"
    echo "  例如： sendfile.sh /root/log/ 等同于 sendfile.sh /root/log/  `date -d'-1 day' +'%Y%m%d'`（日期默认为前一天） md5.list（md5验证文件名默认为 md5.list）"
    echo "  如果希望使用自定义的md5验证文件名， 则日期不可以省略（具体使用方法请查看脚本说明）"
	exit 1
}

[ $# -lt 1 ] && usage
[ $# -gt 3 ] && usage

if test ! -d $dir ; then
	echo "目录不存在 $dir"
    usage
fi


# 生成MD5文件
for file in $dir/$log_name_format
do
	if test -f $file
	then
		filelength=`stat --format=%s $file`
		md5=`/usr/bin/md5sum $file | cut -d ' ' -f1` 
		filename=`echo $(basename $file)`
		line=$filename' '$md5' '$filelength
		echo $line >> $1/$md5filename
	fi
done



#shell for ftp
/usr/bin/ftp > /dev/null 2>&1 -n << EOF
open $host
user $user $passwd
binary
hash
# mkdir $dateStr
# cd $dateStr
lcd $1
prompt
mput $log_name_format
# put $md5filename
close
bye
EOF

echo "send complete .."

sleep 1


# curl 请求校验
#curl -X POST https://$host:9999/ftpcheck/$user/$dateStr/$md5filename > $dir/result.log
#curl -X POST http://172.18.3.214:9999/ftpcheck/$user/$dateStr/$md5filename >> $dir/result.log

# ftp传输结束 删除MD5文件
rm -f $1/md5.list
exit 0
