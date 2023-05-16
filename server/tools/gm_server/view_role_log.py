#!/usr/bin/env python
# -*- coding: utf-8 -*-
import json
import datetime
import time
from bottle import route, template, redirect
from bottle import request, response

import user_manager
from user_manager import check_user

import view_utils
import common_utils


@route('/view_role_log')
@check_user("role_log")
def view_role_log(curr_user):
    print('get role log')
    return template("role_log", curr_user=curr_user, **(view_utils.all_funcs))
