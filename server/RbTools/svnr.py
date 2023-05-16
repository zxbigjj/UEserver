# uncompyle6 version 2.11.2
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.5 (default, Nov  6 2016, 00:28:07) 
# [GCC 4.8.5 20150623 (Red Hat 4.8.5-11)]
# Embedded file name: ./svnr.py
# Compiled at: 2016-04-22 16:33:58

# uncompyle6 svnr.pyc > svnr.py

import logging
import datetime
import MySQLdb
import sys
import os
reload(sys)
sys.setdefaultencoding('utf-8')
import platform
from optparse import OptionParser
import getpass
import commands
from svnr_common_cfg import *
hash = None
try:
    import hashlib
    hash = hashlib.md5()
except ImportError:
    import md5
    hash = md5.new()

kUserConfigFileName = '.svnr_reviewboard_config'

def RunCommand(cmd):
    popen = os.popen4(cmd)
    # info = popen[1].read()
    # return info
    lines = []
    while True:
        line = popen[1].readline()
        if not line: break
        sys.stdout.write("%s" % datetime.datetime.now())
        sys.stdout.write("\t" + line)
        lines.append(line)
    return "".join(lines)


def GetHomeDirPath():
    info = platform.win32_ver()
    homedir = ''
    if info[0] == '':
        homedir = os.environ['HOME']
    else:
        homedrive = os.environ['HOMEDRIVE']
        homepath = os.environ['HOMEPATH']
        homedir = os.path.join(homedrive, homepath)
    return homedir


def GetLogFilePath(username):
    info = platform.win32_ver()
    if info[0] == '':
        logfile = '/tmp/svnr_' + username + '.log'
    else:
        logfile = GetHomeDirPath() + '\\svnr_' + username + '.log'
    return logfile


def GetCfgFilePath():
    return GetHomeDirPath() + '/' + kUserConfigFileName


class SvnrConfig:

    def __init__(self):
        pass

    def Run(self):
        cmd = 'rbt setup-repo --server %s' % kReviewBoard_URL
        os.system(cmd)
        cmd = 'svn propset reviewboard:url %s .' % kReviewBoard_URL
        RunCommand(cmd)
        username = raw_input('username:')
        password = getpass.getpass('review board password:')
        try:
            try:
                file_h = open(GetCfgFilePath(), 'wb')
                file_h.truncate(0)
                file_h.write(username + '\n' + password + '\n')
            except IOError:
                print 'config err!'

        finally:
            file_h.close()


class SvnrHandleBase:

    def __init__(self):
        self.db_connect = None
        self.cursor = None
        self.username = None
        self.password = None
        self.logger = None
        self.svn_relative_path = None
        return

    def InitAll(self):
        self.InitLog()
        self.InitDB()
        self.InitRelativePath()

    def GetUserAndPwd(self):
        if self.username != None and self.password != None:
            return (self.username, self.password)
        else:
            cfg_path = GetCfgFilePath()
            if not os.path.exists(cfg_path):
                print 'please config first, run command:svnr config'
                return ('', '')
            try:
                try:
                    file_h = open(cfg_path, 'rb')
                    lines = file_h.read().split('\n')
                    if len(lines) < 2:
                        self.username = None
                        self.password = None
                        return ('', '')
                    self.username = lines[0]
                    self.password = lines[1]
                    return (
                     self.username, self.password)
                except IOError:
                    print 'open config file failed!'

            finally:
                file_h.close()

            return

    def InitLog(self):
        username, pwd = self.GetUserAndPwd()
        logger = logging.getLogger()
        hdlr = logging.FileHandler(GetLogFilePath(username))
        formatter = logging.Formatter('%(message)s')
        hdlr.setFormatter(formatter)
        logger.addHandler(hdlr)
        logger.setLevel(logging.NOTSET)
        self.logger = logger

    def InitDB(self):
        self.db_connect = MySQLdb.connect(host=kDB_Host, port=kDB_Port, db=kDB_ReviewBoard_Name, user=kDB_User, passwd=kDB_Pwd, charset=kDB_CharSet)
        self.db_connect.autocommit(True)
        self.cursor = self.db_connect.cursor()

    def InitRelativePath(self):
        cmd_out = RunCommand('svn info')
        is_find_relative = False
        root_url = ''
        cur_url = ''
        for line in cmd_out.split('\n'):
            if line.startswith('Relative URL: ^/'):
                self.svn_relative_path = line[len('Relative URL: ^/'):]
                is_find_relative = True
                break
            elif line.startswith('\xe6\xad\xa3\xe7\xa1\xae\xe7\x9a\x84\xe7\x9b\xb8\xe5\xaf\xb9 URL: ^/'):
                self.svn_relative_path = line[len('\xe6\xad\xa3\xe7\xa1\xae\xe7\x9a\x84\xe7\x9b\xb8\xe5\xaf\xb9 URL: ^/'):]
                is_find_relative = True
                break
            elif line.startswith('URL: '):
                cur_url = line[len('URL: '):]
            elif line.startswith('Repository Root: '):
                root_url = line[len('Repository Root: '):]

        if not is_find_relative:
            self.svn_relative_path = cur_url[len(root_url) + 1:]
        if self.svn_relative_path == None:
            print 'init svn relative path failed!!!'
            self.Log('init svn relative path failed!!!')
        return

    def Log(self, text):
        self.logger.info(text)


