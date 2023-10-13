$TargetPath = "shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"
$ShortcutFile = "c:\users\student\Desktop\WindowsTerminal.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetPath
$Shortcut.Save()

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