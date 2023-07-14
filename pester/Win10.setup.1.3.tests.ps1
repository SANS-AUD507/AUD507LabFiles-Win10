# Invoke this test on 507Win10 with this command:
<#
Set-Location c:\users\student\Aud507-Labs\pester
$config=New-PesterConfiguration
$config.Output.Verbosity='detailed'
$config.Run.Path='.\Win10.Setup.1.1.tests.ps1', '.\Win10.Setup.1.3.tests.ps1'
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

Describe 'Lab 1.3 Setup tests for 507Win10 VM' {
    
  Context 'Cloud services - AWS' -skip:$skipAWS {
    BeforeAll{
      Import-Module AWSPowerShell.NetCore
    }

    It '507DC is available over VPN' {
        $res = Test-NetConnection -ComputerName 507dc
        $res | Should -BeTrue -Because "VPN setup from lab 2.3 not correct."
    }

    It 'AWS ARN is set' {
      (Get-STSCallerIdentity).Arn | should -BeLike 'arn*student*' -Because 'AWS setup from lab 1.3 not correct'
    }    
  }

  Context 'Cloud services - Azure' -Skip:$skipAzure {

    It 'AWS config is set to us-east-2 region' {
      'C:\users\student\.aws\config' | should -FileContentMatch 'region = us-east-2' -Because 'AWS setup from lab 1.3 not correct'
    }

    It 'AWS config is set to json output' {
      'C:\users\student\.aws\config' | should -FileContentMatch 'output = json' -Because 'AWS setup from lab 1.3 not correct'
    }

    It 'Azure account is setup' {
      (az account show | ConvertFrom-Json).user.name | Should -BeLike 'student@*' -Because 'Azure setup from lab 1.3 not correct'
    }
  }
}