class SvnrHandlePostRequest(SvnrHandleBase):

    def __init__(self):
        SvnrHandleBase.__init__(self)
        self.arg_options = None
        self.args = None
        self.change_list_name = None
        self.change_list_files = None
        self.review_request_id = None
        self.files_md5_list = None
        return

    def InitAll(self, argv):
        SvnrHandleBase.InitAll(self)
        self.ParseArgs(argv)

    def ParseArgs(self, argv):
        usage = 'usage: %prog pr [options] arg'
        parser = OptionParser(usage)
        parser.add_option('-d', '--debug', dest='debug', help='debug mode')
        if len(argv) < 1:
            print 'argv num must > 1'
            sys.exit(0)
        self.arg_options, self.args = parser.parse_args(argv)
        self.change_list_name = self.args[0]

    def CheckReleaseOrTrunk(self):
        cmd = 'svn info'
        cmd_out = RunCommand(cmd).strip()
        ret = True
        if 'release_' in cmd_out:
            if not self.change_list_name.endswith('release'):
                print 'You Must set changelist name end with _release'
                ret = False
        elif 'branch_' in cmd_out:
            if not self.change_list_name.endswith('branch'):
                print 'You Must set changelist name end with _branch'
                ret = False
        elif not self.change_list_name.endswith('trunk'):
            print 'You Must set changelist name end with _trunk'
            ret = False
        return ret

    def GetChangeListFiles(self):
        if self.change_list_files != None:
            return self.change_list_files
        else:
            change_list_files = []
            cmd_out = RunCommand('svn st')
            is_in_change_list = False
            for line in cmd_out.split('\n'):
                if line == "--- Changelist '" + self.change_list_name + "':":
                    is_in_change_list = True
                elif line == "--- \xe4\xbf\xae\xe6\x94\xb9\xe5\x88\x97\xe8\xa1\xa8 '" + self.change_list_name + "':":
                    is_in_change_list = True
                elif line == '':
                    is_in_change_list = False
                elif is_in_change_list:
                    file_name = line[7:]
                    change_flag = line[:2]
                    if line[0] != ' ':
                        change_list_files.append((change_flag, file_name.strip()))

            self.change_list_files = change_list_files
            return change_list_files

    def GetFilesMD5List(self):
        if self.files_md5_list != None:
            return self.files_md5_list
        else:
            change_list_files = self.GetChangeListFiles()
            files_md5_list = []
            for change_flag, file_name in change_list_files:
                md5_value = '0'
                if change_flag != 'D ':
                    try:
                        try:
                            print file_name
                            file_h = open(file_name, 'rb')
                            content = file_h.read().strip()
                            self.Log('file_name%s, flag:%s' % (file_name, change_flag))
                            hash.update(content)
                            md5_value = hash.hexdigest()
                            self.Log('file_name%s, flag:%s, md5%s' % (file_name, change_flag, md5_value))
                        except:
                            print 'file:%s open failed!' % file_name
                            self.Log('file:%s open failed!' % file_name)

                    finally:
                        file_h.close()

                self.Log('svn relative path %s' % self.svn_relative_path)
                full_path = os.path.join(self.svn_relative_path, file_name)
                full_path = full_path.replace('\\', '/')
                self.Log('md5file full_path:' + full_path)
                files_md5_list.append((self.review_request_id, full_path, md5_value))

            self.Log('Files md5 list is:\n')
            self.Log(files_md5_list)
            self.files_md5_list = files_md5_list
            return files_md5_list

    def UpdateReviewQuestToDB(self):
        sql_cmd = "\n                    delete\n                    from %s\n                    where change_list_name = '%s' and username = '%s'\n                  "
        sql_cmd = sql_cmd % (kDB_Review_TB_Name, self.change_list_name, self.username)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        sql_cmd = "\n                    insert\n                    into %s(review_request_id, change_list_name, username)\n                    values('%s', '%s', '%s')\n                  "
        sql_cmd = sql_cmd % (kDB_Review_TB_Name, self.review_request_id, self.change_list_name, self.username)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)

    def UpdateMD5ToDB(self):
        files_md5_list = self.GetFilesMD5List()
        sql_cmd = "\n                    delete\n                    from %s\n                    where review_request_id = '%s' \n                  "
        sql_cmd = sql_cmd % (kDB_Review_File_MD5_TB_Name, self.review_request_id)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        sql_cmd = 'insert into %s(review_request_id, file_name, md5) '
        sql_cmd = sql_cmd % kDB_Review_File_MD5_TB_Name + "values('%s', '%s', '%s')"
        self.Log(sql_cmd)
        for elem in files_md5_list:
            sql_run = sql_cmd % elem
            self.cursor.execute(sql_run)
            self.Log(sql_run)

        sql_cmd = "\n                    update reviews_review\n                    set ship_it = 0\n                    where review_request_id = '%s'\n                  "
        sql_cmd = sql_cmd % self.review_request_id
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)

    def GetPostRequestCmd(self):
        change_list_files = self.GetChangeListFiles()
        commit_files = [ f[1] for f in change_list_files ]
        post_cmd = 'rbt post '
        if self.arg_options.debug or True:
            post_cmd += '-d '
        post_cmd += '--username=' + self.username + ' '
        post_cmd += '--password=' + self.password + ' '
        post_cmd += '--summary=' + self.change_list_name.strip() + ' '
        sql_cmd = "\n                    select review_request_id\n                    from %s\n                    where username = '%s' and change_list_name = '%s'\n                  "
        sql_cmd = sql_cmd % (kDB_Review_TB_Name, self.username, self.change_list_name)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        db_rets = self.cursor.fetchall()
        if len(db_rets) != 0:
            post_cmd += '-r ' + str(db_rets[0][0]) + ' '
        for file_name in commit_files:
            post_cmd += '-I ' + file_name + ' '

        self.Log('post_cmd:' + post_cmd)
        return post_cmd

    def Run(self):
        change_list_files = self.GetChangeListFiles()
        if len(change_list_files) == 0:
            print 'change list is empty!'
            return False
        if self.CheckReleaseOrTrunk() == False:
            return False
        post_cmd = self.GetPostRequestCmd()
        print post_cmd.replace(self.password, '*' * len(self.password))
        cmd_out = RunCommand(post_cmd)
        self.Log('post_result:' + cmd_out)
        # print cmd_out
        request_beg = cmd_out.rfind('/r/') + 3
        request_end = cmd_out.find('/', request_beg)
        review_request_id = cmd_out[request_beg:request_end]
        try:
            int(review_request_id)
        except:
            review_request_id = cmd_out.strip().rsplit('/')[-3]

        self.review_request_id = review_request_id
        self.Log('review_request_id:' + self.review_request_id)
        self.UpdateMD5ToDB()
        self.UpdateReviewQuestToDB()


