@echo off
color C
title "<IslandServer>"
set loops=0
 
set serverExe=arma3server_x64.exe
set serverPort=2302
set serverMods=@DMServer
set clientMods=@DMClient

set profileName=!serverProfile
set serverConfig=!server.cfg
set basicConfig=!basic.cfg
set extraLaunchParameters=-high -enableHT -malloc=tbbmalloc_x64 -limitFPS=900 -exThreads=7 -maxMem=6655 -autoInit -loadMissionToMemory -hugePages -noSplash -noSound -noPause

:start
cls
:: Показываем параметры батника
echo ---------------------------------------------------
echo IslandServer - Info:
echo     Running on port: %serverPort% 
echo     ServerMods: %serverMods%,
echo     ClientMods: %clientMods%
echo     ServerCfgPath: %serverConfig%
echo     BasicCfgPath: %basicConfig%
echo     ProfilePath: %profileName%
echo ---------------------------------------------------
:: Выводим количество рестартов если они были
if "%loops%" NEQ "0" echo IslandServer - Server Restarts %loops%
:: Выводим время рестарта
echo ---------------------------------------------------
echo IslandServer - Server Running Since %time%
echo ---------------------------------------------------

"%serverExe%" -cfg=%basicConfig% -config=%serverConfig% -mod=%clientMods% -serverMod=%serverMods% -profiles=%profileName% -port=%serverPort% %extraLaunchParameters%
PING -n 10 127.0.0.1 > NUL
set /a loops += 1
goto start
