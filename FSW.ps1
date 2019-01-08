#File Share Witness report.
#alexh@companyname.com

function CheckFSWpath ($PathValue)
{
    
    Get-ChildItem -path $PathValue.value | Select-Object Name, LastWriteTime, FullName | ForEach-Object -Process {
        
        Get-ChildItem -File -path $_.FullName | Select-Object Name, LastWriteTime | Where-Object {($_.Name -like "*.txt*")} | ForEach-Object -Process {
            
            $Result=$_.LastWriteTime

        }

    }

    return $Result
}


#table style:
$html_Css="<style>
table{
	border:1;
	align:center;
    font: normal 12px/150% Arial, Helvetica, sans-serif;
}
table td{
	align:center;
    padding: 5px 5px;
}
.WarningClass{
    background:red;
}
</style>"

#create HTML-skeleton
$Html_before=$html_Css + "<center><table border='1'><tr><td>Cluster</td><td>Owner Node</td><td>Status</td><td>Separate Monitor</td><td>Restart Policy</td><td>Last heartbeat (LT)</td></tr>"
$Html_after="</table></center>"

#clean variables:
$FSW_INFO="";
$FSW_info_To_HTML="";

#let's start:
Get-ADComputers -AdsPathMatch "(OU=MSGRCluster|OU=APPCluster)" | % {
    
    #set value of variables:
    $TdStateClass="";
    $PrependFlag=0;
    $ClusterExistFlag=0;
    $TdStatusClass="";
    $FSW_Status_flag=2;
    $Check_FSW_File="";
	$add_comment="";
    $FSW_restart_police="";
    $td_restart_class=""
    $current_date=Get-Date
	
    #check OS version:
	$OS = Get-WmiObject -Computer $_ -Class Win32_OperatingSystem 
		$OS.Caption
		if($OS.Caption -like "*2003*")
		{
            #check file, cause in 2003 server cluster resource not allowed to provide state status via remote connect:
			 Get-ChildItem -File -path "\\DGWNAS.companyname.COM\D$\MNSClusters\$_\" -Recurse | Select-Object Name, LastWriteTime | Where-Object {($_.Name -like "*.txt*")} | ForEach-Object -Process {
                            #date of FSW file doesn't be older than one day in 2003 Server.
                                    if($current_date.ToShortDateString() -eq $_.LastWriteTime.ToShortDateString())
                                    {
                                        $Check_FSW_File="";
                                        $add_comment+=$_.LastWriteTime
                                        $TD_FSW_path_class="";
                                        $add_comment+=" - All good."
                                    }
                                    else
                                    {
                                        $TD_FSW_path_class="WarningClass";
                                        $PrependFlag=1;
                                        $Check_FSW_File="";
                                        $add_comment+=$_.LastWriteTime
                                        $add_comment+=" - Most likely there are 2(!) or more folders with FSW - need to find and delete older folders. [need manual investigation, cause this is 2003 Server] ";
                                    }} #foreach and else closing:

                                    $add_comment+=" <br> Cluster exist. 2003 Server." # which doesn't allow get quorum resource remotely.
		}
		else
	{
	#if it's not 2003 OS, so gets cluster resources and their states:

    $FSW_INFO=Get-ClusterResource -cluster $_ -Name "File Share Witness" | Select-Object Cluster,OwnerNode,State,SeparateMonitor,RestartAction

    if($FSW_INFO.SeparateMonitor -like "*False*") {$TdStateClass="WarningClass";$PrependFlag=1;}
    if($FSW_INFO.OwnerNode) {$ClusterExistFlag=1;}
    if($FSW_INFO.State -like "*Failed*") {$TdStatusClass="WarningClass";$FSW_Status_flag=0;}
    if($FSW_INFO.State -like "*Online*") {$FSW_Status_flag=1;}
    
    switch ($FSW_INFO.RestartAction){
     0 {$FSW_restart_police="Do not restart the resource";$PrependFlag=1;$td_restart_class="WarningClass"; break}
     1 {$FSW_restart_police="Restart and do not attempt to failover if restart exceeds"; break}
     2 {$FSW_restart_police="Restart and attempt to fail over if restart exceeds";$PrependFlag=1;$td_restart_class="WarningClass"; break}
     default {"Something else happened..."; break}
     }

    $FSW_Path=Get-ClusterResource -cluster $_ -Name "File Share Witness" | Get-ClusterParameter SharePath | select Value
         
         $Check_FSW_File=CheckFSWpath -PathValue $FSW_Path

         if($current_date.ToShortDateString() -eq $Check_FSW_File.ToShortDateString())
                    {
                        $TD_FSW_path_class="";
                    }
                    else
                    {
                        $TD_FSW_path_class="WarningClass";
                        $PrependFlag=1;
                        #check cluster:
                           if(Test-Connection -Quiet $_".companyname.com")
                           {
                                <#
                                #if was here (OS version)
								$OS = Get-WmiObject -Computer $_ -Class Win32_OperatingSystem 
                                $OS.Caption
                                if($OS.Caption -like "*2003*")
                                {

                                    Get-ChildItem -File -path "\\DGWNAS.companyname.COM\D$\MNSClusters\$_\" -Recurse | Select-Object Name, LastWriteTime | Where-Object {($_.Name -like "*.txt*")} | ForEach-Object -Process {
                                    
                                    if($current_date.ToShortDateString() -eq $_.LastWriteTime.ToShortDateString())
                                    {
                                        $Check_FSW_File="";
                                        $add_comment+=$_.LastWriteTime
                                        $TD_FSW_path_class="";
                                        $add_comment+=" - All good."
                                    }
                                    else
                                    {
                                        $Check_FSW_File="";
                                        $add_comment+=$_.LastWriteTime
                                        $add_comment+=" - Most likely there are 2(!) or more folders with FSW - need to find and delete older folders. [need manual investigation, cause this is 2003 Server] ";
                                    }} #foreach and else closing:

                                    $add_comment+=" - Cluster exist. 2003 Server." # which doesn't allow get quorum resource remotely.

                                }
                                else
                                {
                                    ########
                                }
                                #>
                                #$add_comment+="Conflict #1";

                                #######:
                                if($FSW_Status_flag -eq 0)
                                    {
                                        $add_comment+=" - File Share Witness resource failed."
                                    }
                                    else
                                    {
                                        if($FSW_Status_flag -eq 1)
                                        {
                                            $add_comment+=" - Cluster exist, but most likely there are 2(!) or more folders with FSW - need to find and delete older folders. ";
                                        }
                                        else
                                        {
                                            $add_comment+=" - Cluster exist. Probably Quorum resource didn't configured.";
                                        }
                                    }

                            }
                            else
                            {
                                if($ClusterExistFlag -eq 0)
                                {
                                    $PrependFlag=0;
                                    $add_comment+=" - Probably Cluster doesn't exist or not reachable. [Check it and delete folder with FSW and\or Remove this host from DNS (be careful)]";
                                }
                                else
                                {
                                    $add_comment+="Conflict!";
                                }
                                #$add_comment+="Conflict #2";
                            }
                            
                        
                    }

        } #elseif OS ver


         if($PrependFlag -eq 0)
         {
             #primary:
             $FSW_info_To_HTML=$FSW_info_To_HTML+"<tr><td>" + <#$FSW_INFO.Cluster#> $_ + "</td><td>" + $FSW_INFO.OwnerNode + "</td><td class=$TdStatusClass>" + $FSW_INFO.State + "</td><td class=$TdStateClass>" + $FSW_INFO.SeparateMonitor + "</td><td class=$td_restart_class>" + $FSW_restart_police + "</td><td class=$TD_FSW_path_class>" + $Check_FSW_File + $add_comment + "</td></tr>"
         }
         else
         {
             #reverse: if need to push in begins of table:
             $FSW_info_To_HTML="<tr><td>" + <#$FSW_INFO.Cluster#> $_ + "</td><td>" + $FSW_INFO.OwnerNode + "</td><td class=$TdStatusClass>" + $FSW_INFO.State + "</td><td class=$TdStateClass>" + $FSW_INFO.SeparateMonitor + "</td><td class=$td_restart_class>" + $FSW_restart_police + "</td><td class=$TD_FSW_path_class>" + $Check_FSW_File + $add_comment + "</td></tr>"+$FSW_info_To_HTML
         }
		 
		
	
    Write-Host $_;
    }



    #add glue:
    $Html_result=$Html_before+$FSW_info_To_HTML+$Html_after

#write-host $Html_result
ConvertTo-Html -Body $Html_result | Send-GWMailMessage -Subject "File Share Witness Status Report (FSW)" -To "GWREP@companyname.com"
Write-host "E-mail sent"





