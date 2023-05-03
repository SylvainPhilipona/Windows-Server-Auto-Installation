$computer = "192.168.56.102"
$username = "Administrateur"
$password = ".Etml-" | ConvertTo-SecureString -AsPlainText -Force
$ScriptsFolder = "Server_installation"
$TempFolder = "C:\temp"



$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$sess = New-PSSession -ComputerName $computer -Credential $cred
$sess

# Copy the scripts folder to the remote server
Compress-Archive -Path ".\$ScriptsFolder" -DestinationPath ".\$ScriptsFolder.zip" -Force
$zip = (Get-Item -Path ".\$ScriptsFolder.zip").FullName
Copy-Item -path $zip -Destination "$TempFolder\" -ToSession $sess
Invoke-Command -Session $sess -ScriptBlock {Expand-Archive -Path "C:\temp\Server_installation.zip" -DestinationPath "C:\temp" -Force}
Invoke-Command -Session $sess -ScriptBlock {Set-Location "C:\temp\Server_installation"}





##### Execute the script #####
Invoke-Command -Session $sess -ScriptBlock { . "C:\temp\Server_installation\Install-Server.ps1"}





# Clean
# Invoke-Command -Session $sess -ScriptBlock {Set-Location "C:\"}
# Invoke-Command -Session $sess -ScriptBlock {rmdir "$TempFolder" -Confirm:$false -Force -Recurse}
# Invoke-Command -Session $sess -ScriptBlock {mkdir "$TempFolder" | Out-Null}
Remove-Item ".\$ScriptsFolder.zip"



Remove-PSSession -Session $sess