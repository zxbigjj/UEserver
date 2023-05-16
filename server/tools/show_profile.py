#coding=utf-8
#显示sample结果, 把地址转换成函数
import sys,re
import os
import os.path
import json
import subprocess

FUNC_HIDE = {
    'ldo.c(skynet)':        None,
    'lcorolib.c(skynet)':   None,
    'lvm.c(skynet)':        None,
    'lbaselib.c(skynet)':   None,
    'lapi.c(skynet)':       None,
    'ltm.c(skynet)':        None,
    '[C]':                  set(['global <xpcall:-1>', 'upvalue <coroutine_resume:-1>', ]),
}

def get_hide_lua_node(node):
    while node.father:
        node = node.father
    for c in node.children:
        if c.func_info[0] == 'lua_hide':
            return c

class Node(object):
    def __init__(self, father, deep, tag, func_info, sample):
        self.father = father
        self.deep = deep
        self.func_info = tuple(func_info)
        self.sample = sample
        self.total_sample = 0
        self.tag = tag.lower()
        self.children = []

    def key(self):
        return (self.tag, self.func_info[0], self.func_info[1])

    def to_line(self):
        func_info = "%s => %s:%s" % self.func_info
        return "%s%4d/%4d %3s %s" % (self.deep * " ", 
            self.sample,
            self.total_sample,
            self.tag, func_info)

    def add_child(self, tag, func_info, sample):
        if func_info[:2] == self.func_info[:2] and tag == self.tag:
            self.sample += sample
            return self
        for child in self.children:
            if func_info[:2] == child.func_info[:2] and tag == child.tag:
                child.sample += sample
                return child
        child = Node(self, self.deep+1, tag, func_info, sample)
        self.children.append(child)
        return child

    def refresh_total_sample(self):
        self.total_sample = self.sample
        for child in self.children:
            self.total_sample += child.refresh_total_sample()
        return self.total_sample

    def hide_min_sample_node(self, total_sample):
        if self.total_sample <= int(total_sample * 0.03):
            self.sample = self.total_sample
            self.children = []
        else:
            for c in self.children:
                c.hide_min_sample_node(total_sample)

    def can_hide(self):
        # if len(self.children) == 1 and self.sample == 0:
        #     return True
        if self.func_info[1] not in FUNC_HIDE:
            return False
        name_list = FUNC_HIDE[self.func_info[1]]
        if name_list == None or self.func_info[0] in name_list:
            return True
        return False

    # 去掉lua虚拟机函数
    def hide_lua_vm_func(self):
        for c in self.children:
            c.hide_lua_vm_func()
        new_children = []
        lua_vm_children = []
        for c in self.children:
            if c.can_hide():
                lua_vm_children.append(c)
            else:
                new_children.append(c)
        self.children = new_children
        for c in lua_vm_children:
            self.merge(c)

    # 合并两个节点
    def merge(self, other):
        self.sample += other.sample
        for other_child in other.children:
            key = other_child.key()
            for child in self.children:
                if key == child.key():
                    child.merge(other_child)
                    break
            else:
                self.children.append(other_child)
                other_child.deep = self.deep + 1
                other_child.father = self
        other.sample = 0
        other.children = []

    def simple_str(self, total, out_list):
        if self.deep >= 0 and self.sample > 0.01 * self.total_sample:
            func_info = "%s => %s:%s" % self.func_info
            out_list.append("%s%02d %.3f/%.3f %3s %s" % (self.deep * " ", self.deep, 
                self.sample * 1.0 / total,
                self.total_sample * 1.0 / total,
                self.tag, func_info))
        for child in self.children:
            if child.total_sample > max(0.001 * total, 0.1 * self.total_sample):
                child.simple_str(total, out_list)
        return out_list

    def full_str(self, total, out_list):
        func_info = "%s => %s:%s" % self.func_info
        out_list.append("%s%02d %.3f/%.3f %3s %s" % (self.deep * " ", self.deep, 
            self.sample * 1.0 / total,
            self.total_sample * 1.0 / total,
            self.tag, func_info))
        for child in self.children:
            child.full_str(total, out_list)
        return out_list

    def to_dict(self):
        return {
            "self" : (self.tag, self.func_info, self.sample),
            "children" : [x.to_dict() for x in self.children]
        }

    @staticmethod
    def from_dict(d, father):
        deep = 1+father.deep if father else 0
        node = Node(father, deep, d["self"][0], d["self"][1], d["self"][2])
        for c in d["children"]:
            node.children.append(Node.from_dict(c, node))
        return node

    def to_func_dict(self, out_dict, father_keys=None):
        if not father_keys:
            father_keys = []
        key = (self.tag, self.func_info)
        if self.sample > 0:
            if key in out_dict:
                out_dict[key][0] += self.sample
                if key not in father_keys:
                    out_dict[key][1] += self.total_sample
                else:
                    pass
            else:
                out_dict[key] = [self.sample, self.total_sample]
        father_keys.append(key)
        for child in self.children:
            child.to_func_dict(out_dict, father_keys)
        assert(key == father_keys.pop())
        return out_dict

