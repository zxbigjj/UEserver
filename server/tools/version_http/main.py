#coding=utf-8
from crypt import methods
from bottle import request, response
from bottle import run, route, template, redirect, static_file
import bottle
import os
import time
import datetime
import os.path
import json
import string
import urllib2
import binascii
import hashlib
import subprocess
import requests

import gevent
import gevent.monkey
gevent.monkey.patch_all()

this_dir = os.path.dirname(os.path.abspath(__file__))


root = os.path.dirname(os.path.abspath(__file__))
bottle.TEMPLATE_PATH = [os.path.join(root, 'views')]


@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root=root+"/static")


@route('/update_static', method='POST')
def update_static():
    key = 'bHDsfXPt26Tjr35pXJHwVHxHXFsfCNGe'
    ts = request.json.get('ts')
    sign = request.json.get('sign')
    args = request.json.get('args')

    md5 = hashlib.md5()
    md5.update('ts=%s&key=%s&args=%s' % (ts, key, json.dumps(args)))
    if md5.hexdigest() != sign:
        return json.dumps({'err': '签名错误'})

    channel_list = ['ios', 'android']

    import io
    for channel in channel_list:
        with io.open((root + '/static/version/' + channel), 'w', encoding='utf-8') as static_file:
            static_file.write(json.dumps(args[channel], ensure_ascii=False))

    return {'info': '更新完成'}


run(host='0.0.0.0', port=10116, server="gevent", debug=False)
