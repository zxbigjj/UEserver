#coding=utf-8
#自动扫描改动过的脚本
import time
import os, os.path

file_ts_dict = {}

def is_file_changed(filename):
	ts = os.path.getmtime(filename)
	if ts != file_ts_dict.get(filename, 0):
		file_ts_dict[filename] = ts
		return True
	return False

def get_changed_file(root):
	ret = []
	for sub in os.listdir(root):
		filename = root + "/" + sub
		if os.path.isdir(filename):
			ret.extend(get_changed_file(filename))
		elif os.path.isfile(filename):
			if not filename.endswith(".lua"):
				continue
			if is_file_changed(filename):
				ret.append(filename)
	return ret

def main():
	if not os.path.isfile("./status/reload.txt"):
		os.system("touch ./status/reload.txt")
	watch_root_list = [
		"./lualib",
		'./gamelogic/lualib',
	]
	excel_root = "./exceldata"
	service_root_list = ["./service", "./gamelogic/service"]
	for service_root in service_root_list:
		for sub in os.listdir(service_root):
			if os.path.isdir(service_root + "/" + sub):
				watch_root_list.append(service_root + "/" + sub)
	# loop
	first_loop = True
	while True:
		changed_list = []
		changed_excel_list = []
		while True:
			is_changing = False
			for watch_root in watch_root_list:
				tmp = get_changed_file(watch_root)
				if tmp:
					is_changing = True
					for x in tmp:
						if x not in changed_list:
							changed_list.append(x)
			tmp = get_changed_file(excel_root)
			if tmp:
				# 更新excel数据
				is_changing = True
				for x in tmp:
					if x not in changed_excel_list:
						changed_excel_list.append(x)
			if filter(is_file_changed, ['./bin/c2s.spb', './bin/s2c.spb']):
				# 更新协议
				is_changing = True
				x = "./gamelogic/lualib/node_base.lua"
				if x not in changed_list:
					changed_list.insert(0, x)
			if not is_changing:
				break
			else:
				time.sleep(1)
		if first_loop:
			first_loop = False
		elif changed_list or changed_excel_list:
			print changed_excel_list
			print changed_list
			with open("./status/reload.txt", "w") as fobj:
				if changed_excel_list:
					fobj.write("[data]\n")
					fobj.write("\n".join(changed_excel_list))
					fobj.write("\n")
				if changed_list:
					fobj.write("[script]\n")
					fobj.write("\n".join(changed_list))
					fobj.write("\n")
		time.sleep(1)

if __name__ == '__main__':
	main()