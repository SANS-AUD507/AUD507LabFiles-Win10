# Invoke this test on 507Win10 with this command:
<#
Set-Location c:\users\student\Aud507-Labs\pester
$config=New-PesterConfiguration
$config.Output.Verbosity='detailed'
$config.Run.Path='.\Win10.Setup.tests.ps1'
Invoke-Pester -Configuration $config
#>

BeforeDiscovery {
  #reduces verbose printing and causes a boolean return value instead of the whole result object
  $PSDefaultParameterValues['Test-NetConnection:InformationLevel'] = 'Quiet'

}

Describe 'Lab Setup tests for 507Win10 VM' {
    
  #Check basic network setup to ensure local and internet connectivity
  Context 'Network connectivity' {
    It 'Ping 507Ubuntu - HostOnly' {
        $res = Test-NetConnection -ComputerName ubuntu
        $res | Should -BeTrue -Because 'Ensure that second network adapter is set to Host-only'
    }

    It 'Ping Google - NAT' {
        $res = Test-NetConnection -ComputerName dns.google
        $res | Should -BeTrue -Because 'Ensure that first network adapter is set to NAT'
    }
  }

  Context 'Local system checks' {
    It 'Drive free space > 10GB' {
        (Get-PSDrive -name c).Free | Should -BeGreaterThan 10000000000 -Because 'VM disk is low on space'
    }
  }

  #The firefox plugins won't show up in osquery until the application has been run once, and
  #the polices.json file processed.
  Context 'Firefox plugins' {
    BeforeAll {
        $plugins = osqueryi "select * from firefox_addons;" --json 2>$null | ConvertFrom-Json
    }

    It 'Retire.js' {
        $plugins.identifier | Should -Contain '@retire.js' `
          -Because "Firefox must have been launched once to load addons. Launch Firefox and re-run the tests."
    }

    It 'Wappalyzer' {
        $plugins.identifier | Should -Contain 'wappalyzer@crunchlabz.com' `
          -Because "Firefox must have been launched once to load addons. Launch Firefox and re-run the tests."
    }

    It 'FoxyProxy' {
        $plugins.identifier | Should -Contain 'foxyproxy@eric.h.jung' `
          -Because "Firefox must have been launched once to load addons. Launch Firefox and re-run the tests."
    }
  }

}