def get_so_info(data):
    info_list = []
    data = data[:data.index("==sample_begin==")]
    for line in data.split("\n"):
        words = line.split()
        if len(words) < 6: continue
        if 'x' not in words[1]: continue
        if not words[-1].startswith('/'): continue
        name = words[5]
        begin, end = words[0].split('-')
        begin = int(begin, 16)
        end = int(end, 16)
        if info_list and info_list[-1]["name"] == name and info_list[-1]["end"] == begin:
            info_list[-1]["end"] = end
        else:
            info_list.append(dict(name=name, begin=begin, end=end))
    info_list.sort(key=lambda x:x["begin"])
    return info_list


CACHED_POPEN = {}
def addr2line(so_info_list, addr):
    if addr == 0:
        return 'root', 'root', "0"
    so_info = None
    for info in so_info_list:
        if addr >= info["begin"] and addr < info["end"]:
            so_info = info
            break
    if not so_info:
        return '?', '?', "?"
    exe_name = so_info["name"]
    global CACHED_POPEN
    p = CACHED_POPEN.get(exe_name)
    if not p:
        p = subprocess.Popen(["addr2line", "-pfC", "-e", exe_name], 
            stdin=subprocess.PIPE, stdout=subprocess.PIPE)
        CACHED_POPEN[so_info["name"]] = p
    if exe_name.endswith(".so"):
        p.stdin.write("%x\n" % (addr - so_info["begin"] - 1))
    else:
        p.stdin.write("%x\n" % (addr - 1))
    line = p.stdout.readline()
    words = line.strip().split(" at ")
    func_name = words[0]
    file_name, line_num = words[-1].split(":")
    if "/" in file_name:
        file_name = file_name[1+file_name.rindex("/"):]
    if "/" in exe_name:
        file_name += "(%s)" % exe_name[1+exe_name.rindex("/"):]
    else:
        file_name += "(%s)" % exe_name
    return func_name, file_name, line_num

def parse_lua_function_def(line):
    line = line.strip()
    if "#" in line:
        line = line[:line.index("#")]
    match = re.search("function\s*([\w.:]+)\\([ \w,.]*\\)", line)
    if not match:
        match = re.search("([\w.]+)\s*=\s*function\s*\\([ \w,.]*\\)", line)
    if match:
        fname = match.groups()[0]
        if ":" in fname:
            return fname.split(":")[-1]
        elif "." in fname:
            return fname.split(".")[-1]
        else:
            return fname
    return


LUA_FILE_NAMES = {}
for root, dirs, files in os.walk('..'):
    for name in files:
        if name.endswith(".lua"):
            name = root + "/" + name
            LUA_FILE_NAMES[os.path.abspath(name)] = name[3:]

LUA_LINE_CACHE = {}
LUA_FILE_CACHE = {}
def lua_line2func(func_info):
    global LUA_LINE_CACHE
    global LUA_FILE_CACHE
    if func_info in LUA_LINE_CACHE:
        return LUA_LINE_CACHE[func_info]
    if "=>" not in func_info:
        return func_info, "?", "?"
    left, right = func_info.split("=>")
    file_name, line_num = left.split(":")
    if file_name.startswith('[string "'):
        file_name = file_name[9:-2]
    for index, pattern in enumerate(['(function) <(.+\\.lua):(\d+)>', '(\w+) <([\w?]+):(\d+)>']):
        match = re.search(pattern, right)
        if match:
            func_type = ''
            _func_name = ''
            full_file_name = ''
            if index == 0:
                func_type, file_name, line_num = match.groups()
            else:
                func_type, _func_name, line_num = match.groups()
            for k, v in LUA_FILE_NAMES.iteritems():
                # short_src可能是...b/combat_loigc/形式
                if v.endswith(file_name[3:]):
                    full_file_name, file_name = k, v
                    break
            if full_file_name:
                line_num = int(line_num)
                lines = LUA_FILE_CACHE.get(full_file_name)
                if not lines:
                    with open(full_file_name) as lua_file:
                        lines = lua_file.readlines()
                    LUA_FILE_CACHE[full_file_name] = lines
                line = lines[line_num-1]
                lua_func_name = parse_lua_function_def(line)
                if lua_func_name:
                    right = "%s '%s'" % (func_type, lua_func_name)
                else:
                    if index == 1:
                        right = "%s '%s'" % (func_type, _func_name)
                break

    ret = (right, file_name, line_num)
    LUA_LINE_CACHE[func_info] = ret
    return ret

