# Enable RDP
Write-Host "Enabling Remote Desktop..." -ForegroundColor Green

Set-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" `
    -Value 0

# Set RDP Port
New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" `
    -Name "PortNumber" `
    -PropertyType DWord `
    -Value 3389 `
    -Force | Out-Null

# Enable Firewall Rules
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

# Recreate TermService if missing
sc.exe create TermService `
    binPath= "C:\Windows\System32\svchost.exe -k termsvcs" `
    type= share `
    start= auto `
    error= normal `
    obj= "NT Authority\NetworkService" `
    DisplayName= "Remote Desktop Services" 2>$null

# Configure Service
sc.exe config TermService `
    binPath= "C:\Windows\System32\svchost.exe -k termsvcs" `
    type= share `
    start= auto `
    error= normal `
    obj= "NT Authority\NetworkService" `
    DisplayName= "Remote Desktop Services"

# Registry Settings
reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService /v Type /t REG_DWORD /d 32 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService /v Start /t REG_DWORD /d 2 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService /v ErrorControl /t REG_DWORD /d 1 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService /v DependOnService /t REG_MULTI_SZ /d RPCSS /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService /v ServiceSidType /t REG_DWORD /d 1 /f

reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters `
    /v ServiceDll `
    /t REG_EXPAND_SZ `
    /d C:\Windows\System32\termsrv.dll `
    /f

reg add HKLM\SYSTEM\CurrentControlSet\Services\TermService\Parameters `
    /v ServiceDllUnloadOnStop `
    /t REG_DWORD `
    /d 1 `
    /f

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" `
    /v termsvcs `
    /t REG_MULTI_SZ `
    /d TermService `
    /f

# Install RDS Role (Server OS only)
if ((Get-CimInstance Win32_OperatingSystem).ProductType -ne 1) {
    try {
        Install-WindowsFeature -Name RDS-RD-Server -IncludeManagementTools
    }
    catch {
        Write-Host "RDS Role install skipped." -ForegroundColor Yellow
    }
}

# Start Service
try {
    Set-Service -Name TermService -StartupType Automatic
    Start-Service -Name TermService
}
catch {
    Write-Host "Failed to start TermService." -ForegroundColor Red
}

# Verify
Write-Host "`nChecking RDP Listener..." -ForegroundColor Cyan
netstat -ano | findstr ":3389"

Write-Host "`nDone." -ForegroundColor Green
