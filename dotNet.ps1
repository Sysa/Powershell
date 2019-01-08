$ExecutionCommand= {

Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSComputerName, PSChildName, Version, Release -ExcludeProperty RunspaceId

#write-host $RegVal

}

$collectionVariable = @()

Get-ADComputers -Filter * | %{ $Result=Invoke-Command -ComputerName $_ -ScriptBlock $ExecutionCommand ;
    #$Result | Export-CSV -Path 'C:\Users\prodalexh\Desktop\dotNetVersions.csv' -Append -UseCulture
    
    #$Result | Export-XLSX -Path 'C:\Users\prodalexh\Desktop\dotNetVersions.xlsx' -Append
    $collectionVariable += $Result

    #Write-Host ($Result | Format-Table | Out-String | )
    #$Result | Add-Content 'C:\Users\prodalexh\Desktop\dotNetVersions.cvs'
    }
    
    #Write-Host $collectionVariable
    $collectionVariable | Export-XLSX -Path 'C:\Users\prodalexh\Desktop\dotNetVersions.xlsx' -Append