class SvnrHandleCommit(SvnrHandleBase):

    def __init__(self):
        SvnrHandleBase.__init__(self)
        self.change_list_name = None
        self.change_list_files = None
        self.review_request_id = None
        return

    def InitAll(self, argv):
        SvnrHandleBase.InitAll(self)
        self.argv = argv
        self.change_list_name = argv[0]

    def GetDescriptionFromReviewBoard(self):
        sql_cmd = "\n                    select description\n                    from reviews_reviewrequest\n                    where id in(\n                          select review_request_id\n                          from %s\n                          where change_list_name = '%s' and username = '%s'\n                        )\n                  "
        sql_cmd = sql_cmd % (kDB_Review_TB_Name, self.change_list_name, self.username)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        db_rets = self.cursor.fetchall()
        des = ''
        if len(db_rets) > 0:
            des += db_rets[0][0]
        return des

    def Commit(self):
        sql_cmd = "\n                    delete\n                    from %s\n                    where username = '%s'\n                  "
        sql_cmd = sql_cmd % (kDB_ChangeList_TB_Name, self.username)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        sql_cmd = "\n                    insert\n                    into %s(changelist, username, isdir, version)\n                    values('%s', '%s', 0, %d)\n                  "
        sql_cmd = sql_cmd % (kDB_ChangeList_TB_Name, self.change_list_name, self.username, SVN_REVIEW_VERSION)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)
        desc = self.GetDescriptionFromReviewBoard()
        try:
            info = platform.win32_ver()
            if info[0] != '':
                desc = desc.decode('UTF-8')
                desc = desc.encode('GB2312')
        except:
            desc = desc

        args = '--changelist ' + self.change_list_name
        args += ' -m "' + desc + '"'
        ci_cmd = 'svn ci ' + args
        self.Log(ci_cmd)
        os.system(ci_cmd)
        sql_cmd = "\n                    delete\n                    from %s\n                    where username = '%s'\n                  "
        sql_cmd = sql_cmd % (kDB_ChangeList_TB_Name, self.username)
        self.Log(sql_cmd)
        self.cursor.execute(sql_cmd)

    def Run(self):
        self.Commit()


