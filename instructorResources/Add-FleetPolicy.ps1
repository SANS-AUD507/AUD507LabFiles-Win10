#Secrets in plain text in the script here. Normally these would come from
#a secrets vault
$user = "student@5x7.local"
$pass = "student1234!"
$server = "https://fleet.5x7.local:8443"

#Get an auth token for the Fleet API
$body="{`"email`":`"$user`",`"password`":`"$pass`"}"
$uri = "$server/api/v1/fleet/login"

$token = (Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck).token

"Token acquired: $token"
$ssToken = ConvertTo-SecureString -String $token -AsPlainText -Force

#Build up and run the API call to create the windows build number policy
#from the workbook
$polQuery = "select name, version, build, install_date from os_version where build in ('19998','19999');"
$polName = "Windows build number (API created)"
$polDescription = "Find Windows machines with build == (19998 OR 19999)"
$polResolution = "Schedule host for OS upgrade with change authorization board"
$polPlatform = "windows"

$body=@"
{
  `"query`":`"$polQuery`",
  `"name`":`"$polName`",
  `"description`":`"$polDescription`",
  `"resolution`":`"$polResolution`",
  `"platform`":`"$polPlatform`"
}
"@
$uri = "$server/api/v1/fleet/global/policies"

Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck -Authentication Bearer -Token $ssToken

#Build up and run the API call to create an OSQuery version policy
$polQuery = "SELECT version FROM osquery_info where version like '5.8.%';"
$polName = "Osquery version number (API created)"
$polDescription = "Find all machines with osquery build == 5.8.*"
$polResolution = "Schedule host for osquery upgrade with system engineering team"

$body="{`"query`":`"$polQuery`",`"name`":`"$polName`",`"description`":`"$polDescription`",`"resolution`":`"$polResolution`"}"
$uri = "$server/api/v1/fleet/global/policies"

Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck -Authentication Bearer -Token $ssToken

#Queries

#Windows Software
$q = 'select name, version, install_date from programs;'
$uri = "$server/api/v1/fleet/queries"
$body=@"
{
  `"query`":`"$q`",
  `"name`":`"Windows software`",
  `"platform`":`"windows`"
}
"@

Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck -Authentication Bearer -Token $ssToken

#All OS versions
$q = 'SELECT name,version FROM os_version;'
$uri = "$server/api/v1/fleet/queries"
$body=@"
{
  `"query`":`"$q`",
  `"name`":`"Host OS Inventory`"
}
"@

Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck -Authentication Bearer -Token $ssToken
