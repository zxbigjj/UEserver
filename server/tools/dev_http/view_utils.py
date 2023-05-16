#!/usr/bin/env python
# -*- coding: utf-8 -*-
def get_view_class(view_name, child):
    ret = ""
    if child==view_name: ret += " active"
    return ret

all_funcs = {
    'get_view_class': get_view_class,
}
