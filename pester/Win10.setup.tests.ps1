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

  #If the AWS config files are not there, then skip the AWS tests
  if( -not ( (Test-Path -Type Leaf -Path C:\users\student\.aws\credentials) -or (Test-Path -Type Leaf -Path C:\users\student\.aws\config) ) ) {
    Write-Host "Skipping AWS tests because config files do not exist"
    $skipAWS = $true
  }
  else {
    Write-Host 'Importing AWSPowershell.NetCore'
    Import-Module AWSPowershell.NetCore
    Write-Host 'Import complete'

    #Skip the Cloud Services context if there are no good AWS credentials
    $userARN = (Get-STSCallerIdentity).Arn
    if( $userARN -notlike '*student*'){
      Write-Host "Skipping AWS tests because Get-STSCallerIdentity did not return valid ARN"
      $skipAWS = $true
    }
  }

  #If the Azure configuration is not there, then skip the Azure tests
  if( -not (Test-Path -Type Leaf -Path C:\Users\student\.azure\azureProfile.json) ) {
    Write-Host "Skipping Azure tests because config files do not exist"
    $skipAzure = $true
  } 
  else {
    Write-Host 'Importing AZ Accounts module'
    Import-Module Az.Accounts
    Write-Host 'Import complete'

    Write-Host 'Importing AZ Compute module'
    Import-Module Az.Compute
    Write-Host 'Import complete'

    if((Get-AzTenant).Name -notlike '*sans*'){
      Write-Host "Skipping Azure tests because tenant is not correct"
      $skipAzure = $true
    }
  }
}

Describe 'Lab Setup tests for 507Win10 VM' {
  Context 'Network connectivity' {
    It 'Ping 507Ubuntu - HostOnly' {
        $res = Test-NetConnection -ComputerName ubuntu
        $res | Should -BeTrue -Because 'Ensure that second network adapter is set to Host-only'
    }

    It 'dns.google resolves' {
      (Resolve-DnsName -Name dns.google).Count | 
        Should -BeGreaterOrEqual 1 -Because 'Ensure that first network adapter is set to NAT'
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

  Context 'Configuration files' {
    It 'VS Code settings exist' {
      Test-Path -PathType Leaf -Path 'c:\users\student\appdata\roaming\code\user\settings.json' |
        Should -BeTrue -Because 'Ensure that you have run the VMSetup script on the desktop'
    }

    It 'Terminal settings exist' {
      Test-Path -PathType Leaf `
        -Path 'C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json' |
        Should -BeTrue -Because 'Ensure that you have run the VMSetup script on the desktop'
    }

    It 'Terminal state exist' {
      Test-Path -PathType Leaf `
        -Path 'C:\Users\student\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\state.json' |
        Should -BeTrue -Because 'Ensure that you have run the VMSetup script on the desktop'
    }

    It 'Firefox settings exist' {
      Test-Path -PathType Leaf `
        -Path 'c:\Program Files\Mozilla Firefox\distribution\policies.json' |
        Should -BeTrue -Because 'Ensure that you have run the VMSetup script on the desktop'
    }
  }

  Context 'Firefox Policies' {
    BeforeAll {
      $policies = (Get-Content 'c:\Program Files\Mozilla Firefox\distribution\policies.json' | ConvertFrom-Json).policies
    }

    It 'Retire.js updates disabled' {
      $policies.ExtensionSettings."@retire.js".updates_disabled |
        Should -BeTrue -Because 'Ensure the policies.json file for Firefox is correct'
    }

    It 'FoxyProxy updates disabled' {
      $policies.ExtensionSettings."foxyproxy@eric.h.jung".updates_disabled |
        Should -BeTrue -Because 'Ensure the policies.json file for Firefox is correct'
    }

    It 'Wappalyzer updates disabled' {
      $policies.ExtensionSettings."wappalyzer@crunchlabz.com".updates_disabled |
        Should -BeTrue -Because 'Ensure the policies.json file for Firefox is correct'
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

    It 'Retire.js version' {
      $ver = (osqueryi "select version from firefox_addons where identifier='@retire.js';" --json 2>$null | 
        ConvertFrom-Json).version
      $ver | Should -BeExactly '1.7.8'
    }

    It 'Wappalyzer' {
        $plugins.identifier | Should -Contain 'wappalyzer@crunchlabz.com' `
          -Because "Firefox must have been launched once to load addons. Launch Firefox and re-run the tests."
    }

    It 'Wappalyzer version' {
      $ver = (osqueryi "select version from firefox_addons where identifier='wappalyzer@crunchlabz.com';" --json 2>$null | 
        ConvertFrom-Json).version
      $ver | Should -BeExactly '6.10.67'
    }

    It 'FoxyProxy' {
        $plugins.identifier | Should -Contain 'foxyproxy@eric.h.jung' `
          -Because "Firefox must have been launched once to load addons. Launch Firefox and re-run the tests."
    }

    It 'FoxyProxy version' {
      $ver = (osqueryi "select version from firefox_addons where identifier='foxyproxy@eric.h.jung';" --json 2>$null | 
        ConvertFrom-Json).version
      $ver | Should -BeExactly '7.5.1'
    }
  }
  
  Context 'Cloud services - AWS' -skip:$skipAWS {
    BeforeAll{
      Import-Module AWSPowerShell.NetCore
    }

    It 'AWS ARN is set' {
      (Get-STSCallerIdentity).Arn | should -BeLike 'arn*student*' -Because 'AWS setup from lab 1.1 not correct'
    }    
    
    It 'AWS config is set to us-east-2 region' {
      'C:\users\student\.aws\config' | should -FileContentMatch 'region = us-east-2' -Because 'AWS setup from lab 1.1 not correct'
    }

    It 'AWS config is set to json output' {
      'C:\users\student\.aws\config' | should -FileContentMatch 'output = json' -Because 'AWS setup from lab 1.1 not correct'
    }

  }

  Context 'Cloud services - Azure' -Skip:$skipAzure {

    It 'Az CLI account is setup' {
      (az ad signed-in-user show | ConvertFrom-Json).userPrincipalName | 
        Should -BeLike 'student@*' `
        -Because 'Azure setup from lab 1.1 not correct'
    }

    It 'Az PowerShell module tenant is correct' {
      (Get-AzTenant).Name | should -BeLike 'sans*' `
        -Because 'Azure setup from lab 1.1 not correct'       
    }
  }
}