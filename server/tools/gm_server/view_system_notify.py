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


@route('/view_system_notify')
@check_user("system_notify")
def view_system_notify(user):
    return template("system_notify", curr_user=user, **(view_utils.all_funcs))
