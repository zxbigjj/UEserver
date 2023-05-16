#encoding=utf-8
import subprocess, os
import datetime
import pyinotify
import requests

cgid = '72a8877b-fa1e-4bd0-aa10-c9cfb28edecc'
url = 'http://192.168.170.2:11445/ns'

log_dir = os.path.realpath("../../log")
file_dict = {}

class MyEventHandler(pyinotify.ProcessEvent):
    def process_IN_CREATE(self, event):
        # print "CREATE event:", event.pathname
        if event.pathname not in file_dict:
            file_dict[event.pathname] = 0
     
    def process_IN_DELETE(self, event):
        # print "DELETE event:", event.pathname
        file_dict.pop(event.pathname, None)
    
    def process_IN_MODIFY(self, event):
        # print "MODIFY event:", event.pathname
        name = os.path.basename(event.pathname)
        if not name.startswith("error"):
            return
        cmd = "tail -c +%d %s" % (1+file_dict[event.pathname], event.pathname)
        new_content = subprocess.check_output(cmd, shell=True)
        if not new_content:
            return
        file_dict[event.pathname] += len(new_content)

        new_content = ("=====>> %s <<=====\n" % (event.pathname.replace(log_dir, "")[1:])) + new_content
        new_content = new_content.replace("\t", "\\t")
        new_content = new_content.replace("\n", "\\n")
        new_content = new_content.replace('"', "'")
        payload = {'cgid': cgid, 'content': new_content, "senderName":'admin'}
        try:
            requests.post(url, data=payload)
        except requests.exceptions.ConnectionError,e:
            print e
            

def watch_error():
    now = datetime.datetime.now()
    cmd = "find %s | grep %s | grep error | xargs wc" % (log_dir, now.strftime("%Y%m%d%H"))
    output=subprocess.check_output(cmd, shell=True)
    output = [x for x in output.split("\n") if x]
    if len(output) > 1:
        output = output[:-1]
    for info in output:
        info = [x for x in info.split(" ") if x]
        if len(info) < 4:
            break
        file_path = os.path.realpath(info[3])
        file_dict[file_path] = int(info[2])

    # watch manager
    wm = pyinotify.WatchManager()
    mask = pyinotify.IN_DELETE | pyinotify.IN_CREATE | pyinotify.IN_MODIFY
    wm.add_watch(log_dir, mask, rec=True)
 
    # notifier
    notifier = pyinotify.Notifier(wm, MyEventHandler())
    notifier.loop()

def main():
    watch_error()




if __name__ == "__main__":
    main()