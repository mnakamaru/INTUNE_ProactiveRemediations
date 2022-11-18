#=============================================================================================================================
#
# Script Name:     Detect_Windows_Hello_for_Business_Enabled.ps1
# Description:     Detect if Workstation requires Windows Hello for Business provisioning (should be optional)
# Notes:           Remediate if "Match" if registry entry is non-existent or different than the correct value
#
#=============================================================================================================================
# Define Variables
try {
    $RegPath = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork"
    $RegPathPIN = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork\PINComplexity"
    $RegPathTPM12 = "HKLM:SOFTWARE\Policies\Microsoft\PassportForWork\ExcludeSecurityDevices"
    $RegPathBiometrics = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WinBio\Credential Provider"
    # Enable Hello for Business, make it optional, enable Pin Recovery
    $enabledHello = Get-ItemProperty -Path $RegPath -Name "Enabled" -ErrorAction SilentlyContinue
    $disablePostLogonProvisioning = Get-ItemProperty -Path $RegPath -Name "DisablePostLogonProvisioning" -ErrorAction SilentlyContinue
    $EnablePinRecovery = Get-ItemProperty -Path $RegPath -Name "EnablePinRecovery" -ErrorAction SilentlyContinue
    # Check PIN
    $minimumPINLength = Get-ItemProperty -Path $RegPathPIN -Name "MinimumPINLength" -ErrorAction SilentlyContinue
    $maximumPINLength = Get-ItemProperty -Path $RegPathPIN -Name "MaximumPINLength" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path $RegPathPIN -Name "Expiration" -Force -ErrorAction SilentlyContinue | Out-Null
    # Check TPM 
    $requireSecurityDevice = Get-ItemProperty -Path $RegPath -Name "RequireSecurityDevice" -ErrorAction SilentlyContinue
    $disableTPM12 = Get-ItemProperty -Path $RegPathTPM12 -Name "TPM12" -ErrorAction SilentlyContinue
    # Enable Biometrics
    $enableBiometrics = Get-ItemProperty -Path $RegPathBiometrics -Name "Domain Accounts" -ErrorAction SilentlyContinue
    if ($enabledHello.Enabled -eq 1 `
        -and $disablePostLogonProvisioning.DisablePostLogonProvisioning -eq 1 `
        -and $EnablePinRecovery.EnablePinRecovery -eq 1 `
        -and $minimumPINLength.MinimumPINLength -eq 6 `
        -and $maximumPINLength.MaximumPINLength -eq 10 `
        -and $requireSecurityDevice.RequireSecurityDevice -eq 1 `
        -and $disableTPM12.TPM12 -eq 1 `
        -and $enableBiometrics."Domain Accounts" -eq 1) {
        #Exit 0 for Intune and "No_Match" for SCCM, only remediate "Match"
        Write-Host "Match"
        exit 0
    } else {
        #Exit 1 for Intune. We want it to be within the last 7 days "Match" to remediate in SCCM
        Write-Host "No_Match"
        exit 1
    }
}
catch {
    $errMsg = $_.Exception.Message
    return $errMsg
    exit 1
}