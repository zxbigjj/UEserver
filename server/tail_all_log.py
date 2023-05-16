#!/usr/bin/python
#encoding=utf-8
import subprocess, os, sys
import datetime
import pyinotify
import multiprocessing

log_dir = os.path.realpath("log")
file_dict = {}

MSG_QUEUE = multiprocessing.Queue()

def read_msg(queue):
    curr_file_me = ''
    while True:
        try:
            msg = queue.get()
        except:
            break

        if msg[0] != curr_file_name:
            curr_file_name = msg[0]
            print "\n==> %s <==" % msg[0]
        sys.stdout.write(msg[1])

def _tail_file(fullname, queue):
    pipe = subprocess.Popen('tail -f "%s"' % fullname, shell=True, stdout=subprocess.PIPE).stdout
    name = fullname.replace(log_dir, "")[1:]
    while True:
        try:
            line = pipe.readline()
        except:
            break
        queue.put([name, line])


def tail_file(fullname):
    if fullname in file_dict:
        return
    file_dict[fullname] = multiprocessing.Process(target=_tail_file, args=(fullname, MSG_QUEUE))
    file_dict[fullname].start()

class MyEventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        # print "CREATE event:", event.pathname
        if not os.path.isfile(event.pathname):
            return
        tail_file(event.pathname)
     
    def process_IN_DELETE(self, event):
        # print "DELETE event:", event.pathname
        p = file_dict.get(event.pathname)
        if p:
            file_dict.pop(event.pathname)
            p.kill()
    
    def process_IN_MODIFY(self, event):
        # print "MODIFY event:", event.pathname
        tail_file(event.pathname)

def watch_error():
    # watch manager
    wm = pyinotify.WatchManager()
    mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE | pyinotify.IN_MODIFY
    wm.add_watch(log_dir, mask, rec=True)
 
    # notifier
    notifier = pyinotify.Notifier(wm, MyEventHandler())
    notifier.loop()

def main():
    return
    p = multiprocessing.Process(target=read_msg, args=(MSG_QUEUE, ))
    p.start()
    watch_error()

if __name__ == "__main__":
    print 'use: tail -f log/*.log'
    # main()