#!/usr/bin/env python
# -*- coding: utf-8 -*-
def get_view_class(view_name, child, user):
    ret = ""
    if child == view_name:
        ret += " active"
    if not user.check_power(view_name):
        ret += " disabled"
    return ret


all_funcs = {
    'get_view_class': get_view_class,
}
