pwsh c:\users\student\aud507-labs\scriptstermLink.ps1
c:\tools\syspin.exe "C:\Program Files\Mozilla Firefox\firefox.exe" "Pin to taskbar"
c:\tools\syspin.exe "C:\Program Files\Microsoft VS Code\Code.exe" "Pin to taskbar"
c:\tools\syspin.exe "c:\users\student\Desktop\WindowsTerminal.lnk" "Pin to Start"
c:\tools\syspin.exe "c:\users\student\Desktop\WindowsTerminal.lnk" "Pin to Taskbar"

echo Copying Windows Terminal Settings JSON
mkdir c:\tools\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe
mkdir c:\tools\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState
copy /y c:\tools\WTSettings.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

echo Copying Firefox policies File
mkdir "c:\Program Files\Mozilla Firefox\distribution"
copy /y C:\Users\student\AUD507-Labs\scripts\policies.json "c:\Program Files\Mozilla Firefox\distribution\policies.json"
echo Setting default browser to FirefoxESR
setdefaultbrowser HKLM Firefox-308046B0AF4A39CB

echo Copying VS Code global settings JSON
copy /y C:\Users\student\AUD507-Labs\scripts\settings.json c:\users\student\appdata\roaming\code\user\settings.json


