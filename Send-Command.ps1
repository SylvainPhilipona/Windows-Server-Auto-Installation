$computer = "192.168.56.102" # VM cli
# $computer = "192.168.56.105" # VM gui

$username = "Administrateur"
$password = ".Etml-" | ConvertTo-SecureString -AsPlainText -Force
$ScriptsFolder = "Scripts"
$TempFolder = "C:\temp"



$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$sess = New-PSSession -ComputerName $computer -Credential $cred
$sess

# Copy the scripts folder to the remote server
Invoke-Command -Session $sess -ScriptBlock {New-Item -Path "C:\temp" -ItemType Directory -Force -Confirm:$false | Out-Null}
Compress-Archive -Path ".\$ScriptsFolder" -DestinationPath ".\$ScriptsFolder.zip" -Force
$zip = (Get-Item -Path ".\$ScriptsFolder.zip").FullName
Copy-Item -path $zip -Destination "$TempFolder\" -ToSession $sess

Invoke-Command -Session $sess -ScriptBlock {
    Expand-Archive -Path "C:\temp\Scripts.zip" -DestinationPath "C:\temp" -Force
    Set-Location "C:\temp\Scripts"
    .\Install-Server.ps1 -Location "C:\temp\Scripts"
}




# Clean
# Invoke-Command -Session $sess -ScriptBlock {Set-Location "C:\"}
# Invoke-Command -Session $sess -ScriptBlock {rmdir "$TempFolder" -Confirm:$false -Force -Recurse}
# Invoke-Command -Session $sess -ScriptBlock {mkdir "$TempFolder" | Out-Null}
Remove-Item ".\$ScriptsFolder.zip"



Remove-PSSession -Session $sess