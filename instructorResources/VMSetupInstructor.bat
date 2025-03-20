@rem run as admin to make power settings
@rem larger fonts for terminal
copy /y C:\Users\student\aud1-labs\instructorResources\WTSettings-instructor.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

reg import c:\Users\student\aud1-labs\instructorResources\zoomit.reg

start c:\Users\student\aud1-labs\instructorResources\zoomit.exe

@rem set the monitor to never turn off
powercfg -change -monitor-timeout-ac 0