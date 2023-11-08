#Secrets in plain text in the script here. Normally these would come from
#a secrets vault
$user = "student@5x7.local"
$pass = "student1234!"
$server = "https://fleet.5x7.local:8443"

#Get an auth token for the Fleet API
$body='{"email":"$user","password":"$pass"}'
$uri = "$server/api/v1/fleet/login"

$token = (Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck).token

"Token acquired: $token"
$ssToken = ConvertTo-SecureString -String $token -AsPlainText -Force

#Build up the API call to create the windows build number policy
#from the workbook
$polQuery = "select name, version, build, install_date from os_version where build in ('19046');"
$polName = "Windows build number (API created)"
$polDescription = "Find Windows machines with build == 19046"
$polResolution = "Schedule host for OS upgrade with change authorization board"

$body="{`"query`":`"$polQuery`",`"name`":`"$polName`",`"description`":`"$polDescription`",`"resolution`":`"$polResolution`"}"
$uri = "$server/api/v1/fleet/global/policies"

Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck -Authentication Bearer -Token $ssToken

"List of current policies:"
"-------------------------"

Invoke-RestMethod -SkipCertificateCheck `
  -uri 'https://fleet.5x7.local:8443/api/v1/fleet/global/policies' `
  -Authentication Bearer -Token $ssToken