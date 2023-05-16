set -e

export PYTHONPATH=./tools/py/lib/python2.7/site-packages:$PYTHONPATH
cd ./tools

chmod +x ./py/bin/python2.7
./py/bin/python2.7 ./parse_xls.py

chmod +x ./lua/lua
./lua/lua generator_result.lua
cd ../
echo "generator success!"
