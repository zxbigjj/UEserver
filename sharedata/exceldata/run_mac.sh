export PYTHONPATH=./tools/py/lib/python2.7/site-packages:$PYTHONPATH
cd ./tools
python ./parse_xls.py
/usr/local/bin/lua generator_result.lua
cd ../
echo "generator success!"