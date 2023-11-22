<#
TODO: Get API token from nessus6.js ala Posh_nessus hack
TODO: Get list of template uuids to get the Basic San one
#>
[CmdletBinding()]
param (
    [string]$fileName = ".\windowsScan.json"
)

$body = @{
  'username' = 'student'
  'password' = 'student'
}

$baseUri = 'https://scanner.5x7.local:8834'
$uri = $baseUri + '/session'

$res = invoke-RestMethod -SkipCertificateCheck -Method Post `
  -uri $uri -body $body
"Token obtained: $($res.token)"

$js = (Invoke-WebRequest -SkipCertificateCheck -uri $baseUri/nessus6.js).rawContent
$m = ($js -split ";" ) -match "return`"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
$apiToken = ($m -replace '.*return"', '') -replace '".*', ''

$headers = @{
  'X-Api-Token' = "$apiToken"
  'X-Cookie' = "token=$($res.token)"
}
$headers
$uri = $baseUri + "/scans"

Invoke-RestMethod -uri $uri -SkipCertificateCheck -Method Get `
  -Headers $headers

$body=Get-Content $fileName
Invoke-RestMethod -uri $uri -SkipCertificateCheck -Method Post `
  -Headers $headers -Body $body -ContentType 'application/json'