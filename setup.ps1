########
# PowerShell-Skript zur Einrichtung von Chocolatey und OpenSSH-Server unter Windows
# Dieses Skript:
# - Setzt die Execution Policy auf RemoteSigned (nur für den aktuellen Benutzer)
# - Installiert Chocolatey, falls nicht vorhanden
# - Installiert und konfiguriert den OpenSSH-Server, falls nicht vorhanden
########

# Set PowerShell execution policy to RemoteSigned for the current user
# Überprüft und setzt die PowerShell Execution Policy, um Skriptausführung zu erlauben
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Verbose "Execution policy is already set to RemoteSigned for the current user, skipping..." -Verbose
}
else {
    Write-Verbose "Setting execution policy to RemoteSigned for the current user..." -Verbose
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

# Install chocolatey
# Prüft, ob Chocolatey (Paketmanager) installiert ist. Falls nicht, wird es installiert.
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Verbose "Chocolatey is already installed, skip installation." -Verbose
}
else {
    Write-Verbose "Installing Chocolatey..." -Verbose
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install OpenSSH Server
# Prüft, ob der OpenSSH-Dienst installiert ist. Falls nicht, erfolgt Installation und Konfiguration.
if ([bool](Get-Service -Name sshd -ErrorAction SilentlyContinue)) {
    Write-Verbose "OpenSSH is already installed, skip installation." -Verbose
}
else {
    Write-Verbose "Installing OpenSSH..." -Verbose

    # Holt verfügbare OpenSSH Server-Komponenten
    $openSSHpackages = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name

    # Installiert jede gefundene OpenSSH-Komponente
    foreach ($package in $openSSHpackages) {
        Add-WindowsCapability -Online -Name $package
    }

    # Startet und konfiguriert den SSH-Dienst
    Write-Verbose "Starting OpenSSH service..." -Verbose
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'

    # Überprüft, ob die Firewallregel für SSH bereits existiert, sonst wird sie erstellt
    Write-Verbose "Confirm the Firewall rule is configured..." -Verbose
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
    else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }
}