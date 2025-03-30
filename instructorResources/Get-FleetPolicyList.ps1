#Secrets in plain text in the script here. Normally these would come from
#a secrets vault
$user = "student@lab.local"
$pass = "student1234!"
$server = "https://fleet.lab.local:8443"

#Get an auth token for the Fleet API
$body="{`"email`":`"$user`",`"password`":`"$pass`"}"
$uri = "$server/api/v1/fleet/login"

$token = (Invoke-RestMethod -Body $body -Uri $uri `
  -ContentType 'application/json' -Method Post `
  -SkipCertificateCheck).token

"Token acquired: $token"
$ssToken = ConvertTo-SecureString -String $token -AsPlainText -Force
$uri = "$server/api/v1/fleet/global/policies"

"List of current policies:"
"-------------------------"

(Invoke-RestMethod -SkipCertificateCheck `
  -uri $uri `
  -Authentication Bearer -Token $ssToken).policies | Format-List *