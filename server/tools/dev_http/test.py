# #coding=utf-8
# import op_server
# from bottle import request, response
# from bottle import run, route, template, redirect, static_file
# import bottle
# import os
# import time
# import datetime
# import os.path
# import json
# import urllib2
# import binascii
# import hashlib
# import subprocess

# import gevent
# import gevent.monkey

# print(os.listdir("/GameServer/game"))

# This is test msg


import pymysql

# 打开数据库连接
db = pymysql.connect(host='localhost',
                     user='DbUserGroup',
                     password='85SkL547P6we5bWj',
                     database='dbusergroup')

# 使用 cursor() 方法创建一个游标对象 cursor
cursor = db.cursor()

# 使用 execute()  方法执行 SQL 查询
cursor.execute("SELECT VERSION()")

# 使用 fetchone() 方法获取单条数据.
data = cursor.fetchone()

print("Database version : %s " % data)

# 关闭数据库连接
db.close()
