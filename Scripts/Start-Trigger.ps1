# Unregister-ScheduledJob -Name ServerInstallation -ErrorAction SilentlyContinue | Out-Null

if(!(((Get-ScheduledJob).Name) -Contains "ServerInstallation")){
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
    Register-ScheduledJob -Trigger $trigger -FilePath "C:\temp\Server_installation\Install-Server.ps1" -Name ServerInstallation 
}


# Problème de droit d'execution