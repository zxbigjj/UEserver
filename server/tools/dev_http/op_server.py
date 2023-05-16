#coding=utf-8
import os
import os.path
import subprocess
import Queue
import time
import datetime
import gevent
import traceback


class Server(object):
    def __init__(self, server_id, path, name):
        self.server_id = server_id
        self.path = path
        self.name = name

        self.op_lock = False
        self.op_process_queue = Queue.Queue()
        self.op_log = Queue.Queue()

        self.status = ''

        self.watch_thread = gevent.spawn(self._read_log)
        self.watch_thread = gevent.spawn(self._check_status)

        self.time = time.strftime(
            '%Y-%m-%d %H:%M:%S', time.localtime(time.time()))

    def is_locked(self):
        return self.op_lock

    def _read_log(self):
        while True:
            op_process = self.op_process_queue.get()
            if not op_process:
                break
            while True:
                line = op_process.stdout.readline()
                if not line:
                    break
                self.put_log(line)

    def _check_status(self):
        while True:
            out = subprocess.check_output(
                "ps aux | grep skynet | grep s%s_" % self.server_id, shell=True)
            out = [s for s in out.split("\n") if 'grep' not in s and s.strip()]
            if len(out) == 0:
                self.status = "关闭"
            elif len(out) >= 2:
                self.status = "运行"
            else:
                self.status = "异常"
            gevent.sleep(1)

    def put_log(self, line):
        self.op_log.put(line)

    def clear_log(self):
        self.op_log = Queue.Queue()

    def fetch_log(self):
        info_list = []
        while True:
            try:
                info = self.op_log.get(False)
            except Queue.Empty:
                break
            info_list += info.split("\n")
        return info_list

    def _do(self, args, timeout=None):
        op_process = subprocess.Popen(" ".join(args),
                                      close_fds=True,
                                      shell=True,
                                      stderr=subprocess.STDOUT,
                                      stdout=subprocess.PIPE,
                                      cwd=os.path.join(self.path, "server"))
        self.op_process_queue.put(op_process)
        if not timeout:
            op_process.wait()
        else:
            while timeout > 0:
                timeout -= 0.1
                gevent.sleep(0.1)
                if op_process.poll() != None:
                    break
            else:
                # 超时
                op_process.kill()
                return False
        if op_process.returncode > 0:
            print "==============操作出错,返回值非0：%s" % op_process.returncode

    def __shut_server(self):
        self.put_log("============关闭服务器开始")
        self._do(['python', '-u', 'shutdown_server.py',
                 str(self.server_id)], timeout=10)
        out = subprocess.check_output(
            "ps aux | grep skynet | grep s%s_" % self.server_id, shell=True)
        out = [s for s in out.split("\n") if 'grep' not in s and s.strip()]
        if out:
            # --kill
            self.put_log("============强制关闭服务器")
            self._do(['python', '-u', 'shutdown_server.py',
                     str(self.server_id), '--kill'])
        self.put_log("============关闭服务器结束")

    def __reload_exceldata(self):
        self.put_log("============更新配置表开始")
        self._do(['svn', 'up', '../sharedata', '--accept theirs-full'])
        self._do(['make'])
        self.put_log("============更新配置表结束")

    def __start_server(self):
        self.time = time.strftime(
            '%Y-%m-%d %H:%M:%S', time.localtime(time.time()))
        self.put_log("============启动服务器开始")
        self._do(['svn', 'up', '.', '--accept theirs-full'])
        self._do(['python', '-u', 'start_server.py', str(self.server_id)])
        self.put_log("============启动服务器结束")

    def __del_database(self):
        config_name = os.path.join(
            self.path, 'server/config/s%s_game.lua' % self.server_id)
        config = {}
        with open(config_name) as db_config_file:
            for line in db_config_file.readlines():
                line = line.strip()
                if '=' not in line:
                    continue
                key, value = [x.strip() for x in line.split('=')]
                config[key] = value

        assert(config['gamedb'])
        config['gamedb'] = config['gamedb'].strip().replace(
            "'", "").replace('"', '')
        config['db_host'] = config['db_host'].strip().replace(
            "'", "").replace('"', '')
        config['db_port'] = config['db_port'].strip().replace(
            "'", "").replace('"', '')
        config['db_user'] = config['db_user'].strip().replace(
            "'", "").replace('"', '')
        config['db_passwd'] = config['db_passwd'].strip().replace("'",
                                                                  "").replace('"', '')

        print(config)
        import pymysql
        self.put_log("============删除数据库:" + config['gamedb'])
        conn = pymysql.connect(
            host=config['db_host'],
            port=int(config['db_port']),
            user=config['db_user'],
            password=config['db_passwd'])
        cursor = conn.cursor()
        cursor.execute("drop database " + config['gamedb'])
        conn.commit()
        cursor.close()
        conn.close()

    def _restart(self):
        try:
            self.__shut_server()
            self.__reload_exceldata()
            self.__start_server()
        except Exception, e:
            traceback.print_exc()
            self.put_log(str(e))
        self.op_lock = False

    def _del_database(self):
        try:
            self.__shut_server()
            self.__del_database()
            self.__start_server()
        except Exception, e:
            traceback.print_exc()
            self.put_log(str(e))
        self.op_lock = False

    def _reload_exceldata(self):
        try:
            self.__reload_exceldata()
        except Exception, e:
            traceback.print_exc()
            self.put_log(str(e))
        self.op_lock = False

    def op_server(self, op):
        if self.is_locked():
            return False, "其他人正在操作这个服务器，请过会再试"
        assert(self.op_lock == False)
        self.op_lock = True
        self.clear_log()
        if op == "restart":
            gevent.spawn(self._restart)
        elif op == "reload_exceldata":
            gevent.spawn(self._reload_exceldata)
        elif op == "del_database":
            gevent.spawn(self._del_database)
        else:
            return False, "暂不支持此操作"
        return True, ""

    def reload_exceldata(self):
        assert(self.op_lock == False)
        self.op_lock = True
        self.clear_log()
        gevent.spawn(self._reload_exceldata)


SERVER_LIST = [
    Server(server_id=55, path="/data/UEServer", name="测试服"),
    # Server(server_id=55, path="/GameServer/game", name="黑道1策划服(hd1)"),
]


def get_server(server_id):
    server_list = [s for s in SERVER_LIST if s.server_id == server_id]
    if not server_list:
        return None
    return server_list[0]


def do_op(op, server_id):
    server = get_server(server_id)
    if not server:
        return False, "server_id错误"
    if not os.path.isdir(server.path):
        return False, "server目录错误"
    # if not set(os.listdir(server.path)) >= set(['server', 'sharedata']):
    #     return False, "server目录错误"
    return server.op_server(op)


def check_server_op(server_id):
    server = get_server(server_id)
    assert(server)
    if server.is_locked():
        return False, server.fetch_log()
    else:
        return True, server.fetch_log()
