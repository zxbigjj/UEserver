#encoding=utf8
import os
import os.path
import shutil
import string
import re
import sys

import xlrd
FIELD_NAME_ROW = 3
FIELD_TYPE_ROW = 4
FIELD_CHECKER_ROW = 5
FIELD_BODY_START_ROW = 6

VALUE_SPLIT = "/"
STRING_SPLIT = '//'

CLIENT_DIR = '../data/client'
SERVER_DIR = '../data/server'
TEMP_LUA_PATH = "../data/temp_lua_data"

ALL_RAW_TYPE = [
    "bool", "int", "float", "string", "lang",
    "bool_list", "int_list", "float_list", "string_list", "lang_list",
]

ALL_CHECKER = {
    "key":          [], #主键
    "uniq":         [], #不重复
    "ref":          ["string"],    #引用其他表
    "ref_count":    ["string"],    #引用其他表, 加数量
    "ignore":       [],     #忽略这个字段
    "no2lua":       [],     # 整张表不导出lua
    "size":         ["string"],     #检查两个字段长度是否相同
    "no_empty":     [], # 不能为空
    "group_by":     [], #掉落表特殊处理
    "table":        [], #字段转为lua表
    "len":          ["int"] #检查列表长度
}

# 解析结果
ALL_TABLE = {}

#掉落特殊处理
GROUP_TABLE = ["DropGroupData", "DropData"]

def TIPS(*tips_list):
    tips_list = list(tips_list)
    for i, tips in enumerate(tips_list):
        if type(tips) == str:
            for code in ["utf8", "gb2312"]:
                try:
                    tips_list[i] = tips.decode(code)
                    break
                except:
                    pass
        elif type(tips) == unicode:
            pass
        else:
            tips_list[i] = unicode(tips)
    if sys.platform == 'win32':
        return u','.join(tips_list)
    else:
        return u','.join(tips_list).encode("utf8")

def ERROR(*tips_list):
    tips_list = list(tips_list)
    for i, tips in enumerate(tips_list):
        if type(tips) == str:
            for code in ["utf8", "gb2312"]:
                try:
                    tips_list[i] = tips.decode(code)
                    break
                except:
                    pass
        elif type(tips) == unicode:
            pass
        else:
            tips_list[i] = unicode(tips)
    for i, tips in enumerate(tips_list):
        if sys.platform == 'win32':
            print tips
        else:
            print tips.encode("utf8")
    
    print "=" * 80
    if sys.platform == 'win32':
        print u','.join(tips_list)
    else:
        print u','.join(tips_list).encode("utf8")
    print "=" * 80
    raise RuntimeError()

# excel表列编号(0开始)转换到字母
def col_index2name(index):
    letters = string.letters[26:]
    if index < 26:
        return     letters[index % 26]
    return letters[index / 26 - 1] + letters[index % 26]

