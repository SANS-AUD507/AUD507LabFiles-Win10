call C:\Users\student\AUD507-Labs\scripts\vmsetup.bat

@rem larger fonts for terminal
copy /y C:\Users\student\AUD507-Labs\instructorResources\WTSettings-instructor.json C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

reg import c:\Users\student\AUD507-Labs\instructorResources\zoomit.reg

start c:\Users\student\AUD507-Labs\instructorResources\zoomit.exe