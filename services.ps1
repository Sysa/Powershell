# Example of usage: 
# install-service.ps1 -Type Stop -ServiceName Jenkins -WorkDir 'C:\Temp' -ServiceUsername **** -ServicePassword ****

param(
    [Parameter(Mandatory=$true)] 
    [ValidateSet("Setup", "Remove", "Stop", "Start", "HardStop", "NetStop", "NetStart")]
    [alias('t')]
    [string]$Type ="Setup",

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [alias('s')]
    [string]$ServiceName,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [alias('w')]
    [string]$WorkDir,

    [Parameter(Mandatory=$false)]
    [alias('u')]
    [string] $ServiceUsername = "$env:USERDOMAIN\$env:USERNAME",

    [Parameter(Mandatory=$false)]
    [alias('p')]
    [string] $ServicePassword

)

Begin {
    Clear-Host
    $global:Filter = 'Name=' + "'" + $ServiceName + "'" + ''
    $global:ServiceName =  $ServiceName
    $RetryInterval = 2 ## seconds
}

Process {

    function uStart-Service ($serv){
        $start = $serv.StartService().ReturnValue

        if ($start -eq 0) {
            Write-Host -NoNewline ("`nStartService() request accepted. Awaiting 'started' status.")

            while ($(Get-WmiObject -Class Win32_Service -Filter $global:Filter).Stoped) {
                Start-Sleep -s $RetryInterval
                Write-Host -NoNewline "."
            }
            Write-Host "`nDone"

        } else {
            Write-Host ("Failed to start service. ReturnValue was '{0}'." -f $start) -ForegroundColor "red"
            sc.exe qc "$global:ServiceName"
            sc.exe start "$global:ServiceName"
        }

    }

    function uStop-Service ($serv){
        
        #getting PID of the service by name:
        $process = Get-Process | Where-Object Name -EQ $serv.Name
        
        $stop = $serv.StopService().ReturnValue
        
        if ($stop -eq 0) {
            Write-Host -NoNewline ("StopService request accepted. Awaiting 'stopped' status.")

            while ($(Get-WmiObject -Class Win32_Service -Filter $global:Filter).Started) {
                Start-Sleep -s $RetryInterval
                Write-Host -NoNewline "."
            }
            Write-Host "`nStop"
        } else {
            Write-Host ("Failed to stop service. ReturnValue was '{0}'." -f $stop) -ForegroundColor "red"
            sc.exe qc "$global:ServiceName"
            sc.exe stop "$global:ServiceName"
        }

        #waiting for PID, it can be running for a while:
        $process = Get-Process | Where-Object Name -EQ $serv.Name
        $StopConditionCounter = 0 # This is counter as flag for stop `while` statement below

        while ($StopConditionCounter -lt 50){  # 50 iterations with the 2 seconds delay 
                                               # (delay value placed in RetryInterval variable)
                                               # 50 iterations ~= 100 seconds ~= 1,6 min - should be more than enough

            $process = Get-Process | Where-Object Name -EQ $serv.Name -ErrorAction SilentlyContinue
                                                                    # `-ErrorAction SilentlyContinue`
                                                                    # need to avoid exceptions when process will be finally stopped
            if($process.Id)
            {
                write-host "Process ID " $process.ID " Named as " $process.Name " is still running"
                $StopConditionCounter++
                if($StopConditionCounter -eq 49)
                {
                    write-host "Process is not responding. Kill " $process.ID
                    Stop-Process -Id $process.ID -Force
                }
            }
            else
            {
                write-host "Process successfully exited"
                $StopConditionCounter = 999
            }
            Start-Sleep -Seconds $RetryInterval #2 sec
            }
    }

    function uRemove-Service ($serv){
        Write-Host ("`nDeleteService().")
        #$del = $serv.Delete().ReturnValue
        #if ($del -ne 0) {
            #Write-Host ("Failed to delete service. ReturnValue was '{0}'." -f $del) -ForegroundColor "red"
            sc.exe qc "$global:ServiceName"
            sc.exe delete "$global:ServiceName"
        #}
    }

    function uHardStop-Service (){
        $ServicePID = (get-wmiobject win32_service | where { $_.name -eq $global:ServiceName}).processID

        if($ServicePID -ne 0){
            Write-Host ("HardStop service $global:ServiceName, with kill process pid [$ServicePID]") -ForegroundColor "red"

            taskkill /f /pid $ServicePID

            sc.exe query "$global:ServiceName"
        } else {
             Write-Host ("For $global:ServiceName the process doesn't exists") -ForegroundColor "red"
        }
    }

    function uNetStop-Service (){
        Write-Host ("NetStop service $global:ServiceName") -ForegroundColor "red"

        net stop "$global:ServiceName"
    }

    function uNetStart-Service (){
        Write-Host ("NetStart service $global:ServiceName") -ForegroundColor "red"

        net start "$global:ServiceName"
    }

     function uCheckStatus($expectedStatus){
        sleep(5)
        $arrService = Get-Service -Name $global:ServiceName
        $i=0
        While ($arrService.Status -ne $expectedStatus){
            sleep(10)
            $arrService.Refresh()
            if ($i -ne 6) {
                ++$i
                Continue
            }
            if ($arrService.Status -ne  $expectedStatus){
                Write-Host ("Failed to check status service.EXP[$expectedStatus] but service.ACT[$($arrService.Status)]") -ForegroundColor "red"
                exit 1
            }
        }
        Write-Host ("Status Service $global:ServiceName is [$($arrService.Status)]")
     }

    #Script

    if ($Type -eq 'HardStop') {
        uHardStop-Service $ServiceName
    }

    if ($Type -eq 'NetStart') {
        uNetStart-Service $ServiceName
        uCheckStatus 'Running'
    }

    if ($Type -eq 'NetStop') {
        uNetStop-Service $ServiceName
    }

	Try {
		#if (Get-Service $ServiceName -ErrorAction stop) {
			$service = Get-WmiObject -Class Win32_Service -Filter $global:Filter -ErrorAction Stop
			
			#write-host $service
			if ($service.DisplayName -gt 0)
			{
				Write-Host "Service exist";
				Write-Host $service.DisplayName
				$service_exist_flag = $true
			}
			else {
				Write-Host "Service does NOT exist"
				$service_exist_flag = $false
			}
				
				if ($Type -eq 'Start') {
					if($service_exist_flag){
						uStart-Service $service
						uCheckStatus 'Running'
						exit 0
					}
					else {
						Write-Host "Service does not exist"
						exit 1
						}
				}

				if ($Type -eq 'Stop') {
					if($service_exist_flag){
						uStop-Service $service
						exit 0
					}
					else {
						Write-Host "Service does not exist"
						exit 0
					}
				}

				if ($Type -eq 'Remove') {
					if($service_exist_flag) {
						Get-Service $ServiceName
						if ($(Get-Service $ServiceName).Status -eq "Running") {
							uStop-Service $service
						}

						uRemove-Service $service
						sleep(3)
					}
					else
					{
						Write-Host "Service does not exist"
						exit 0
					}
				}
			


		#}
	}
	Catch #[Microsoft.PowerShell.Commands.ServiceCommandException]
	{
		write-host $Error[0].Exception
		exit 1
	}

    if ($Type -eq 'Setup') {
        Write-Host "Setup $ServiceName"

        $binPath = "$WorkDir\$ServiceName.exe"

        Write-Host $binPath

        New-Service -name $ServiceName -displayName $ServiceName -binaryPathName $binPath

        $service = Get-WmiObject -Class Win32_Service -Filter $global:Filter

        $change = $service.Change($null, $null, $null, $null, $null, $null, $ServiceUsername, $ServicePassword).ReturnValue

        if ($change -eq 0) {
            Write-Host ("`nService Change() request accepted.")
        } else {
            Write-Host ("Failed to change service credentials. ReturnValue was '{0}'" -f $change) -ForegroundColor "red"
            exit 1
        }

        $start = $service.StartService().ReturnValue
		
		#uStart-Service $service
		uCheckStatus 'Running'
		

        if ($start -eq 0) {
            Write-Host ("`nStartService() request accepted.")
            exit 0
        } else {
            Write-Host ("Failed to start service. ReturnValue was '{0}'." -f $start) -ForegroundColor "red"
            exit 1
        }
    }

    exit 0
}

End { }