class FieldChecker(object):
    def __init__(self, name, args):
        self.name = name
        self.args = args
        self.check_func = getattr(self, "check_" + name)

    def __eq__(self, other):
        if self.name != other.name:
            return False
        for a, b in zip(self.args, other.args):
            if a != b:
                return False
        return True

    @staticmethod
    def parse(text):
        text = text.strip()
        if "(" not in text:
            name = text
            args = []
        else:
            left, right = text.find("("), text.find(")")
            if right < 0:
                return u"缺少右括号"
            name = text[:left]
            args = [x.strip() for x in text[left+1:right].split(",")]
        if name not in ALL_CHECKER:
            return u"不支持的逻辑检查"
        if len(args) != len(ALL_CHECKER[name]):
            return u"参数数量不对"
        for i in range(len(args)):
            ty = ALL_CHECKER[name][i]
            if ty == "int":
                try:
                    args[i] = int(args[i])
                except:
                    return u"第%d个参数应该是整数" % (i+1)
            if ty == "float":
                try:
                    args[i] = float(args[i])
                except:
                    return u"第%d个参数应该是浮点数" % (i+1)
        return FieldChecker(name, args)

    def check_key(self, table, field):
        return self.check_uniq(table, field)

    def check_uniq(self, table, field):
        field_name = field.field_name
        uniq_set = set()
        for key, config in table.config_dict.iteritems():
            if field_name not in config:
                continue
            value = config[field_name]
            if value in uniq_set:
                ERROR(u"字段不唯一", table.table_name, field_name, key, value)
            uniq_set.add(value)

    def check_ignore(self, table, field):
        field_name = field.field_name
        for key, config in table.config_dict.iteritems():
            config.pop(field_name, None)
    def check_len(self, table, field):
        field_name = field.field_name
        num = self.args[0]
        for key, config in table.config_dict.iteritems():
            if field_name not in config:
                continue
            value = config[field_name]
            if len(value) != num:
                ERROR(u"列表长度不对", table.table_name, field_name, key, value)

    def check_no_empty(self, table, field):
        # 解析的时候检查
        pass

    def check_no2lua(self, table, field):
        table.no2lua = True

    def check_ref(self, table, field):
        field_name = field.field_name
        ref_table_name = self.args[0]
        ref_table = ALL_TABLE.get(ref_table_name)
        if not ref_table:
            ERROR(u"引用的表不存在", table.table_name, field_name, ref_table_name)
        if not ref_table.ch_key_name:
            ERROR(u"引用的表没有中文索引", table.table_name, field_name, ref_table_name)
        for key, config in table.config_dict.iteritems():
            if field_name not in config:
                continue
            value = config[field_name]
            if type(value) == list:
                new_list = []
                for v in value:
                    new_v = ref_table.ch_key2id(v)
                    if new_v is None:
                        ERROR(u"引用非法", table.table_name, field_name, ref_table_name, key, v)
                    else:
                        new_list.append(new_v)
                config[field_name] = new_list
            else:
                new_v = ref_table.ch_key2id(value)
                if new_v is None:
                    ERROR(u"引用非法", table.table_name, field_name, ref_table_name, key, value)
                else:
                    config[field_name] = new_v

    def check_ref_count(self, table, field):
        field_name = field.field_name
        ref_table_name = self.args[0]
        ref_table = ALL_TABLE.get(ref_table_name)
        if not ref_table:
            ERROR(u"引用的表不存在", table.table_name, field_name, ref_table_name)
        if not ref_table.ch_key_name:
            ERROR(u"引用的表没有中文索引", table.table_name, field_name, ref_table_name)
        for key, config in table.config_dict.iteritems():
            if field_name not in config:
                continue
            value = config[field_name]
            if type(value) == list:
                if len(value) % 2 == 1:
                    ERROR(u"引用count必须是偶数个string", table.table_name, field_name, ref_table_name, key, value)
                new_list = []
                for i in xrange(0, len(value), 2):
                    v = value[i]
                    new_v = ref_table.ch_key2id(v)
                    if new_v is None:
                        ERROR(u"引用非法", table.table_name, field_name, ref_table_name, key, v)
                    else:
                        new_list.append(new_v)
                        new_list.append(int(value[i+1]))
                config[field_name] = new_list
            else:
                ERROR(u"引用count必须是个string_list", table.table_name, field_name, ref_table_name, key, value)

    def check_size(self, table, field):
        field_name = field.field_name
        check_size_name = self.args[0]
        if check_size_name not in table.field_dict:
            ERROR(u"%s表中%s字段不存在" % (table.table_name, check_size_name))
        for key, config in table.config_dict.iteritems():
            if field_name not in config and check_size_name not in config:
                continue
            if field_name not in config and check_size_name in config:
                ERROR(u"%s表中第%s行两个关联字段%s和%s长度不相同" % (table.table_name, key, field_name, check_size_name))
            if field_name in config and check_size_name not in config:
                ERROR(u"%s表中第%s行两个关联字段%s和%s长度不相同" % (table.table_name, key, field_name, check_size_name))
            if len(config[field_name]) != len(config[check_size_name]):
                ERROR(u"%s表中第%s行两个关联字段%s和%s长度不相同" % (table.table_name, key, field_name, check_size_name))

    def check_group_by(self, table, field):
        pass

    def check_table(self, table, field):
        pass

