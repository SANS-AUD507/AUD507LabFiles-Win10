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