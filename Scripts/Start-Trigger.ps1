param(
    [Parameter(Mandatory=$true)]
    [string]$Location
)

if(!(((Get-ScheduledJob).Name) -Contains "ServerInstallation")){
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:15
    Register-ScheduledJob -Trigger $trigger -FilePath "$Location\Install-Server.ps1" -Name ServerInstallation -ArgumentList @($Location)

    # The purpose of adding a random delay to the start time of a scheduled task is to prevent all 
    # tasks from starting at exactly the same time, which can cause performance issues or overload the system. 
    # By adding a random delay, the tasks are staggered, which can help ensure that they all run smoothly 
    # and don't compete with each other for system resources.
}