class TableField(object):
    def __init__(self, field_name):
        self.field_name = field_name
        self.index = 0    # 列编号
        self.__raw_type = None        # 类型
        self.checker_list = []    # 检查

    def is_list(self):
        return self.__raw_type.endswith("list")

    def no_empty(self):
        for checker in self.checker_list:
            if checker.name == "no_empty":
                return True
        return False

    def is_table(self):
        for checker in self.checker_list:
            if checker.name == "table":
                return True
        return False

    @property
    def raw_type(self):
        return self.__raw_type
    @raw_type.setter
    def raw_type(self, value):
        self.__raw_type = value
        self.parse_value = getattr(self, "parse_" + value)

    def _bool(self, v):
        if type(v) == unicode:
            return True if v.lower() == "true" else False
        return bool(v)
    def _string(self, v):
        if type(v) == float:
            if int(v) == v:
                v = str(int(v))
            else:
                v = str(v)
        return v.strip()
    def parse_int(self, cell):
        if type(cell.value) != unicode:
            assert(int(cell.value) == cell.value)
        return int(cell.value)
    def parse_int_list(self, cell):
        if type(cell.value) == float:
            return [int(cell.value)]
        return [int(x) for x in cell.value.split(STRING_SPLIT)]
    def parse_float(self, cell):
        return float(cell.value)
    def parse_float_list(self, cell):
        value = cell.value
        if type(cell.value) == float:
            if int(cell.value) == cell.value:
                value = int(cell.value)
            return [value]
        return [float(x) for x in cell.value.split(STRING_SPLIT)]
    def parse_string(self, cell):
        return self._string(cell.value)
    def parse_string_list(self, cell):
        value = cell.value
        if type(cell.value) == float:
            if int(cell.value) == cell.value:
                value = str(int(cell.value))
            else:
                value = str(cell.value)
        return [x.strip() for x in value.split(STRING_SPLIT)]
    def parse_lang(self, cell):
        return "lang-%s" % self._string(cell.value)
    def parse_lang_list(self, cell):
        value = cell.value
        if type(cell.value) == float:
            if int(cell.value) == cell.value:
                value = str(int(cell.value))
            else:
                value = str(cell.value)
        return ["lang-%s" % self._string(x) for x in value.split(STRING_SPLIT)]
    def parse_bool(self, cell):
        return self._bool(cell.value)
    def parse_bool_list(self, cell):
        return [self._bool(x) for x in cell.value.split(STRING_SPLIT)]

class TableRow(dict):
    def __getattr__(self, name):
        return self[name]
    def __setattr__(self, name, value):
        self[name] = value

