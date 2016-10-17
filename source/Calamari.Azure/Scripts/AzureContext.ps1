﻿## Octopus Azure Context script, version 1.0
## --------------------------------------------------------------------------------------
## 
## This script is used to load the Azure Powershell module and select the Azure subscription
##
## The script is passed the following parameters. 
##
##   $OctopusUseBundledAzureModules = "true"
##   $OctopusAzureModulePath = "....\Calamari\AzurePowershell\Azure.psd1"
##   $OctopusAzureTargetScript = "..."
##   $OctopusAzureTargetScriptParameters = "..."
##   $UseServicePrincipal = "false"
##   $OctopusAzureSubscriptionId = "..."
##   $OctopusAzureStorageAccountName = "..."
##   $OctopusAzureCertificateFileName = "...."
##   $OctopusAzureCertificatePassword = "...."
##   $OctopusAzureADTenantId = "...."
##   $OctopusAzureADClientId = "...."
##   $OctopusAzureADPassword = "...."

if ([System.Convert]::ToBoolean($OctopusUseBundledAzureModules)) {
	# Add bundled Azure modules to PSModulePath
	$StorageModulePath = ([IO.Path]::Combine("$OctopusAzureModulePath", "Storage"))
	$ServiceManagementModulePath = ([IO.Path]::Combine("$OctopusAzureModulePath", "ServiceManagement"))
	$ResourceManagerModulePath = [IO.Path]::Combine("$OctopusAzureModulePath", "ResourceManager", "AzureResourceManager")
	Write-Verbose "Adding bundled Azure PowerShell modules to PSModulePath"
	$env:PSModulePath = $ResourceManagerModulePath + ";" + $ServiceManagementModulePath + ";" + $StorageModulePath + ";" + $env:PSModulePath
}

If ([System.Convert]::ToBoolean($OctopusUseServicePrincipal)) {
	# Authenticate via Service Principal
	$securePassword = ConvertTo-SecureString $OctopusAzureADPassword -AsPlainText -Force
	$creds = New-Object System.Management.Automation.PSCredential ($OctopusAzureADClientId, $securePassword)
	Write-Verbose "Authenticating with Service Principal"
	Login-AzureRmAccount -Credential $creds -TenantId $OctopusAzureADTenantId -SubscriptionId $OctopusAzureSubscriptionId -ServicePrincipal
} Else {
	# Authenticate via Management Certificate
	Write-Verbose "Loading the management certificate"
	Add-Type -AssemblyName "System"
	$certificate = new-object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($OctopusAzureCertificateFileName, $OctopusAzureCertificatePassword, ([System.Security.Cryptography.X509Certificates.X509KeyStorageFlags] "PersistKeySet", "Exportable"))
	$azureProfile = New-AzureProfile -SubscriptionId $OctopusAzureSubscriptionId -StorageAccount $OctopusAzureStorageAccountName -Certificate $certificate
	$azureProfile.Save(".\AzureProfile.json")
	Select-AzureProfile -Profile $azureProfile | Out-Null
} 

Write-Verbose "Invoking target script $OctopusAzureTargetScript with $OctopusAzureTargetScriptParameters parameters"

try {
	Invoke-Expression ". $OctopusAzureTargetScript $OctopusAzureTargetScriptParameters"
} catch {
	# Warn if FIPS 140 compliance required when using Service Management SDK
	if ([System.Security.Cryptography.CryptoConfig]::AllowOnlyFipsAlgorithms -and ![System.Convert]::ToBoolean($OctopusUseServicePrincipal)) {
		Write-Warning "The Azure Service Management SDK is not FIPS 140 compliant. http://g.octopushq.com/FIPS"
	}
	
	throw
}