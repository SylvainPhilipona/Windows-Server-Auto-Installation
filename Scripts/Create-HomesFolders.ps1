# Obtiens les valeurs en constantes
$constants = .\Get-Constants.ps1
$ServerName = $constants.Server.Name
$HomeFolder = $constants.AD.Users.HomeFolder
$ShareName = $constants.AD.Users.ShareName

# Crée le dossier de shares
New-Item -ItemType Directory -Path $HomeFolder -Force -Confirm:$false

# Désactive l'héritage et enlève les droits d'accès aux utilisateurs
$acl = Get-ACL -Path $HomeFolder
$acl.Access | ForEach-Object{$acl.RemoveAccessRule($_)}
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule($acl.Owner,"FullControl","Allow")))
$acl.SetAccessRuleProtection($True, $True)
Set-Acl -Path $HomeFolder -AclObject $acl

# Partage le dossier en Control total à tout les utilisateurs
# Remove-SmbShare -Name $ShareName -Force -Confirm:$false
New-SmbShare -Name $ShareName -Description "Dossiers Home des utilisateurs" -Path $HomeFolder -Confirm:$false
Grant-SmbShareAccess -Name $ShareName -AccountName ((Get-SmbShareAccess -Name $ShareName).AccountName) -AccessRight Full -Force -Confirm:$false

New-ADUser -Name "sylphilipona" -GivenName "Sylvain" -Surname "Philipona" -AccountPassword (ConvertTo-SecureString ".Etml-123" -AsPlainText -Force) -HomeDirectory "\\$ServerName\$ShareName\sylphilipona" -HomeDrive "H:"
Enable-ADAccount "sylphilipona"