class ConfigTable(object):
    def __init__(self, table_name):
        self.table_name = table_name
        self.field_dict = {}
        self.key_name = None
        self.ch_key_name = "ch_key"

        self.no2lua = False

        self.sheet_list = []    # 原始的excel表对象
        self.config_dict = {}    # 所有数据， id做key
        self.ch_key_dict = {}    # 所有数据， ch_key做key

    def ch_key2id(self, ch_key):
        if ch_key not in self.ch_key_dict:
            return
        key_name = self.key_name
        if self.table_name in GROUP_TABLE:
            key_name = "group_id"
        return self.ch_key_dict[ch_key][key_name]

    def parse_field_name(self, filename, sheet, cindex):
        cell = sheet.cell(FIELD_NAME_ROW, cindex)
        if cell.ctype == xlrd.XL_CELL_EMPTY:
            # ERROR(u"列名没有", filename, sheet.name,
            #     u"%s列" % col_index2name(cindex), cell.value)
            return
        # 列名
        if cell.ctype != xlrd.XL_CELL_TEXT:
            ERROR(u"列名错误", filename, sheet.name,
                u"%s列" % col_index2name(cindex), cell.value)
        field_name = cell.value
        if not filename:
            return
        m = re.match("[a-zA-Z]\w+", field_name)
        if not m or m.end() != len(field_name):
            ERROR(u"列名不合法", filename, sheet.name,
                u"%s列" % col_index2name(cindex), cell.value)
        return field_name

    def parse_all_sheet(self):
        for filename, sheet in self.sheet_list:
            self.parse_sheet_header(filename, sheet)
        for filename, sheet in self.sheet_list:
            self.parse_sheet_body(filename, sheet)

    def parse_sheet_header(self, filename, sheet):
        # 解析表头
        print TIPS('parse_head', self.table_name, os.path.basename(filename), sheet.name)
        for cindex, cell in enumerate(sheet.row(FIELD_NAME_ROW)[1:], 1):
            field_name = self.parse_field_name(filename, sheet, cindex)
            if not field_name:
                break
            field = self.field_dict.get(field_name)
            if not field:
                field = TableField(field_name)
                field.index = len(self.field_dict)
                self.field_dict[field_name] = field
            # 列类型
            cell = sheet.cell(FIELD_TYPE_ROW, cindex)
            if cell.ctype != xlrd.XL_CELL_TEXT or cell.value not in ALL_RAW_TYPE:
                ERROR(u"列类型错误", filename, sheet.name,
                    u"%s列" % col_index2name(cindex), field_name, cell.value)
            if field.raw_type and field.raw_type != cell.value:

                ERROR(u"列类型冲突", filename, sheet.name,
                    u"%s列" % col_index2name(cindex), field_name, cell.value, field.raw_type)
            field.raw_type = cell.value
            # 逻辑检查
            cell = sheet.cell(FIELD_CHECKER_ROW, cindex)
            if cell.ctype != xlrd.XL_CELL_EMPTY:
                if cell.ctype != xlrd.XL_CELL_TEXT:
                    ERROR(u"列检查错误", filename, sheet.name,
                        u"%s列" % col_index2name(cindex), cell.value)
                for text in cell.value.split("$"):
                    if not text:
                        continue
                    checker = FieldChecker.parse(text)
                    if not isinstance(checker, FieldChecker):
                        ERROR(u"列检查错误", checker, filename, sheet.name,
                            u"%s列" % col_index2name(cindex), text)
                    if not [x for x in field.checker_list if x == checker]:
                        field.checker_list.append(checker)
                    if checker.name == "key":
                        self.key_name = field_name
            else:
                if cindex == 1:
                    ERROR(u"第二列逻辑检查不能留空，至少写个$key", filename, sheet.name)
            # 主键？
            if not self.key_name and cindex == 1:
                self.key_name = field_name

    def parse_sheet_body(self, filename, sheet):
        # 查找主键的第一个空
        start_row = FIELD_BODY_START_ROW
        end_row = FIELD_BODY_START_ROW
        all_rows = [None] * start_row
        for cell in sheet.col(1)[start_row:]:
            if cell.ctype == xlrd.XL_CELL_EMPTY:
                break
            all_rows.append(TableRow())
            end_row += 1
        # 解析数据
        for cindex, cell in enumerate(sheet.row(FIELD_NAME_ROW)[1:], 1):
            field_name = self.parse_field_name(filename, sheet, cindex)
            if not field_name:
                break
            field = self.field_dict[field_name]
            no_empty = field.no_empty()
            for rindex, cell in enumerate(sheet.col(cindex)[start_row:end_row], start_row):
                if cell.ctype == xlrd.XL_CELL_EMPTY or cell.value == " " or cell.value == "":
                    if no_empty:
                        ERROR(u"此列不能为空", filename, sheet.name, field_name, u"第%s行" % (rindex+1))
                    continue
                try:
                    value = field.parse_value(cell)
                except Exception,e:
                    ERROR(u"解析数据失败%s" % e, filename, sheet.name, field_name,
                        u"第%s行" % (rindex+1), cell.value)
                all_rows[rindex][field_name] = value
        # 保存
        for rindex, config in enumerate(all_rows[start_row:], start_row):
            key = config[self.key_name]
            if key in self.config_dict:
                ERROR(u"主键重复", filename, sheet.name, u"第%s行" % (rindex+1), key)
            self.config_dict[key] = config
        if self.ch_key_name in self.field_dict:
            for rindex, config in enumerate(all_rows[start_row:], start_row):
                # if self.ch_key_name not in config:
                #     ERROR(u"ch_key缺失", filename, sheet.name,
                #         u"第%s行" % (rindex+1), config[self.key_name])
                if self.ch_key_name in config:
                    key = config[self.ch_key_name]
                    if self.table_name not in GROUP_TABLE:
                        if key in self.ch_key_dict:
                            ERROR(u"ch_key重复", filename, sheet.name,
                                u"第%s行" % (rindex+1), config[self.key_name], key)
                    self.ch_key_dict[key] = config
        else:
            self.ch_key_name = None
    def save_as_lua(self):
        if not self.field_dict:
            return
        if not self.config_dict:
            with open(os.path.join(TEMP_LUA_PATH, self.table_name + ".lua"), "wb") as temp_lua:
                temp_lua.write("return {\n")
                # 写入字段名字循序，避免在不同的平台下顺序不同而导致diff
                field_list = self.field_dict.values()
                field_list.sort(key=lambda x:x.index)
                temp_lua.write("    [ [==[__element_names_scheme]==] ] = {\n")
                for index, field in enumerate(field_list, 1):
                    temp_lua.write("        [%d] = [==[%s]==],\n" % (index, field.field_name))
                temp_lua.write("    },\n")
                # 写入table字段，lua负责解析成table
                temp_lua.write("    [ [==[__table_field_list]==] ] = {\n")
                for index, field in enumerate(field_list, 1):
                    if field.is_table():
                        temp_lua.write("        [==[%s]==],\n" % (field.field_name))
                temp_lua.write("    },\n")
                temp_lua.write("}\n")
            return
        def value2str(value):
            if type(value) == list:
                str_list = ["{"]
                for v in value:
                    str_list.append(value2str(v))
                    str_list.append(",")
                str_list.append("}")
                return "".join(str_list)
            if type(value) == unicode:
                return "[==[%s]==]" % (value.encode("utf8"))
            if type(value) == str:
                return "[==[%s]==]" % (value.encode("utf8"))
            if type(value) == bool:
                return "true" if value else "false"
            return "%s" % value

        with open(os.path.join(TEMP_LUA_PATH, self.table_name + ".lua"), "wb") as temp_lua:
            temp_lua.write("return {\n")
            # 写入字段名字循序，避免在不同的平台下顺序不同而导致diff
            field_list = self.field_dict.values()
            field_list.sort(key=lambda x:x.index)
            temp_lua.write("    [ [==[__element_names_scheme]==] ] = {\n")
            for index, field in enumerate(field_list, 1):
                temp_lua.write("        [%d] = [==[%s]==],\n" % (index, field.field_name))
            temp_lua.write("    },\n")
            # 写入table字段，lua负责解析成table
            temp_lua.write("    [ [==[__table_field_list]==] ] = {\n")
            for index, field in enumerate(field_list, 1):
                if field.is_table():
                    temp_lua.write("        [==[%s]==],\n" % (field.field_name))
            temp_lua.write("    },\n")
            # 所有数据
            config_list = self.config_dict.values()
            config_list.sort(key=lambda x:x[self.key_name])
            for config in config_list:
                temp_lua.write("    [ %s ] = {\n" % value2str(config[self.key_name]))
                for k,v in config.iteritems():
                    temp_lua.write("        %s = " % k)
                    temp_lua.write(value2str(v))
                    temp_lua.write(",\n")
                temp_lua.write("    },\n")
            # 结束
            temp_lua.write("}\n")
        return

