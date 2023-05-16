import time

ts = '165649113655000002'
tsT = ts[:10]
print((time.strftime("%Y-%m-%d %H:%M", time.localtime(int(tsT)))))
