<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Install-Server.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 29.03.2023
 	Author: Sylvain Philipona
 	Reason: Ajout de la gestion du redémarrage afin que le script continue aprés le redémarrage du serveur
 	*****************************************************************************
.SYNOPSIS
    Lance la création des services d'un serveur
 	
.DESCRIPTION
    Affiche une interface permettant à l'utilisateur de lancer la création des différents services d'un serveur.
    Ces services sont les suivants : AD DS, DNS, DHCP
 	
.OUTPUTS
	- Un serveur AD DC
    - Un serveur DNS
    - Un service DHCP

.EXAMPLE
    .\Install-Server.ps1

    ========= Installation de serveur =========
    1: Appuyer sur '1' pour Renommer le server 
    2: Appuyer sur '2' pour Installer l'AD     
    3: Appuyer sur '3' pour Installer le DHCP  
    Q: Appuyer sur 'Q' pour Quitter
    Sélectionnez une option: 
 	
.LINK
    Rename-Server.ps1
    Install-AD.ps1
    Install-DHCP.ps1
#>

# https://stackoverflow.com/questions/59502407/automatically-logon-after-restart
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value 1 -PropertyType String -Force
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUsername -Value "Administrateur" -PropertyType String -Force
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value ".Etml-" -PropertyType String -Force
New-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount -Value 10 -PropertyType DWORD -Force


# Create the main key if not exists
if(!(Test-path "HKLM:\SOFTWARE\SRV_INSTALLATION")){
    New-Item "HKLM:\SOFTWARE\SRV_INSTALLATION" | Out-Null
}

# Check if the server is renamed
try{
    Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\SRV_INSTALLATION" -Name "Name" | Out-Null
    Write-Host "Renamed" -ForegroundColor Green
}
catch{
    New-ItemProperty -Path "HKLM:\SOFTWARE\SRV_INSTALLATION" -Name "Name" -Value 1 -PropertyType DWord | Out-Null
    Write-Host "Renaming the server..." -ForegroundColor Cyan
    
    . "C:\temp\Server_installation\Start-Trigger.ps1"
    . "C:\temp\Server_installation\Rename-Server.ps1"
    exit
}

# Check if the AD is installed
try{
    Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\SRV_INSTALLATION" -Name "AD" | Out-Null
    Write-Host "AD installed" -ForegroundColor Green
}
catch{
    New-ItemProperty -Path "HKLM:\SOFTWARE\SRV_INSTALLATION" -Name "AD" -Value 1 -PropertyType DWord | Out-Null
    Write-Host "Installing the AD..." -ForegroundColor Cyan

    try{
        . "C:\temp\Server_installation\Start-Trigger.ps1"
        . "C:\temp\Server_installation\Install-AD.ps1"

    }catch{
        $_ >> "C:\Users\Administrateur\Desktop\log.txt"
    }
    exit
}





mkdir "C:\Users\Administrateur\Desktop\BONJOURERRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
Unregister-ScheduledJob -Name ServerInstallation -ErrorAction SilentlyContinue | Out-Null






# return


# # Affichage du menu
# function Show-Menu
# {
#     param (
#         [string]$Title = 'Installation de serveur'
#     )
#     Clear-Host
#     Write-Host "========= $Title ========="
    
#     Write-Host "1: Appuyer sur '1' pour Renommer le server"
#     Write-Host "2: Appuyer sur '2' pour Installer l'AD"
#     Write-Host "3: Appuyer sur '3' pour Installer le DHCP"
#     Write-Host "Q: Appuyer sur 'Q' pour Quitter"
# }

# # Boucle qui se répète tant que l'input est différent de 'q' ou 'Q' 
# do
# {
#     # Affiche le menu puis demande à l'utilisateur de faire une sélection
#     Show-Menu
#     $selection = Read-Host "Sélectionnez une option"

#     # Lance les différents scripts selon la sélection
#     switch ($selection)
#     {
#         '1' {
#             .\Rename-Server.ps1
#         } '2' {
#             .\Install-AD.ps1
#         } '3' {
#             .\Install-DHCP.ps1
#         }
#     }
# }
# until (@('q', 'Q').Contains($selection))