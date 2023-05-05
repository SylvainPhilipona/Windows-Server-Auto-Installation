﻿<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Install-Server.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 05.05.2023
 	Author: Sylvain Philipona
 	Reason: Ajout d'un service
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
$Username = $constants.User.Username
$Password = $constants.User.Password

# Défini les services à installer
$Services = @{
    "1-Name" = ".\Rename-Server.ps1"
    "2-AD" = ".\Install-AD.ps1"
    "3-DHCP" = ".\Install-DHCP.ps1"
    "4-HOMES" = ".\Create-HomesFolders.ps1"
}

# Crée les clé de registre permettant l'auto login lors du redémarrage du serveur
Set-ItemProperty $WinLogonPath -Name AutoAdminLogon -Value 1 -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name AutoLogonCount -Value 60 -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name DefaultUsername -Value $Username -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name DefaultPassword -Value $Password -Force | Out-Null

# Crée la clé principale si elle n'existe pas déjà
if(!(Test-path $ServerInstallationsPath)){
    New-Item $ServerInstallationsPath | Out-Null
}

# Démarre le Job qui va réexecuter ce script au redémarrage
.\Start-Trigger.ps1 -Location $Location

# Lance l'installation de tout les services dans l'ordre
foreach($service in $services.GetEnumerator() | Sort-Object Name ){
    $serviceName = $service.Name
    $serviceInstaller = $service.Value

    # Vérifie si le service est déjà installé, sinon l'installe
    try{
        # Check si la clé de registre pour l'installation du service existe
        Get-ItemPropertyValue -Path $ServerInstallationsPath -Name $serviceName | Out-Null
    }
    catch{
        # Crée la clé de registre pour l'installation du service
        New-ItemProperty -Path $ServerInstallationsPath -Name $serviceName -Value 0 -PropertyType DWord | Out-Null
        mkdir "C:\Users\Administrateur\Desktop\$serviceName" | Out-Null
        msg * "Installation du service $servicename"

        # Installe le service
        . $serviceInstaller
        Set-ItemProperty -Path $ServerInstallationsPath -Name $serviceName -Value 1
        mkdir "C:\Users\Administrateur\Desktop\$serviceName-DONE" | Out-Null

        # Redémarre le serveur
        Restart-Computer -Force

        exit
    }
}

mkdir "C:\Users\Administrateur\Desktop\AAAAAAAAAAAA-1" | Out-Null

# Supprime les clé de registre permettant l'auto login
Set-ItemProperty $WinLogonPath -Name AutoAdminLogon -Value 0 -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name DefaultUsername -Value 0 -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name DefaultPassword -Value 0 -Force | Out-Null
Set-ItemProperty $WinLogonPath -Name AutoLogonCount -Value 0 -Force | Out-Null

mkdir "C:\Users\Administrateur\Desktop\AAAAAAAAAAAA-2" | Out-Null

msg * "L'installation des services s'est terminée correctement !"

mkdir "C:\Users\Administrateur\Desktop\AAAAAAAAAAAA-3" | Out-Null

# Supprime le Job qui execute ce script au démarrage
Unregister-ScheduledJob -Name ServerInstallation -Force -ErrorAction SilentlyContinue | Out-Null

mkdir "C:\Users\Administrateur\Desktop\AAAAAAAAAAAA-4" | Out-Null