#Super simple alias
Set-Alias -Name t -Value Start-Timer

#HashTable of characters for the clock
#Letters was probably a stupid name, since there aren't any...
$letters = @{}

$letters[' '] = @(
  "  ",
  "  ",
  "  ",
  "  ",
  "  ",
  "  ",
  "  "
)

$letters['A'] = @(
  " ### ",
  "#   #",
  "#   #",
  "#   #",
  "#####",
  "#   #",
  "#   #"
)

$letters['M'] = @(
  " # # ",
  "# # #",
  "# # #",
  "#   #",
  "#   #",
  "#   #",
  "#   #"
)

$letters['P'] = @(
  "###### ",
  "#     #",
  "#     #",
  "###### ",
  "#      ",
  "#      ",
  "#      "
)

$letters['0'] = @(
  "#####",
  "#   #",
  "#   #",
  "#   #",
  "#   #",
  "#   #",
  "#####"
)

$letters['1'] = @(
  "###  ",
  "  #  ",
  "  #  ",
  "  #  ",
  "  #  ",
  "  #  ",
  "#####"
)

$letters['2'] = @(
  "#####",
  "    #",
  "    #",
  "#####",
  "#    ",
  "#    ",
  "#####"
)

$letters['3'] = @(
  "#####",
  "    #",
  "    #",
  "#####",
  "    #",
  "    #",
  "#####"
)

$letters['4'] = @(
  "#   #",
  "#   #",
  "#   #",
  "#####",
  "    #",
  "    #",
  "    #"
)

$letters['5'] = @(
  "#####",
  "#    ",
  "#    ",
  "#####",
  "    #",
  "    #",
  "#####"
)

$letters['6'] = @(
  "#####",
  "#    ",
  "#    ",
  "#####",
  "#   #",
  "#   #",
  "#####"
)

$letters['7'] = @(
  "#####",
  "    #",
  "    #",
  "    #",
  "    #",
  "    #",
  "    #"
)

$letters['8'] = @(
  "#####",
  "#   #",
  "#   #",
  "#####",
  "#   #",
  "#   #",
  "#####" 
)

$letters['9'] = @(
  "#####",
  "#   #",
  "#   #",
  "#####",
  "    #",
  "    #",
  "#####"
)

$letters[':'] = @(
  "     ",
  "     ",
  "  #  ",
  "     ",
  "  #  ",
  "     ",
  "     "
)

function Write-Time {
  param (
    [string]$TimeString = "12:34",
    $Color = "DarkGreen"
  )
  
  
  $letterHeight = 7
  #Each letter will be seven lines high. Draw them in order with spaces
  for ( $line = 0; $line -lt $letterHeight; ++$line) {
    $outLine = ""
    for ( $i = 0; $i -lt $TimeString.length; $i++) {
      $c = $TimeString[$i]
      $outline += ($letters[[string]$c][$line] + " ") -replace '#', [char]0x2588
    }
    Write-Host $outLine -ForegroundColor $Color
    
    #endregion
  }
}

Function Write-TimerHelp {

  "Shortcut Keys"
  "-------------"
  "Up Arrow: Add 1 minute"
  "Down Arrow: Subtract 1 minute"
  "Z: Zero the seconds (Same as down arrow)"
  "T: Toggle threshold colors"
  "E: Toggle end time display"
  "H: Toggle help display"
  "Q: Quit"
}
Function Write-ClockHelp {

  "Shortcut Keys"
  "-------------"
  "M: Toggle military (24h) time"
  "S: Toggle seconds display"
  "Q: Quit"
}

