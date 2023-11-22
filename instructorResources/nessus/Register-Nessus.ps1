function run-sshCommand {
  param (
    $Command = 'hostname'
  )
  ssh -i C:\Users\student\.ssh\ubuntukey student@ubuntu "$Command"
}

$randomEmail = "a" + (Get-Random).toString() + "@b.co"

$body = "{`"email`":`"$randomEmail`",`"first_name`":`"fn`",`"last_name`":`"ln`"}"
$body

$uri = 'https://www.tenable.com/evaluations/api/v1/nessus/essentials'
$codeResult = Invoke-RestMethod -Uri $uri -ContentType 'application/json' `
  -Method Post -Body $body

$regCode = $codeResult.code

$regCode
$cmd = "sudo systemctl stop nessusd.service && sudo sudo /opt/nessus/sbin/nessuscli fetch --register $regCode && sudo systemctl start nessusd.service"
run-sshCommand -Command $cmd


