if x%1==x goto:help
set IP=%1
set BinFile=%CD%\build\esp8266.esp8266.generic\SDWebServer.ino.bin
python %LOCALAPPDATA%\Arduino15\packages\esp8266\hardware\esp8266\3.1.2\tools\espota.py -i %IP% -p 8266 -a admin -f %BinFile%
goto :EOF
:help
Echo use %0 <IPadres>
:EOF
