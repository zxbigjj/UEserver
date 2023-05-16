set PYTHONPATH=./tools/Python27/Lib/site-packages;%PYTHONPATH%
cd ./tools
.\\Python27\\python.exe -B .\\parse_xls.py
if ERRORLEVEL 1 (
    color 04 
    pause
)
.\\lua\\lua.exe .\\generator_result.lua
cd ../
echo "generator success!"