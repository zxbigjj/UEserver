#!/usr/bin/env python
# -*- coding: utf-8 -*-
import string
import time
import random
import hashlib

import bson
from pymongo import MongoClient

import config

_client = None
_db = None


def init():
    global _client, _db
    _client = MongoClient(config.mongo_host, config.mongo_port)
    _db = _client.wpys_gm


def find_one(cname, query):
    return _db[cname].find_one(query)


def find(cname, query=None, **kwargs):
    return _db[cname].find(query, **kwargs)


def insert_one(cname, doc):
    return _db[cname].insert_one(doc)


def delete_one(cname, _filter):
    return _db[cname].delete_one(_filter)


def update_one(cname, _filter, update):
    return _db[cname].update_one(_filter, update)


def replace_one(cname, _filter, update):
    return _db[cname].replace_one(_filter, update)


class SimpleDbBase(object):
    KEY_NAME = ""
    DB_NAME = ""
    CACHE = {}

    def __init__(self, data):
        for k, v in data.items():
            if k == "_id":
                setattr(self, self.KEY_NAME, str(v))
            else:
                if type(v) == unicode:
                    v = v.encode("utf8")
                setattr(self, k, v)
        self.CACHE[getattr(self, self.KEY_NAME)] = self

    def save(self):
        doc = self.__dict__
        _id = bson.ObjectId(getattr(self, self.KEY_NAME))
        replace_one(self.DB_NAME, {"_id": _id}, doc)

    def delete(self):
        _id = bson.ObjectId(getattr(self, self.KEY_NAME))
        delete_one(self.DB_NAME, {"_id": _id})
        self.CACHE.pop(getattr(self, self.KEY_NAME))

    @classmethod
    def load(cls, query):
        data = find_one(cls.DB_NAME, query)
        if data:
            obj = cls(data)
            return obj

    @classmethod
    def load_all(cls):
        for data in find(cls.DB_NAME):
            cls(data)

    @classmethod
    def create(cls, data, check_field):
        obj = cls.get_by_field(check_field, data[check_field])
        if obj:
            raise RuntimeError(check_field + ":" +
                               data[check_field] + " has exists")
        result = insert_one(cls.DB_NAME, data)
        _id = result.inserted_id
        # 再次检查
        if cls.get_by_field(check_field, data[check_field]):
            delete_one({"_id": _id})
            raise RuntimeError(check_field + ":" +
                               data[check_field] + " has exists")
        # ok
        data["_id"] = _id
        obj = cls(data)
        # 再保存一次
        obj.save()
        return obj

    @classmethod
    def get_all(cls):
        return cls.CACHE

    @classmethod
    def get_by_key(cls, key):
        return cls.CACHE.get(key)

    @classmethod
    def get_by_field(cls, field_name, field_value):
        for k, v in cls.CACHE.iteritems():
            if getattr(v, field_name) == field_value:
                return v
