#coding=utf-8
import op_server
from bottle import request, response
from bottle import run, route, template, redirect, static_file
import bottle
import os
import time
import datetime
import os.path
import json
import urllib2
import binascii
import hashlib
import subprocess

import gevent
import gevent.monkey
gevent.monkey.patch_all()

this_dir = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(os.path.abspath(__file__))
bottle.TEMPLATE_PATH = [os.path.join(root, 'views')]


@route('/hello')
def hello():
    return "Hello World!"


@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root=root+"/static")


CLIENT_ERROR = {}


@route('/client_error')
def client_error():
    errmsg = request.params.get("errmsg")
    if not errmsg:
        return
    if errmsg not in CLIENT_ERROR:
        CLIENT_ERROR[errmsg] = {"count": 1, "last_ts": datetime.datetime.now()}
    else:
        CLIENT_ERROR[errmsg]["count"] += 1
        CLIENT_ERROR[errmsg]["last_ts"] = datetime.datetime.now()


@route('/all_client_error')
def all_client_error():
    items = CLIENT_ERROR.items()
    items.sort(key=lambda x: x[1]["last_ts"], reverse=True)
    lines = []
    for item in items:
        lines.append("%s   ====>%s<====" %
                     (item[1]["last_ts"], item[1]["count"]))
        lines.append(item[0])
    return "<br>".join(lines)


@route('/cluster_router')
def cluster_router():
    return static_file('cluster_router', root=root+"/static")


@route('/')
def main():
    redirect("/index")


###################################  index


@route('/index')
def index():
    import view_utils
    return template("index",
                    server_list=op_server.SERVER_LIST,
                    **(view_utils.all_funcs))


@route('/op_server', method='post')
def do_op_server():
    server_id = request.params.get("server_id")
    op = request.params.get("op")
    server_id = int(server_id)
    ok, err = op_server.do_op(op, server_id)
    if not ok:
        return {"err": err}
    return {}


@route('/check_server_op', method="post")
def check_server_op():
    server_id = int(request.params.get("server_id"))
    finish, info = op_server.check_server_op(server_id)
    return {'finish': finish, 'info': info}


###################################  test_page
@route('/test_page')
def test_page():
    import view_utils
    return template("test_page", **(view_utils.all_funcs))


run(host='0.0.0.0', port=30081, server="gevent", debug=False)
