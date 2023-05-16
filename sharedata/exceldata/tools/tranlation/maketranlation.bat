@echo off
rem if "%1" == "" goto label1
cd %1
set PYTHONPATH= ./../Python27/Lib/site-packages;%PYTHONPATH%
.\\..\\Python27\\python.exe -B .\\tranlation.py
if ERRORLEVEL 1 (
    color 04 
    pause
)
echo "tranlation finish!"
pause