<#
.NOTES
    *****************************************************************************
    ETML
    Name:	Get-Constants.ps1
    Author:	Sylvain Philipona
    Date:	22.03.2023
 	*****************************************************************************
    Modifications
 	Date  : 23.03.2023
 	Author: Sylvain Philipona
 	Reason: Enregistement du fichier en UTF-8 with BOM
 	*****************************************************************************
.SYNOPSIS
    Fichier de constantes
 	
.DESCRIPTION
    Ce fichier contient toutes les constantes necessaires au bon fonctionement des scripts
 	
.OUTPUTS
	- Retourne un object PowerShell contenant toutes les constantes

.EXAMPLE
    .\Get-Constants.ps1

    Server                   AD                              DHCP
    ------                   --                              ----
    {Subnet, IP, Name, Mask} {AdminPassword, Domain, Forest} {StartScope, StopScope}
#>

return [PSCustomObject]@{
    Server = @{
        Name = "TPI-DC"
        IP = "192.168.1.1"
        Mask = "255.255.255.0"
        Subnet = "24"
    }

    AD = @{
        Forest = "local"
        Domain = "tpi"
        AdminPassword = ".Etml-"
    }

    DHCP = @{
        StartScope = "192.168.1.150"
        StopScope = "192.168.1.200"
    } 
}