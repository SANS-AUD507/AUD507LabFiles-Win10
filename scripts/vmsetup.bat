echo Updating lab file repo
cd c:\users\student\aud507-labs
git pull
cd scripts

pwsh c:\users\student\aud507-labs\scripts\termLink.ps1
c:\tools\syspin.exe "C:\Program Files\Mozilla Firefox\firefox.exe" "Pin to taskbar"
c:\tools\syspin.exe "C:\Program Files\Microsoft VS Code\Code.exe" "Pin to taskbar"
c:\tools\syspin.exe "C:\Program Files\BurpSuitePro\BurpSuitePro.exe" "Pin to Start"
c:\tools\syspin.exe "c:\users\student\Desktop\WindowsTerminal.lnk" "Pin to Start"
c:\tools\syspin.exe "c:\users\student\Desktop\WindowsTerminal.lnk" "Pin to Taskbar"

echo Copying Windows Terminal settings JSON
mkdir c:\tools\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe
mkdir c:\tools\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
copy /y C:\Users\student\AUD507-Labs\config\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json


echo Setting default browser to FirefoxESR
setdefaultbrowser HKLM Firefox-308046B0AF4A39CB

echo Copying VS Code global settings JSON
mkdir C:\Users\student\AppData\Roaming\code
mkdir C:\Users\student\AppData\Roaming\code\user
copy /y C:\Users\student\AUD507-Labs\config\codeSettings.json c:\users\student\appdata\roaming\code\user\settings.json


echo Copying Firefox policies File
mkdir "c:\Program Files\Mozilla Firefox\distribution"
copy /y C:\Users\student\AUD507-Labs\config\policies.json "c:\Program Files\Mozilla Firefox\distribution\policies.json" 
