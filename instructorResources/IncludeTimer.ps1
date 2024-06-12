#Super simple alias
Set-Alias -Name t -Value New-Timer
Set-Alias -Name c -Value New-Countdown

#HashTable of characters for the clock
#Letters was probably a stupid name, since there aren't many...
$letters = Import-LocalizedData -BaseDirectory . -FileName letters.psd1

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
  "M: Prompt for new timer minutes"
  "H: Toggle help display"
  "Q: Quit"
}
Function Write-ClockHelp {

  "Shortcut Keys"
  "-------------"
  "M: Toggle military (24h) time"
  "S: Toggle seconds display"
  "G: Set text color to green"
  "R: Set text color to red"
  "Y: Set text color to yellow"
  "B: Set text color to blue"
  "K: Set text color to black"
  "W: Set text color to white"
  "Q: Quit"
}


# TODO: Needs a function to start a timer that ends at a certain time (start of class, return from lunch, etc.)
function Start-Timer {
  [CmdletBinding()]
  param (
    [datetime]$StartTime,
    [datetime]$EndTime,
    $ShowEndTime,
    $UseThresholds,
    $ShowHelp
  )

  Clear-Host

  while ( (Get-Date) -lt $EndTime ) {

    $StatusMessage = "                                   "
   
    $ts = New-TimeSpan -Start (Get-Date) -End $EndTime

    #If the user presses a key, handle it
    while ( [Console]::KeyAvailable) {
      #Clear the screen, since we've been messing with cursor position
      Clear-Host
      $keyInfo = [Console]::ReadKey($true)
      switch ( $keyInfo.Key) {
        'Q' { return }
        'UpArrow' { 
          $EndTime = (Get-Date).AddMinutes([Math]::Ceiling($ts.TotalMinutes + .1))
          $EndTime = $EndTime.AddSeconds(1)
          $statusMessage = "Added 1 minute"
        }
        'DownArrow' { 
          $EndTime = (Get-Date).AddMinutes([Math]::Floor($ts.TotalMinutes))
          $EndTime = $EndTime.AddSeconds(1)
          $statusMessage = "Seconds set to zero"
        }
        'Z' {
          $EndTime = (Get-Date).AddMinutes([Math]::Floor($ts.TotalMinutes))
          $EndTime = $EndTime.AddSeconds(1)
          $statusMessage = "Seconds set to zero"
        }
        'T' { $UseThresholds = (-not $UseThresholds); $statusMessage = "Thresholds set to $useThresholds" }
        'M' { 
          "Set Minutes to:"
          $howmany = Read-Host
          [int]$min = 0
          if ( [int]::TryParse($howmany, [ref]$min) ) {
            $endTime = (Get-Date).AddMinutes($min).AddSeconds(1)
          }
        }
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
    
    "$statusMessage"
    if ($ShowEndTime) {
      Write-Host "Ends: $($endTime.ToLongTimeString())" -ForegroundColor Yellow
    }

    if ($showHelp) {
      Write-TimerHelp
    }
    Start-Sleep -Seconds 1
  }
}

#Function to create a timer which ends at a certain time.
function New-Countdown {
  [CmdletBinding()]
  param (
    [string]$EndingTime = "09:00",
    [Alias("E")]
    [switch]$ShowEndTime,
    [Alias("T")]
    [switch]$UseThresholds,
    [switch]$ShowHelp
  )

  $startTime = (Get-Date)
  $endTime = Get-Date -Date $EndingTime
  if ( $endTime -lt $startTime) {
    $endTime = $endTime.AddDays(1)
  }

  start-timer -StartTime $startTime -EndTime $endTime `
    -ShowEndTime $ShowEndTime -UseThresholds $UseThresholds -ShowHelp $ShowHelp
}

function New-Timer {
  [CmdletBinding()]
  param (
    [int]$Minutes = 0,
    [int]$Seconds = 0,
    [int]$Hours = 0,
    [Alias("E")]
    [switch]$ShowEndTime,
    [Alias("T")]
    [switch]$UseThresholds,
    [switch]$ShowHelp
  )

  $startTime = (Get-Date)
  $endTime = ($startTime).AddHours($Hours)
  $endTime = $endTime.AddMinutes($Minutes)
  $endTime = $endTime.AddSeconds($Seconds + 1)

  start-timer -StartTime $startTime -EndTime $endTime `
    -ShowEndTime $ShowEndTime -UseThresholds $UseThresholds -ShowHelp $ShowHelp
}
function Start-Clock {
  [CmdletBinding()]
  param (
    [string]$Color = "DarkGreen",
    [Alias("S")]
    [switch]$ShowSeconds,
    [Alias("M")]
    [switch]$Military,
    [Alias("D")]
    [switch]$ShowDate,
    [switch]$ShowHelp
  )

  Clear-Host
  while ( $true ) {

    if ( $ShowDate) { $StatusMessage = (Get-Date).ToLongDateString() }
    else { $StatusMessage = "                                " }
    
    $host.UI.RawUI.CursorPosition = @{ x = 0; y = 0 }

    #If the user presses a key, handle it
    while ( [Console]::KeyAvailable) {
      #Clear the host since we're about to print something new
      Clear-Host 
      $keyInfo = [Console]::ReadKey($true)
      switch ( $keyInfo.Key) {
        'Q' { return }
        'G' { $color = 'DarkGreen'; $statusMessage = "Color set to green" }
        'R' { $color = 'DarkRed'; $statusMessage = "Color set to red" }
        'Y' { $color = 'DarkYellow'; $statusMessage = "Color set to yellow" }
        'B' { $color = 'DarkBlue'; $statusMessage = "Color set to blue" }
        'K' { $color = 'Black'; $statusMessage = "Color set to black" }
        'W' { $color = 'White'; $statusMessage = "Color set to white" }
        'D' { $ShowDate = (-not $ShowDate); $StatusMessage = "ShowDate set to $ShowDate" }
        'M' { $Military = (-not $Military); $statusMessage = "Military set to $Military" }
        'S' { $ShowSeconds = (-not $ShowSeconds); $statusMessage = "ShowSeconds set to $ShowSeconds" }
        'H' { $ShowHelp = (-not $ShowHelp) }
      }

    }

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
    
    Write-Time -TimeString (Get-Date -Format $timeFormat) -Color $Color
    "$StatusMessage"
    if ($showHelp) {
      Write-ClockHelp
    }

    Start-Sleep -Seconds 1
  }
}