ADDR_CACHE = {}
def parse_call_tree(data):
    so_info_list = get_so_info(data)
    global ADDR_CACHE
    
    root = Node(None, -1, "c", ("fake_root", "fake_root", 0), 0)
    root.add_child("lua", ("lua_hide", "lua_hide", 0), 0)
    node = root
    for line in data[data.index("==sample_begin=="):].split("\n"):
        line = line.strip()
        if not line or line.startswith("=="):
            continue
        tag, deep, sample, func_info = line.strip().split(",")
        deep = int(deep)
        sample = int(sample)
        if tag == "lua":
            func_info = lua_line2func(func_info)
        else:
            addr = int(func_info, 16)
            if addr in ADDR_CACHE:
                func_info = ADDR_CACHE[addr]
            else:
                func_info = addr2line(so_info_list, addr)
                ADDR_CACHE[addr] = func_info
        while node.deep >= deep:
            node = node.father
        # print "%s%02d %02d %3s %s" % (deep * "-", deep, sample, tag, func_info)
        node = node.add_child(tag, func_info, sample)

    # 计算总样本
    root.hide_lua_vm_func()
    root.refresh_total_sample()
    root.hide_min_sample_node(root.total_sample)
    return root

def get_char():
    import termios
    # 获取标准输入的描述符
    fd = sys.stdin.fileno()
    # 获取标准输入(终端)的设置
    old_ttyinfo = termios.tcgetattr(fd)
    # 配置终端
    new_ttyinfo = old_ttyinfo[:]
    # 使用非规范模式(索引3是c_lflag 也就是本地模式)
    new_ttyinfo[3] &= ~termios.ICANON
    # 关闭回显(输入不会被显示)
    new_ttyinfo[3] &= ~termios.ECHO
    # 使设置生效
    termios.tcsetattr(fd, termios.TCSANOW, new_ttyinfo)
    # 从终端读取
    try:
        while True:
            char = os.read(fd, 1)
            yield char
    except KeyboardInterrupt, e:
        pass
    finally:
        # 还原终端设置
        termios.tcsetattr(fd, termios.TCSANOW, old_ttyinfo)

