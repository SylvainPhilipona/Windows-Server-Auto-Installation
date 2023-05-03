<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Install-Server.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 03.05.2023
 	Author: Sylvain Philipona
 	Reason: Ajout de l'auto login après un redémarrage
 	*****************************************************************************
.SYNOPSIS
    Lance la création des services d'un serveur
 	
.DESCRIPTION
    
 	
.OUTPUTS
	- Un serveur AD DC
    - Un serveur DNS
    - Un service DHCP

.EXAMPLE
    .\Install-Server.ps1

    
 	
.LINK
    Get-Constants.ps1
    Start-Trigger.ps1
    Rename-Server.ps1
    Install-AD.ps1
    Install-DHCP.ps1

    https://stackoverflow.com/questions/59502407/automatically-logon-after-restart
#>

param(
    [string]$Location
)

if($Location){
    Set-Location $Location
}
else{
    $Location = $MyInvocation.MyCommand.Path
}


# Obtiens les valeurs en constantes
$constants = .\Get-Constants.ps1
$ServerInstallationsPath = $constants.Registry.Paths.ServerInstallations
$WinLogonPath = $constants.Registry.Paths.WinLogon
$AutoLogonCount = $constants.Registry.AutoLogonCount
$Username = $constants.User.Username
$Password = $constants.User.Password

# Crée les clé de registre permettant l'auto login lors du redémarrage du serveur
New-ItemProperty $WinLogonPath -Name AutoAdminLogon -Value 1 -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name DefaultUsername -Value $Username -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name DefaultPassword -Value $Password -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name AutoLogonCount -Value $AutoLogonCount -PropertyType DWORD -Force | Out-Null

# Crée la clé principale si elle n'existe pas déjà
if(!(Test-path $ServerInstallationsPath)){
    New-Item $ServerInstallationsPath | Out-Null
}

# Démarre le Job qui va réexecuter ce script au redémarrage
.\Start-Trigger.ps1 -Location $Location

# Vérifie si le serveur est déjà renommé, sinon le renomme
try{
    # Check si la clé de registre pour le renommage du serveur existe
    Get-ItemPropertyValue -Path $ServerInstallationsPath -Name "Name" | Out-Null
    Write-Host "Renamed" -ForegroundColor Green
}
catch{
    # Crée la clé de registre pour le renommage du serveur
    New-ItemProperty -Path $ServerInstallationsPath -Name "Name" -Value 1 -PropertyType DWord | Out-Null
    Write-Host "Renaming the server..." -ForegroundColor Cyan
    
    # Renomme le serveur puis le redémarre
    .\Rename-Server.ps1
    exit
}

# Vérifie si l'Active Directory est déjà installé, sinon l'installe
try{
    # Check si la clé de registre pour l'installation de l'AD existe
    Get-ItemPropertyValue -Path $ServerInstallationsPath -Name "AD" | Out-Null
    Write-Host "AD installed" -ForegroundColor Green
}
catch{
    # Crée la clé de registre pour l'installation de l'AD
    New-ItemProperty -Path $ServerInstallationsPath -Name "AD" -Value 1 -PropertyType DWord | Out-Null
    Write-Host "Installing the AD..." -ForegroundColor Cyan

    # Installe l'AD puis redémarre le serveur
    .\Install-AD.ps1
    exit
}

# Vérifie si le DHCP est déjà installé, sinon l'installe
try{
    # Check si la clé de registre pour l'installation du DHCP existe
    Get-ItemPropertyValue -Path $ServerInstallationsPath -Name "DHCP" | Out-Null
    Write-Host "DHCP installed" -ForegroundColor Green
}
catch{
    # Crée la clé de registre pour l'installation du DHCP
    New-ItemProperty -Path $ServerInstallationsPath -Name "DHCP" -Value 1 -PropertyType DWord | Out-Null
    Write-Host "Installing the DHCP..." -ForegroundColor Cyan

    # Installe le DHCP puis redémarre le serveur
    .\Install-DHCP.ps1
    exit
}

# Supprime le Job qui execute ce script au démarrage
Unregister-ScheduledJob -Name ServerInstallation -ErrorAction SilentlyContinue | Out-Null

# Supprime les clé de registre permettant l'auto login
Set-ItemProperty $WinLogonPath -Name AutoAdminLogon -Value 0 -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name DefaultUsername -Value 0 -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name DefaultPassword -Value 0 -PropertyType String -Force | Out-Null
New-ItemProperty $WinLogonPath -Name AutoLogonCount -Value 0 -PropertyType DWORD -Force | Out-Null