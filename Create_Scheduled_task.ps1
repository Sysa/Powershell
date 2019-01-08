
#$list_of_hosts = "TOK12SDGWDB01", "CME12SDGWDDB02", "QW12SDGWSDB1", "SNG12SDGWDB02", "QW12SDGWLDB01", "EQ12SDGWDB01", "CME12SDGWDDB01", "SNG12SDGWDB01", "TOK12SDGWDB02", "CME12SDGWCDB01", "CME12SDGWCDB02", "LN12SDGWLDB01", "LN12SDGWLDB02", "QW12SDGWCDB1", "QW12SDGWLDB02", "SYD12SDGWLDB1"


$script_block = {
try {
        $scheduled_task_action = New-ScheduledTaskAction -Execute 'C:\Xpit.com\Utilities\LogRipper\GWLogRipper.exe' -Argument '1,2,3' -WorkingDirectory 'C:\Xpit.com\Utilities\LogRipper\'
        $scheduled_task_trigger = New-ScheduledTaskTrigger -Daily -At 2am
        #don't forget to insert password!
        Register-ScheduledTask -Action $scheduled_task_action -Trigger $scheduled_task_trigger -TaskName "ArchivePerfCountersWithSQL" -Description "Automatically generated scheduled task" -User 'yourcompanyname\stasks' -Password 'pwd'
    }
catch
    {
        Write-Host "creating new task failed for host " $_
    }
try {
        #remove old scheduled task:
        Unregister-ScheduledTask -TaskName "ArchivePerfCounters" -Confirm:$false
    }
catch
    {
        Write-Host "removing old task failed for host " $_
    }
}

$list_of_hosts | % { 
    Write-Host $_
    Copy-Item C:\Steps.xml -destination \\$_\C$\xpit.com\Utilities\LogRipper\Steps.xml -Force
    
    Invoke-Command -ComputerName $_ -ScriptBlock $script_block

 }


 

