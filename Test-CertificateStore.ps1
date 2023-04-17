
<#PSScriptInfo

.VERSION 1.2

.GUID 2014dca1-a0f1-4e02-ba3c-8f3e01aec1f6

.AUTHOR David Paulino

.COMPANYNAME UC Lobby

.COPYRIGHT

.TAGS Windows Server Certificates

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
  Version 1.0 – 2015/07/21 - Initial release
  Version 1.1 – 2018/08/01 - Check #7 - Expired certificates in Root, Intermediate and Personal Store.
  Version 1.2 - 2023/04/17 - Updated to publish in PowerShell Gallery
.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 This script checks for issues with certificates in the Certificate Store. 

#> 
Param()

$startTime = Get-Date;

Write-Host "Check #1: Misplaced certificates in Trusted Root CA" -ForegroundColor Cyan
$check = Get-Childitem cert:\LocalMachine\root -Recurse | Where-Object { $_.Issuer -ne $_.Subject }

if (($check).count -gt 0) {
    Write-Host "Found" ($check).count "misplaced certificate(s) in Trusted Root CA:" -ForegroundColor yellow
    $check | Select-Object Issuer, Subject, Thumbprint | Format-List
}
else {
    Write-Host "No misplaced certificate found in Trusted Root CA." -ForegroundColor Green
}

Write-Host "Check #2: Duplicates in Trusted Root CA" -ForegroundColor Cyan
$check = Get-Childitem cert:\LocalMachine\root | Group-Object -Property Thumbprint | Where-Object { $_.Count -gt 1 }

if (($check).count -gt 0) {
    Write-Host "Found" ($check).count "duplicated Trusted Root CA certificate(s):" -ForegroundColor yellow
    $check | Select-Object -ExpandProperty Group | Select-Object Issuer, Subject, Thumbprint -Unique | Format-List
}
else {
    Write-Host "No duplicated certificate(s) found." -ForegroundColor Green
}

Write-Host "Check #3: More than 100 certificates in Trusted Root CA store" -ForegroundColor Cyan
$check = (Get-Childitem cert:\LocalMachine\root).count

if ($check -gt 100) {
    Write-Host "Found" $check "Trusted Root CA certificates." -ForegroundColor yellow
}
else {
    Write-Host "Found" $check "Trusted Root CA certificates." -ForegroundColor Green
}

Write-Host "Check #4: Root CA certificates in Personal Store" -ForegroundColor Cyan
$check = Get-Childitem cert:\LocalMachine\my -Recurse | Where-Object { $_.Issuer -eq $_.Subject } 

if (($check).count -gt 0) {
    Write-Host "Found" ($check).count "Root CA certificate(s) in Personal Store:" -ForegroundColor yellow
    $check | Select-Object FriendlyName, Issuer, Subject, Thumbprint | Format-List
}
else {
    Write-Host "No Root CA certificate(s) found in Personal Store." -ForegroundColor Green
}


Write-Host "Check #5: Duplicated Friendly Name" -ForegroundColor Cyan
$check = Get-Childitem cert:\LocalMachine\my | Group-Object -Property FriendlyName | Where-Object { $_.Count -gt 1 } 

if (($check).count -gt 0) {
    Write-Host ("Found" + $check.count + "certificate(s) with the same Friendly Name:") -ForegroundColor yellow
    $check | Select-Object -ExpandProperty Group | Select-Object FriendlyName, Issuer, Subject, Thumbprint | Format-List
}
else {
    Write-Host "No duplicated certificate(s) found." -ForegroundColor Green
}

Write-Host "Check #6: Misplaced Root CA certificates in Intermediate CA store" -ForegroundColor Cyan
$check = Get-ChildItem Cert:\localmachine\CA | Where-Object { $_.Issuer -eq $_.Subject } 

if (($check).count -gt 0) {
    Write-Host "Found" ($check).count "misplaced Root CA certificate(s) in Intermediate CA store:" -ForegroundColor yellow
    $check | Select-Object Issuer, Subject, Thumbprint | Format-List
}
else {
    Write-Host "No misplaced Root CA certificate found." -ForegroundColor Green
}

Write-Host "Check #7: Expired certificates in Root, Intermediate and Personal Store" -ForegroundColor Cyan
$limit = Get-Date 
$checkMy = Get-ChildItem Cert:\LocalMachine\My |  ? { $_.NotAfter -le $limit } 
$checkRoot = Get-ChildItem Cert:\LocalMachine\Root |  ? { $_.NotAfter -le $limit } 
$checkCA = Get-ChildItem Cert:\LocalMachine\CA |  ? { $_.NotAfter -le $limit } 

if (($checkMy).count -gt 0) {
    Write-Host "Found" ($checkMy).count "expired certificate(s) in Personal store:" -ForegroundColor yellow
    $checkMy | Select-Object Issuer, Subject, Thumbprint, NotAfter | Format-List
}
else {
    Write-Host "No expired certificates in the Personal store." -ForegroundColor Green
}

if (($checkRoot).count -gt 0) {
    Write-Host "Found" ($checkRoot).count "expired certificate(s) in Root CA store:" -ForegroundColor yellow
    $checkRoot | Select-Object Issuer, Subject, Thumbprint, NotAfter | Format-List
}
else {
    Write-Host "No expired certificates in the Root CA Store." -ForegroundColor Green
}

if (($checkCA).count -gt 0) {
    Write-Host "Found" ($checkCA).count "expired certificate(s) in Intermediate CA store:" -ForegroundColor yellow
    $checkCA | Select-Object Issuer, Subject, Thumbprint, NotAfter | Format-List
}
else {
    Write-Host "No expired certificates in the Intermediate CA Store." -ForegroundColor Green
}

$endTime = Get-Date; 
$totalTime = [math]::round(($endTime - $startTime).TotalSeconds, 2)
Write-Host "Execution time:" $totalTime "seconds." -ForegroundColor Cyan