def main():
    # 扫描目录找出所有xls文件
    all_xls_files = []
    for dirpath, dirnames, filenames in os.walk("../excel"):
        for filename in filenames:
            if filename.startswith("~"):
                continue
            if filename.endswith("xls") or filename.endswith("xlsx"):
                all_xls_files.append(os.path.join(dirpath, filename))
    # 扫描所有文件，按表名归类
    for filename in all_xls_files:
        for sheet in xlrd.open_workbook(filename).sheets():
            if sheet.nrows == 0 or sheet.name.startswith("#"):
                continue
            # 表名
            cell = sheet.cell(3, 0)
            if cell.ctype != xlrd.XL_CELL_TEXT:
                ERROR(u"表名类型不对", filename, sheet.name)
            table_name = cell.value
            if not table_name:
                continue
            if not table_name.isalnum():
                ERROR(u"表名只能包含数字字母", filename, table_name)
            # 记录sheet
            if table_name not in ALL_TABLE:
                ALL_TABLE[table_name] = ConfigTable(table_name)
            ALL_TABLE[table_name].sheet_list.append((filename, sheet))
    # 解析
    for table in ALL_TABLE.values():
        table.parse_all_sheet()
    # 逻辑检查
    for table in ALL_TABLE.values():
        for field in table.field_dict.values():
            for checker in field.checker_list:
                checker.check_func(table, field)
    # 导出到lua
    for table_name in GROUP_TABLE:
        check_group_name(table_name)
    check_drop_data()

    for p in [CLIENT_DIR, SERVER_DIR, TEMP_LUA_PATH]:
        if os.path.exists(p):
            shutil.rmtree(p, True)
        os.makedirs(p)
    for table in ALL_TABLE.values():
        if table.no2lua:
            continue
        table.save_as_lua()
    # 生成file_list

    with open(os.path.join(TEMP_LUA_PATH, "file_list.lua"), "wb") as file_list:
        file_list.write("return {\n")
        for table in ALL_TABLE.values():
            if table.no2lua:
                continue
            table_name = table.table_name
            file_list.write("[ [==[../data/temp_lua_data/%s.lua]==] ] = [==[%s.lua]==],\n" % (table_name, table_name))
        file_list.write("}\n")

