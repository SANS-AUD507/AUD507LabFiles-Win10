echo Running Follow-On Script
cd c:\labFiles\scripts

echo Copying Windows Terminal settings JSON
mkdir C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe
mkdir C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
copy /y c:\labFiles\config\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
copy /y c:\labFiles\config\WTState.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\state.json

pwsh c:\labFiles\scripts\termLink.ps1
c:\tools\syspin.exe "C:\Program Files\Mozilla Firefox\firefox.exe" "Pin to taskbar"
c:\tools\syspin.exe "C:\Program Files\Microsoft VS Code\Code.exe" "Pin to taskbar"
c:\tools\syspin.exe "c:\users\student\Desktop\Windows Terminal.lnk" "Pin to Start"
c:\tools\syspin.exe "c:\users\student\Desktop\Windows Terminal.lnk" "Pin to Taskbar"

echo Setting default browser to FirefoxESR
setdefaultbrowser HKLM Firefox-308046B0AF4A39CB

echo Copying VS Code global settings JSON
mkdir C:\Users\student\AppData\Roaming\code
mkdir C:\Users\student\AppData\Roaming\code\user
copy /y c:\labFiles\config\codeSettings.json c:\users\student\appdata\roaming\code\user\settings.json

echo Copying Firefox policies File
mkdir "c:\Program Files\Mozilla Firefox\distribution"
copy /y c:\labFiles\config\policies.json "c:\Program Files\Mozilla Firefox\distribution\policies.json" 

echo SSH Setup
mkdir c:\users\student\.ssh

copy /y c:\labFiles\config\almakey c:\users\student\.ssh
copy /y c:\labFiles\config\ubuntukey c:\users\student\.ssh

echo HOSTS file
copy /y c:\labFiles\config\hosts c:\windows\system32\drivers\etc\hosts

echo Setting default Terminal
reg import c:\labFiles\config\wt.reg

echo Disabling server manager on startup
reg import c:\labFiles\config\servermanager.reg

echo Setting desktop background
c:\tools\LGPO.exe /g c:\labFiles\config\desktopGPO

shutdown /r /t 5
