if x%1==x goto:help
set IP=%1
set BinFile=%CD%\build\esp32.esp32.esp32c3\SDWebServer.ino.bin
python %LOCALAPPDATA%\Arduino15\packages\esp32\hardware\esp32\2.0.7\tools\espota.py -i %IP% -p 3232 -a admin -f %BinFile%
goto :EOF
:help
Echo use %0 <IPadres>
:EOF
