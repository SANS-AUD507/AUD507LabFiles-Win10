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

$baseUri = 'https://scanner.lab.local:8834'
$uri = $baseUri + '/session'

$res = Invoke-RestMethod -SkipCertificateCheck -Method Post `
  -Uri $uri -Body $body
"Token obtained: $($res.token)"

# Get the API key that magically makes everything in the API work,
# even though it shouldn't...
$js = (Invoke-WebRequest -SkipCertificateCheck -Uri $baseUri/nessus6.js).rawContent
$m = ($js -split ";" ) -match "return`"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
$apiToken = ($m -replace '.*return"', '') -replace '".*', ''

# Set the headers for authenticated requests
$headers = @{
  'X-Api-Token' = "$apiToken"
  'X-Cookie'    = "token=$($res.token)"
}
$headers

$bodyObject = Get-Content $fileName | ConvertFrom-Json

# If no uuid is provide by the user, then
# get the uuid of the "basic" network scan from the scanner
# and insert it into the json data
if ( [string]::IsNullOrEmpty($uuid) ) {
  $uri = $baseUri + '/editor/scan/templates'
  $res = Invoke-RestMethod -SkipCertificateCheck -Method Get `
    -Uri $uri -Headers $headers
  $uuid = ($res.templates | Where-Object Name -EQ 'basic').uuid
  $uuid
  $bodyObject.uuid = $uuid
}

#Set the launch_now property to match the user parameters
$bodyObject.settings.launch_now = $launchNow

$body = $bodyObject | ConvertTo-Json -Compress -Depth 10

# Add the scan 

$uri = $baseUri + "/scans"
Invoke-RestMethod -Uri $uri -SkipCertificateCheck -Method Post `
  -Headers $headers -Body $body -ContentType 'application/json'