class Svnr:

    def __init__(self, argv):
        self.argv = argv
        self.CMDS = [
         'config',
         'pr',
         'ci']

    def CheckAndParserArgv(self):
        if len(self.argv) == 1 or self.argv[-1] == '':
            print 'svnr config : to config svnr'
            print 'svnr pr changelistname : post change list to reviewboard'
            print 'svnr ci changelistname : commit change list'
            return True
        if self.argv[1] not in self.CMDS:
            args = ''
            for arg in self.argv[1:]:
                if ' ' in arg:
                    args += '"' + arg + '" '
                else:
                    args += arg + ' '

            print args
            cmd = 'svn ' + args + ' '
            print cmd
            os.system(cmd)
            return True
        return False

    def Run(self):
        if self.CheckAndParserArgv():
            return 0
        opt = self.argv[1]
        if opt == 'config':
            svnr_config = SvnrConfig()
            svnr_config.Run()
        elif opt == 'pr':
            svnr_req = SvnrHandlePostRequest()
            svnr_req.InitAll(self.argv[2:])
            svnr_req.Run()
        elif opt == 'ci':
            svnr_ci = SvnrHandleCommit()
            svnr_ci.InitAll(self.argv[2:])
            svnr_ci.Run()
        return 0


def main(argv):
    try:
        svnr = Svnr(argv)
        return svnr.Run()
    except Exception as e:
        print str(e)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
# okay decompiling svnr.pyc
