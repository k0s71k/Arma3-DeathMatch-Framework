::@echo off
::color C
::set loops = 0
::set path_to_server=G:\DMServer
::set servermodlist=@DMServer;
::set modlist=@DMClient
::set server_cfg=!serverProfile\!server.cfg
::set basic_cfg=!serverProfile\!basic.cfg
::set extra_launch_parameters=-autoinit -enableHT -loadMissionToMemory -high -hugepages
::set profile_name=!serverProfile
::
:::start
::c:\Windows\System32\tasklist /FI "IMAGENAME eq arma3server_x64.exe" 2>NUL | c:\Windows\System32\find /I /N "arma3server_x64.exe">NUL
::if "%ERRORLEVEL%"=="0" goto loop
::
::echo <IslandServer> - Server started at %time% %date%
::
::if "%loops%" NEQ "0" (
::    echo <IslandServer> - Restarts: %loops%
::)
::set /A loops += 1
::start "%profile_name%" /HIGH /min /wait "%path_to_server%\arma3server_x64.exe" -servermod=%servermodlist% -mod=%modlist% "-config=%server_cfg%" "-cfg=%basic_cfg%" "-profiles=%profile_name%" "-name=%profile_name%" %extra_launch_parameters%
::c:\Windows\System32\taskkill /im arma3server_x64.exe
::goto started
:::loop
::cls
::echo <IslandServer> - Server is already running, running monitoring loop
::
:::started
::c:\Windows\System32\timeout /t 3
::c:\Windows\System32\tasklist /FI "IMAGENAME eq arma3server_x64.exe" 2>NUL | c:\Windows\System32\find /I /N "arma3server_x64.exe">NUL
::
::if "%ERRORLEVEL%"=="0" goto loop
::c:\Windows\System32\taskkill /im arma3server_x64.exe
::goto start


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