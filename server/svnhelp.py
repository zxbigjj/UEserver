#coding=utf-8
import sys
import subprocess
import datetime
import re
import os
this_dir = os.path.dirname(os.path.abspath(__file__))
svnr_path = os.path.normpath(os.path.join(this_dir, "RbTools/svnr.py"))


def get_clname(line):
    if not line.startswith("--- Changelist"):
        return ''
    start = line.find("'") + 1
    end = line.find("'", start)
    return line[start:end]

def get_filename_from_line(line):
    return line[3:].strip()

def cl(clname, *key_list):
    st = subprocess.check_output(["svn", "st"])
    lines = []
    for line in st.split("\n"):
        if line.startswith("--- Changelist"):
            break
        if line.startswith("M  ") or line.startswith("D  ") or \
                line.startswith("A  "):
            if not key_list or [k for k in key_list if k in line]:
                lines.append(get_filename_from_line(line))
    if not lines:
        print "nothing to do"
        return
    # 是否已有
    for line in st.split("\n"):
        if line.startswith("--- Changelist") and clname in line:
            clname = get_clname(line)
            break
    else:
        clname = clname + datetime.datetime.today().strftime('%m%d') + "_trunk"
    subprocess.check_output(["svn", "cl", clname] + lines)
    print subprocess.check_output(["svn", "st"])

def clremove(clname, *key_list):
    st = subprocess.check_output(["svn", "st"])
    lines = []
    cl_begin = False
    for line in st.split("\n"):
        if line.startswith("--- Changelist"):
            if cl_begin:
                break
            else:
                if clname in line:
                    cl_begin = True
                continue
        if not cl_begin:
            continue
        if not key_list or [k for k in key_list if k in line]:
            lines.append(get_filename_from_line(line))
    if not lines:
        print "nothing to do"
        return
    subprocess.check_output(["svn", "cl", "--remove"] + lines)
    print subprocess.check_output(["svn", "st"])
    return

def pr(clname):
    st = subprocess.check_output(["svn", "st"])
    fullname = ''
    for line in st.split("\n"):
        if line.startswith("--- Changelist") and clname in line:
            fullname = get_clname(line)
            break
    if not fullname:
        print "nothing to do"
        return
    os.system("python %s pr %s" % (svnr_path, fullname))
    return

def ci(clname, *args):
    st = subprocess.check_output(["svn", "st"])
    fullname = ''
    for line in st.split("\n"):
        if line.startswith("--- Changelist") and clname in line:
            fullname = get_clname(line)
            break
    if not fullname:
        print "nothing to do"
        return
    os.system("python %s ci %s %s" % (svnr_path, fullname, " ".join(args)))
    return

def svndiff(pattern=""):
    pattern = re.compile(pattern)
    st = subprocess.check_output(["svn", "st"])
    lines = []
    for line in st.split("\n"):
        if line.startswith("M  ") or line.startswith("D  ") or \
                line.startswith("A  "):
            if pattern.search(line): lines.append(get_filename_from_line(line))
    if not lines:
        print "nothing to do"
        return
    print subprocess.check_output(["svn", "diff"] + lines)

def main():
    if len(sys.argv) < 2:
        print "可用指令："
        print "cl clname file_filter_key: 添加到cl"
        print "clremove clname file_filter_key: 从cl移除"
        print "ci clname: 提交cl"
        print "svndiff pattern: diff符合pattern的文件"
        return
    op = sys.argv[1]
    globals()[op](*sys.argv[2:])
    
if __name__ == "__main__":
    main()