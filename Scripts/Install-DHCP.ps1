<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Install-DHCP.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 23.03.2023
 	Author: Sylvain Philipona
 	Reason: Résolution du warning demandant de terminer la configuration du DHCP
 	*****************************************************************************
.SYNOPSIS
    Installe un DHCP
 	
.DESCRIPTION
    Installe le service DHCP puis le configure

.EXAMPLE
    .\Install-DHCP.ps1

    COMMENTAIRES : L’installation a démarré...
    COMMENTAIRES : Poursuivre l’installation ?
    COMMENTAIRES : Le traitement des conditions préalables a démarré...
    COMMENTAIRES : Le traitement des conditions préalables a réussi.

    Success Restart Needed Exit Code      Feature Result
    ------- -------------- ---------      -------------- 
    True    No             Success        {Serveur DHCP, Outils du serveur DHCP}
    COMMENTAIRES : Installation réussie.
    AVERTISSEMENT : Attente du démarrage du service « Serveur DHCP (dhcpserver) »…
 	
.LINK
    Get-Constants.ps1
    
    https://www.technig.com/install-and-configure-dhcp-using-powershell-in-windows-server-2022/
    https://www.faqforge.com/windows/configure-dhcp-powershell/
    https://www.linkedin.com/pulse/resolved-dhcp-post-installation-warning-flag-going-server-haider
#>

# Obtiens les valeurs en constantes
$constants = .\Get-Constants.ps1
$ServerIP = $constants.Server.IP
$ServerName = $constants.Server.Name
$Mask = $constants.Server.Mask
$Forest = $constants.AD.Forest
$Domain = $constants.AD.Domain
$StartScope = $constants.DHCP.StartScope
$StopScope = $constants.DHCP.StopScope

#################################
#     Configuration du DHCP     #
#################################

# Installation des services DHCP
Install-WindowsFeature DHCP -IncludeManagementTools -Verbose

# Ajout du scope d'adresses assignables
Add-DhcpServerV4Scope -Name "DHCP Scope" -StartRange $StartScope -EndRange $StopScope -SubnetMask $Mask

# Ajout des serveurs DNS et DHCP dans l'étendue
Set-DhcpServerV4OptionValue -DnsServer $ServerIP -Router $ServerIP

# Définission de la durée du bail DHCP à 1 jour
Set-DhcpServerv4Scope -ScopeId $ServerIP -LeaseDuration 1.00:00:00

# Autorisation du serveur DHCP dans le DC
Add-DhcpServerInDC -DnsName "$ServerName.$Domain.$Forest" -IPAddress $ServerIP

# Redémarrage du service DHCP
Restart-service dhcpserver

# Résolution du warning demandant de terminer la configuration du DHCP
Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2