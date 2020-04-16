#in case of execution policy, use "Set-ExecutionPolicy Bypass -Scope CurrentUser"
while ($true) {
    $SignalStrength = (netsh wlan show interfaces) -Match '^\s+Signal' -Replace '^\s+Signal\s+:\s+',''
    #The `r (carriage return) is ignored in PowerShell (ISE) Integrated Scripting Environment host application console,
    #but it does work in a PowerShell console session.
    Write-Host "`rWi-Fi Signal Strength is $SignalStrength" -NoNewline
    Start-Sleep -Seconds 1
    }
