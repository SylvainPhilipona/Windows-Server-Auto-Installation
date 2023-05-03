<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Install-AD.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 23.03.2023
 	Author: Sylvain Philipona
 	Reason: Enregistement du fichier en UTF-8 with BOM
 	*****************************************************************************
.SYNOPSIS
    Installe un Active Directory
 	
.DESCRIPTION
    Installe un annuaire Active Directory et le promouvoit en tant que controlleur de domaine.
    Un DNS est aussi installé avec l'AD.

.EXAMPLE
    .\Install-AD.ps1

    COMMENTAIRES : L’installation a démarré...
    COMMENTAIRES : Poursuivre l’installation ?
    COMMENTAIRES : Le traitement des conditions préalables a démarré...
    COMMENTAIRES : Le traitement des conditions préalables a réussi.

    Success       : True
    RestartNeeded : No
    FeatureResult : {Services AD DS, Gestion de stratégie de groupe, Outils d’administration de serveur distant, Centre
                    d’administration Active Directory...}
    ExitCode      : Success

    COMMENTAIRES : Installation réussie.
    AVERTISSEMENT : Les contrôleurs de domaine Windows Server 2022 offrent un paramètre de sécurité par défaut nommé
    « Autoriser les algorithmes de chiffrement compatibles avec Windows NT 4.0 ». Ce paramètre empêche l’utilisation
    d’algorithmes de chiffrement faibles lors de l’établissement de sessions sur canal sécurisé.
 	
    .....

.LINK
    Get-Constants.ps1

    https://www.dell.com/support/kbdoc/fr-ch/000121955/installation-de-active-directory-domain-services-and-promotion-the-server-to-a-domain-controller?lwp=rt
#>

# Obtiens les valeurs en constantes

$constants = . "C:\temp\Server_installation\Get-Constants.ps1"
$ServerIP = $constants.Server.IP
$Subnet = $constants.Server.Subnet
$Forest = $constants.AD.Forest
$Domain = $constants.AD.Domain
$AdminPassword = $constants.AD.AdminPassword

####################################################################################
#     Création de l'AD DS, configure le serveur comme DC et crée le serveur DNS    #
####################################################################################

# Défini l'adresse ip statique du serveur, le masque de sous réseau et la passerelle par défaut
New-NetIPAddress -IPAddress $ServerIP -InterfaceAlias "Ethernet" -DefaultGateway $ServerIP -AddressFamily IPv4 -PrefixLength $Subnet

# Défini le serveur DNS par défaut
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses ($ServerIP)

# Installation des services de domaine Active Directory
# Add-WindowsFeature AD-Domain-Services –IncludeManagementTools -Verbose
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools -Verbose

# Création de la fôret et du domaine 
# Le mot de passe 'SafeModeAdministratorPassword' est le mot de passe du mode de restauration des services d’annuaire (DSRM)
# Le serveur va être configuré en tant que controlleur de domaine
Install-ADDSForest -DomainName "$Domain.$Forest" -InstallDNS -SafeModeAdministratorPassword  (ConvertTo-SecureString $AdminPassword -AsPlainText -Force) -confirm:$false -Force -NoRebootOnCompletion

# Redémarre le serveur
Restart-Computer -Force