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

$headers = @{
  'X-Api-Token' = 'fbfe05d0-7f52-4b95-a617-560e3cb3b07b'
  'X-Cookie' = "token=$($res.token)"
}
$headers
$uri = $baseUri + "/scans"

Invoke-RestMethod -uri $uri -SkipCertificateCheck -Method Get `
  -Headers $headers

$body=Get-Content $fileName
Invoke-RestMethod -uri $uri -SkipCertificateCheck -Method Post `
  -Headers $headers -Body $body -ContentType 'application/json'