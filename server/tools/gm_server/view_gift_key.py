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


@route('/view_gift_key')
@check_user("gift_key")
def view_gift_key(curr_user):
    return template("gift_key", curr_user=curr_user, **(view_utils.all_funcs))
