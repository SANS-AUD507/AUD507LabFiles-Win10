$imagePath = "C:\aud1-labs\config\wallpaper_logo.png"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $imagePath
rundll32.exe user32.dll, UpdatePerUserSystemParameters