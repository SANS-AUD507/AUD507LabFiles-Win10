[CmdletBinding()]
param (
  [string]$filePath = "c:\labFiles\scans"
)

function run-sshCommand {
  param (
    $Command = 'hostname'
  )
  ssh -i C:\Users\student\.ssh\ubuntukey student@ubuntu "$Command"
}

#Get an auth token for the local scanner
$body = @{
  'username' = 'student'
  'password' = 'student'
}

$baseUri = 'https://scanner.lab.local:8834'
$uri = $baseUri + '/session'

$tokenRes = Invoke-RestMethod -SkipCertificateCheck -Method Post `
  -Uri $uri -Body $body
"Token obtained: $($tokenRes.token)"

# Get the API key that magically makes everything in the API work,
# even though it shouldn't...
$js = (Invoke-WebRequest -SkipCertificateCheck -Uri $baseUri/nessus6.js).rawContent
$m = ($js -split ";" ) -match "return`"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
$apiToken = ($m -replace '.*return"', '') -replace '".*', ''

# Set the headers for authenticated requests
$headers = @{
  'X-Api-Token'  = "$apiToken"
  'X-Cookie'     = "token=$($tokenRes.token)"
  'accept'       = 'application/json'
  'content-type' = 'multipart/form-data'
}
$headers

#Import everything in the source folder
foreach ( $file in (Get-ChildItem $filePath)) {
  $filename = $file.fullname
  "`n-----------------------------------"
  "Processing: $filename"
  $form = @{
    Filedata = Get-Item -Path $filename
  }

  $uri = $baseUri + "/file/upload"
  $res = Invoke-RestMethod -Uri $uri -SkipCertificateCheck -Method Post `
    -Headers $headers -Form $form

  $fileId = $res.fileuploaded
  $body = @{'file' = "$fileId" }
  $body

  # Import the scan 
  $headers = @{
    'X-Api-Token' = "$apiToken"
    'X-Cookie'    = "token=$($tokenRes.token)"
    'accept'      = 'application/json'
  }
  #$headers

  $uri = $baseUri + "/scans/import"
  Invoke-RestMethod -Uri $uri -SkipCertificateCheck -Method Post `
    -Headers $headers -Body $body 
}

"`n-----------------------------------"
"Cleaning up file upload directory on Ubuntu"
"`nUploaded Files"
run-sshCommand -Command "sudo ls -l /opt/nessus/var/nessus/users/student/files/"
"`nRemoving files"
run-sshCommand -Command "sudo find /opt/nessus/var/nessus/users/student/files/ -type f | xargs sudo rm"
"`nDirectory contents after delete:"
run-sshCommand -Command "sudo ls -l /opt/nessus/var/nessus/users/student/files/"