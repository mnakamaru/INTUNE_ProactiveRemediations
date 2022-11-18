#=============================================================================================================================
#
# Script Name:     Remediate_WindowsHelloForBusiness_Required.ps1
# Description:     This script places the appropriate registry entry to ensure WHfB provisioning is not required
# Notes:           No variable substitution needed
#
#=============================================================================================================================
try {
    $RegPath = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork"
    $RegPathPIN = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork\PINComplexity"
    $RegPathTPM12 = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork\ExcludeSecurityDevices"
    $RegPathBiometrics = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider"
    # Create registry keys to make Windows Hello for Business provisioning optional
    New-Item -Path $RegPath -Force | Out-Null
    New-Item -Path $RegPathPIN -Force | Out-Null
    New-Item -Path $RegPathTPM12 -Force | Out-Null
    New-Item -Path $RegPathBiometrics -Force | Out-Null
    # Enable Hello for Business, make it optional, enable Pin Recovery
    New-ItemProperty -Path $RegPath -Name "Enabled" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name "DisablePostLogonProvisioning" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegPath -Name "EnablePinRecovery" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
    # Check PIN
    New-ItemProperty -Path $RegPathPIN -Name "MinimumPINLength" -Value 6 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegPathPIN -Name "MaximumPINLength" -Value 10 -PropertyType DWORD -Force | Out-Null
    Remove-ItemProperty -Path $RegPathPIN -Name "Expiration" -Force -ErrorAction SilentlyContinue | Out-Null
    # Check TPM 
    New-ItemProperty -Path $RegPath -Name "RequireSecurityDevice" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path $RegPathTPM12 -Name "TPM12" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
    # Enable Biometrics
    New-ItemProperty -Path $RegPathBiometrics -Name "Domain Accounts" -Value 0x00000001 -PropertyType DWORD -Force | Out-Null
}
catch{
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}