def zoom_tree(node_root):
    node_root.refresh_total_sample()
    total = node_root.total_sample
    zoom_dict = {}
    zoomed_zoom = None
    selected_index = [None]
    zoom_list = []
    def KEY(node):
        return (node.tag,) + node.func_info[:2]
    class ZoomCls(object):
        def __init__(self, tag, func_info, sample, total_sample):
            self.tag = tag
            self.func_info = func_info
            self.sample = sample
            self.total_sample = total_sample
            self.caller_list = []
            self.children = []
        def add_caller(self, caller, sample):
            for x in self.caller_list:
                if x[0] is caller:
                    x[1] += sample
                    return
            self.caller_list.append([caller, sample])
        
        def add_child(self, child, sample):
            for x in self.children:
                if x[0] is child:
                    x[1] += sample
                    return
            self.children.append([child, sample])
        
        def __str__(self):
            ret = u"%04d/%04d %3s" % (
                self.sample,
                self.total_sample,
                self.tag)
            ret += u" %s => %s:%s" % self.func_info
            return ret
        def __repr__(self):
            return u" %s => %s:%s" % self.func_info

    def to_zoom(node):
        if node.total_sample == 0:
            return
        if node.sample > 0:
            # 抽取调用路径
            call_path = [node]
            f = node.father
            while f:
                if KEY(f) != KEY(call_path[0]):
                    call_path.insert(0, f)
                f = f.father
            # total_sample
            check_dict = {}
            for c in call_path:
                key = KEY(c)
                if key in check_dict:
                    continue
                zoom = zoom_dict.get(key)
                if not zoom:
                    zoom = ZoomCls(c.tag, c.func_info, 0, 0)
                    zoom_dict[key] = zoom
                check_dict[key] = True
                zoom.total_sample += node.sample
            # sample
            zoom_dict[KEY(node)].sample += node.sample
            # 调用关系
            caller_dict = {}
            for index in range(0, len(call_path)-1):
                caller_dict[KEY(call_path[index])] = KEY(call_path[index+1])
            for x, y in caller_dict.iteritems():
                zoom_dict[x].add_child(zoom_dict[y], node.sample)
            # 被调用关系
            callee_dict = {}
            for index in range(1, len(call_path)):
                callee_dict[KEY(call_path[index])] = KEY(call_path[index-1])
            for x, y in callee_dict.iteritems():
                zoom_dict[x].add_caller(zoom_dict[y], node.sample)
        for c in node.children:
            to_zoom(c)
        return zoom_dict[KEY(node)]
    def print_zoom(left='     ', middle='  '):
        zoom = zoom_list[-1]
        if selected_index[0] is not None and len(zoom_list) == selected_index[0] + 1:
            cmd = u'\033[31m%s\033[0m%s\033[31m%s\033[0m' % (left, middle, zoom)
            print cmd.encode("utf8")
        else:
            print "%s%s%s" % (left, middle, zoom)
    def print_call_list(call_list, left):
        if len(call_list) == 1:
            zoom_list.append(call_list[0])
            print_zoom(left)
            return
        for i in range(len(call_list)):
            c = call_list[i]
            zoom_list.append(c)
            if i == 0:
                print_zoom(left, u" ┌")
            elif i == len(call_list) - 1:
                print_zoom(left, u" └")
            else:
                print_zoom(left, u" │")
        return
    def p():
        spliter = "====" * 20
        os.system("clear")
        del zoom_list[:]
        # caller
        for c, c_sample in zoomed_zoom.caller_list:
            left = "%.3f" % (c_sample * 1.0 / zoomed_zoom.total_sample)
            call_list =[c]
            x = c
            while len(x.caller_list) == 1:
                x = x.caller_list[0][0]
                if x in call_list: break
                call_list.insert(0, x)
            print_call_list(call_list, left)
            if c is not zoomed_zoom.caller_list[-1][0]:
                print ""
        # zoomed
        print spliter
        if selected_index[0] is None:
            selected_index[0] = len(zoom_list)
        zoom_list.append(zoomed_zoom)
        print_zoom()
        print spliter
        # children
        for c, c_sample in zoomed_zoom.children:
            left = "%.3f" % (c_sample * 1.0 / zoomed_zoom.total_sample)
            call_list = [c]
            x = c
            while len(x.children) == 1:
                x = x.children[0][0]
                if x is c: break
                call_list.append(x)
            print_call_list(call_list, left)
            if c is not zoomed_zoom.children[-1][0]:
                print ""
        print '\033[32m总样本数：%d\033[0m' % total

    zoom_root = to_zoom(node_root)
    for zoom in zoom_dict.itervalues():
        zoom.caller_list.sort(key=lambda x:-x[1])
        zoom.children.sort(key=lambda x:-x[1])
    zoomed_zoom = zoom_root
    p()
    for char in get_char():
        if not char: return
        elif char == "q":
            return
        elif char == "s":
            if selected_index[0] < len(zoom_list) - 1:
                selected_index[0] += 1
                p()
        elif char == "w":
            if selected_index[0] > 0:
                selected_index[0] -= 1
                p()
        elif char == " ":
            if zoomed_zoom is not zoom_list[selected_index[0]]:
                zoomed_zoom = zoom_list[selected_index[0]]
                selected_index[0] = None
                p()


