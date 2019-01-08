get-ADComputers -ExcludeClusters | % {
    try {
        $remoteTime = invoke-command -ComputerName $_ -ScriptBlock {get-date -format "HH:mm:ss"} -ErrorAction SilentlyContinue
        #Start-Sleep -s 2 #for debugging
        $currenttime = get-date -format "HH:mm:ss"
    if (Get-variable -Name remotetime)
    {
        if ($currenttime -eq $remotetime)
            {}
        else
            {
            try {
                $diff = New-timespan -Start $remoteTime -End $currenttime

                Write-Host "difference" $diff "at" $_ $currenttime $remotetime
                $tempsecond = New-TimeSpan -Seconds 1
                $tempsecondnegative = New-TimeSpan -Seconds -1 #for covering backwards
                if ($diff.TotalSeconds -gt $tempsecond.TotalSeconds -or $diff.TotalSeconds -lt $tempsecondnegative.TotalSeconds)
                    {Write-Warning "difference more than $tempsecond at $_" -Verbose}

            }
            catch 
            {}

            #Write-Host $_ $currenttime $remotetime
            
            }
        }
    }
    #{$Error[4] | Select –Property *}
    catch [System.Management.Automation.Remoting.PSRemotingTransportException]
    {Write-Host $_ }
    }
