@echo off

rem DNS
REM ============================================================================================= 
set hostspath=%windir%\System32\drivers\etc\hosts

takeown /F  %hostspath%
cacls %hostspath% /t /e /g "Authenticated Users":f

copy  %hostspath%  %hostspath%.bk
move /Y %hostspath%.bk  %hostspath%

SET NEWLINE=^& echo.
echo %NEWLINE%^192.168.234.100 phippy.local phippy-api.local phippy-ui.local myapp.local wordpress.local >> %hostspath%
echo %NEWLINE%^192.168.234.100 k8s.local prometheus.local hubble-ui.local >> %hostspath%

echo %NEWLINE%^192.168.234.101 traefik.local >> %hostspath%