def check_group_name(table_name):
    name_dict = {}
    for key, config in ALL_TABLE[table_name].config_dict.iteritems():
        group_id = config["group_id"]
        name = config["ch_key"]
        if name not in name_dict:
            name_dict[name] = group_id
        else:
            if group_id != name_dict[name]:
                ERROR(u"组名字重复", table_name, name, key, group_id, name_dict[name])

def check_drop_data():
    global ALL_TABLE
    grouped = {}
    name_dict = {}
    path_cache = {}
    for key, config in ALL_TABLE["DropGroupData"].config_dict.iteritems():
        group_id = config["group_id"]
        if not group_id in grouped:
            grouped[group_id] = {}
            name_dict[group_id] = config["ch_key"]
        grouped[group_id][key] = config

    def _arrive(group_id):
        if group_id in path_cache:
            return path_cache[group_id]
        ret = {}
        for _, child in grouped[group_id].items():
            if not child.get("drop_group"): continue
            ret[child["drop_group"]] = (group_id, child["drop_group"])
        path_cache[group_id] = ret
        for _, child in grouped[group_id].items():
            if not child.get("drop_group"): continue
            for k, path in _arrive(child["drop_group"]).iteritems():
                if k in ret: continue
                ret[k] = (group_id, path)
        return ret
    for k in grouped.keys():
        _arrive(k)
    for group_id, path_dict in path_cache.iteritems():
        if group_id in path_dict:
            full_path = []
            def _expand_path(p):
                full_path.append(p[0])
                if type(p[1]) == tuple:
                    _expand_path(p[1])
                else:
                    full_path.append(p[1])
            _expand_path(path_dict[group_id])
            err = u"掉落组循环引用:" + u" >> ".join([name_dict[x] for x in full_path])
            ERROR(err)

if __name__ == "__main__":
    main()
