<#
TODO: Get API token from nessus6.js ala Posh_nessus hack
TODO: Get list of template uuids to get the Basic San one
#>
[CmdletBinding()]
param (
    [string]$fileName = ".\windowsScan.json",
    [string]$uuid,
    [boolean] $launchNow = $true
)

#Get an auth token for the local scanner

$body = @{
  'username' = 'student'
  'password' = 'student'
}

$baseUri = 'https://scanner.5x7.local:8834'
$uri = $baseUri + '/session'

$res = invoke-RestMethod -SkipCertificateCheck -Method Post `
  -uri $uri -body $body
"Token obtained: $($res.token)"

# Get the API key that magically makes everything in the API work,
# even though it shouldn't...
$js = (Invoke-WebRequest -SkipCertificateCheck -uri $baseUri/nessus6.js).rawContent
$m = ($js -split ";" ) -match "return`"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
$apiToken = ($m -replace '.*return"', '') -replace '".*', ''

# Set the headers for authenticated requests
$headers = @{
  'X-Api-Token' = "$apiToken"
  'X-Cookie' = "token=$($res.token)"
}
$headers

$bodyObject =Get-Content $fileName | ConvertFrom-Json

# If no uuid is provide by the user, then
# get the uuid of the "basic" network scan from the scanner
# and insert it into the json data
if ( [string]::IsNullOrEmpty($uuid) ) {
  $uri = $baseUri + '/editor/scan/templates'
  $res = invoke-RestMethod -SkipCertificateCheck -Method Get `
    -uri $uri -Headers $headers
  $uuid = ($res.templates | Where-Object Name -eq 'basic').uuid
  $uuid
  $bodyObject.uuid = $uuid
}

#Set the launch_now property to match the user parameters
$bodyObject.settings.launch_now = $launchNow

$body = $bodyObject | ConvertTo-Json -Compress

# Add the scan 

$uri = $baseUri + "/scans"
Invoke-RestMethod -uri $uri -SkipCertificateCheck -Method Post `
  -Headers $headers -Body $body -ContentType 'application/json'