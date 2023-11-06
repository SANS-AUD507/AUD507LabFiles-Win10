$TargetPath = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
$ShortcutFile = "c:\users\student\Desktop\Windows Terminal.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()

$TargetPath = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
$ShortcutFile = "c:\users\student\Desktop\WT-Admin.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()
#Set shortcut to run as admin by flipping the right bit
$bytes = [System.IO.File]::ReadAllBytes("c:\users\student\Desktop\WT-Admin.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes("c:\users\student\Desktop\WT-Admin.lnk", $bytes)

$TargetPath = "c:\users\student\aud507-labs"
$ShortcutFile = "c:\users\student\Desktop\AUD507-Labs.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()

$targetPath = 'c:\users\student\aud507-labs\scripts\launchBurp.cmd'
$ShortcutFile = "c:\users\student\Desktop\BurpProxy.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.IconLocation = 'C:\tools\burpsuite\burp.ico'
$Shortcut.Save()

# Pin Aud507-Labs Folder to Quick Access
$shortcut = New-Object -com shell.application
$shortcut.NameSpace("C:\Users\student\AUD507-Labs").Self.InvokeVerb("pintohome")