def view_tree(root):
    selected_node = None
    flag_auto_ignore = False
    flag_show_file = True
    class ShowCls(object):
        def __init__(self):
            self.fold = True
    def init(node):
        node.show = ShowCls()
        node.children.sort(key=lambda x:-x.total_sample)
        for c in node.children:
            init(c)
    def fold_node(node):
        node.show.fold = True
        for c in node.children:
            fold_node(c)
    def unfold_node(node):
        node.show.fold = False
        for c in node.children:
            unfold_node(c)
    def get_print_node(node, result):
        if flag_auto_ignore and node is not selected_node and len(node.children) == 1 and node.show.fold==False:
            pass
        else:
            result.append(node)
        if not node.show.fold:
            for c in node.children:
                get_print_node(c, result)
        return result
    def print_node_list(node_list):
        total = root.total_sample
        index = node_list.index(selected_node)
        for node in node_list[max(0,index-25):index+25]:
            if node.father:
                left = u""
                use_dot = True
                if node is node.father.children[-1]:
                    if node.father not in node_list:
                        left = u"··" + left
                    else:
                        left = u"└─" + left
                else:
                    left += u"├─"
                up = node.father
                while up.father:
                    if up is up.father.children[-1]:
                        if up in node_list or not use_dot:
                            if left.startswith(u"··"):
                                left = u"  └·" + left[2:]
                            else:
                                left = u"  " + left
                            use_dot = False
                        else:
                            left = u"··" + left
                    else:
                        if left.startswith(u"··"):
                            left = u"│·" + left
                        else:
                            left = u"│ " + left
                        use_dot = False
                    up = up.father
            else:
                left = u""
            right = u"%.3f/%.3f %3s" % (
                node.sample * 1.0 / total,
                node.total_sample * 1.0 / total,
                node.tag)
            if flag_show_file:
                right += u" %s => %s:%s" % node.func_info
            else:
                right += u" %s" % node.func_info[0]
            if node is selected_node:
                cmd = u'%s\033[31m%s\033[0m' % (left, right)
                print cmd.encode("utf8")
            else:
                print left + right
        print '\033[32m总样本数：%d, 当前：%d/%d \033[0m' % (total, selected_node.sample, selected_node.total_sample)
        print '\033[32m上下移动：wWsS\033[0m'
        print '\033[32m展开折叠：ad/space/\033[0m'
        print '\033[32m显示：    fi\033[0m'
        print '\033[32m退出：    q\033[0m'
    def p():
        os.system("clear")
        print_node_list(get_print_node(root, []))
     
    init(root)
    root.show.fold = False
    selected_node = root.children[0]
    p()
    
    for char in get_char():
        if not char: return
        elif char == "q":
            return
        elif char == "d":
            #右
            selected_node.show.fold = False
            while len(selected_node.children) == 1:
                selected_node = selected_node.children[0]
                selected_node.show.fold = False
            if selected_node.children:
                selected_node = selected_node.children[0]
            p()
        elif char == "a":
            # 左
            selected_node.show.fold = True
            if selected_node.father:
                selected_node = selected_node.father
                selected_node.show.fold = True
            while selected_node.father:
                if len(selected_node.father.children) > 1:
                    break
                selected_node = selected_node.father
                selected_node.show.fold = True
            p()
        elif char == "s":
            #下
            node_list = get_print_node(root, [])
            index = node_list.index(selected_node)
            if index < len(node_list) - 1:
                selected_node = node_list[index+1]
                p()
        elif char == "S":
            #下
            node_list = get_print_node(root, [])
            index = node_list.index(selected_node)
            if index < len(node_list) - 10:
                selected_node = node_list[index+10]
            else:
                selected_node = node_list[-1]
            p()
        elif char == "w":
            #上
            node_list = get_print_node(root, [])
            index = node_list.index(selected_node)
            if index > 0:
                selected_node = node_list[index-1]
                p()
        elif char == "W":
            #上
            node_list = get_print_node(root, [])
            index = node_list.index(selected_node)
            if index >= 10:
                selected_node = node_list[index-10]
            else:
                selected_node = node_list[0]
            p()
        elif char == "i":
            flag_auto_ignore = not flag_auto_ignore
            p()
        elif char == "f":
            flag_show_file = not flag_show_file
            p()
        elif char == " ":
            # 折叠打开所有子数
            if selected_node.show.fold:
                unfold_node(selected_node)
            else:
                fold_node(selected_node)
            p()
        else:
            print repr(char)

def main():
    args = [x for x in sys.argv if not x.startswith("--")]
    if len(sys.argv) < 2:
        print "用法：show_profile.py profile_data_file"
        print "--text, --json, --zoom, --read_json"
        return
    data_path = os.path.abspath(args[1])
    if "--read_json" in sys.argv:
        root = Node.from_dict(json.loads(open(data_path).read()), None)
        root.refresh_total_sample()
    else:
        root = parse_call_tree(open(data_path).read())

    # print "\n".join(root.full_str(root.total_sample, []))
    if "--json" in sys.argv:
        print json.dumps(root.to_dict())
        return
    if "--text" in sys.argv:
        func_list = [(v,k) for k,v in root.to_func_dict({}).items()]
        func_list.sort(key=lambda x: x[0][0])
        for v, k in func_list:
            print v, k
        print "总样本数:%s" % root.total_sample
        return
    if "--zoom" in sys.argv:
        zoom_tree(root)
        return
    view_tree(root)

if __name__ == '__main__':
    main()