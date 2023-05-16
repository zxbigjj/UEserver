#coding=utf-8
import os
import time,datetime
import os.path
import json
import urllib2
import binascii
import hashlib
import subprocess

import gevent, gevent.monkey
gevent.monkey.patch_all()

this_dir = os.path.dirname(os.path.abspath(__file__))

import bottle
from bottle import run, route, template, redirect, static_file
from bottle import request, response

root = os.path.dirname(os.path.abspath(__file__))
bottle.TEMPLATE_PATH = [os.path.join(root, 'views')]

@route('/hello')
def hello():
    return "World!"

@route('/static/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root=root+"/static")


@route('/')
def main():
    redirect("/hello")

run(host='0.0.0.0', port=10115, server="gevent", debug=False)