function Start-Timer {
  [CmdletBinding()]
  param (
    [int]$Minutes = 15,
    [int]$Seconds = 0,
    [int]$Hours = 0,
    [switch]$ShowEndTime,
    [switch]$UseThresholds,
    [switch]$ShowHelp
  )

  $startTime = (Get-Date)
  $endTime = ($startTime).AddHours($Hours)
  $endTime = $endTime.AddMinutes($Minutes)
  $endTime = $endTime.AddSeconds($Seconds + 1)
  Clear-Host

  while ( (Get-Date) -lt $endTime ) {

    $StatusMessage = "                                   "
   
    $ts = New-TimeSpan -Start (Get-Date) -End $endTime

    #If the user presses a key, handle it
    while ( [Console]::KeyAvailable) {
      #Clear the screen, since we've been messing with cursor position
      Clear-Host
      $keyInfo = [Console]::ReadKey($true)
      switch ( $keyInfo.Key) {
        'Q' { return }
        'UpArrow' { 
          $endTime = (Get-Date).AddMinutes([Math]::Ceiling($ts.TotalMinutes + .1))
          $endTime = $endTime.AddSeconds(1)
          $statusMessage = "Added 1 minute"
        }
        'DownArrow' { 
          $endTime = (Get-Date).AddMinutes([Math]::Floor($ts.TotalMinutes))
          $endTime = $endTime.AddSeconds(1)
          $statusMessage = "Seconds set to zero"
        }
        'Z' {
          $endTime = (Get-Date).AddMinutes([Math]::Floor($ts.TotalMinutes))
          $endTime = $endTime.AddSeconds(1)
          $statusMessage = "Seconds set to zero"
        }
        'T' { $UseThresholds = (-not $UseThresholds); $statusMessage = "Thresholds set to $useThresholds" }
        'H' { $showHelp = (-not $showHelp) }
        'E' { $ShowEndTime = (-not $ShowEndTime) }
      }

    }
    
    $ts = New-TimeSpan -Start (Get-Date) -End $endTime
    
    $color = 'DarkGreen'
    #Use threshold colors
    if ( $UseThresholds ) {
      if ( $ts.TotalMinutes -lt 5) {
        $color = 'DarkYellow'
      }
      if ( $ts.TotalMinutes -lt 1 ) {
        $color = 'DarkRed'
      }
    }

    $timeString = $ts.Hours.ToString("00") + ":" + $ts.Minutes.tostring("00") + ":" + $ts.Seconds.ToString("00")
    $host.UI.RawUI.CursorPosition = @{ x = 0; y = 0 }
    Write-Time  -TimeString $timeString -Color $color
    
    "$statusMessage`n"
    if ($ShowEndTime) {
      Write-Host "Ends: $($endTime.ToLongTimeString())" -ForegroundColor Yellow
    }

    if ($showHelp) {
      Write-TimerHelp
    }
    Start-Sleep -Seconds 1
  }
}

function Start-Clock {
  [CmdletBinding()]
  param (
    [string]$Color = "DarkGreen",
    [switch]$ShowSeconds,
    [switch]$Military,
    [switch]$ShowHelp
  )

  Clear-Host
  while ( $true ) {

    $StatusMessage = "                                "
    $host.UI.RawUI.CursorPosition = @{ x = 0; y = 0 }

    #If the user presses a key, handle it
    while ( [Console]::KeyAvailable) {
      #Clear the host since we're about to print something new
      Clear-Host 
      $keyInfo = [Console]::ReadKey($true)
      switch ( $keyInfo.Key) {
        'Q' { return }
        'M' { $Military = (-not $Military); $statusMessage = "Military set to $Military" }
        'S' { $ShowSeconds = (-not $ShowSeconds); $statusMessage = "ShowSeconds set to $ShowSeconds" }
        'H' { $ShowHelp = (-not $ShowHelp) }
      }

    }
    
    $color = 'DarkGreen'
    if ( $Military) {
      $timeFormat = "HH:mm"
    }
    else {
      $timeFormat = "hh:mm"
    }

    if ( $ShowSeconds) {
      $timeFormat += ":ss"
    }

    if ( -not $Military ) {
      $timeFormat += " tt"
    }
    Write-Time -TimeString (Get-Date -Format $timeFormat)
    "$StatusMessage`n"
    if ($showHelp) {
      Write-ClockHelp
    }
    Start-Sleep -Seconds 1
  }
}