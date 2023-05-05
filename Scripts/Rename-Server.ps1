<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Rename-Server.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 23.03.2023
 	Author: Sylvain Philipona
 	Reason: Enregistement du fichier en UTF-8 with BOM
 	*****************************************************************************
.SYNOPSIS
    Renomme le PC
 	
.DESCRIPTION
    Renomme le PC puis le redémarre pour que la modification soit prise en compte
  	
.EXAMPLE
    .\Rename-Server.ps1

    AVERTISSEMENT : Les modifications seront prises en compte après le redémarrage de l'ordinateur DESKTOP-HE4GEDI.

.LINK
    Get-Constants.ps1
#>

# Obtiens les valeurs en constantes
$constants = .\Get-Constants.ps1
$ServerName = $constants.Server.Name

# Renomme le serveur
Rename-Computer -NewName $ServerName -Confirm:$false -Force