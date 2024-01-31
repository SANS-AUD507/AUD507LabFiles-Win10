@rem run as admin to make power settings
@rem larger fonts for terminal
copy /y C:\Users\student\AUD507-Labs\instructorResources\WTSettings-instructor.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

reg import c:\Users\student\AUD507-Labs\instructorResources\zoomit.reg

start c:\Users\student\AUD507-Labs\instructorResources\zoomit.exe

@rem set the monitor to never turn off
powercfg -change -monitor-timeout-ac 0