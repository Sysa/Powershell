#$apiKey = "YourAsanaAPIkey"
#$resource = "https://app.asana.com/api/1.0/projects/53033518081799"

#$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("Authorization","Basic $apiKey")

#Invoke-RestMethod -Method Get -Uri $resource -Headers $headers




#variables:

    $date = Get-Date -format "d.M.yyyy"
    #$date=$date.ToShortDateString()
    $root_fld="C:\inetpub\wwwroot\Basana\";

#create folder:

    if ( -Not (Test-Path "$root_fld$date"))
        {
         new-item -path $root_fld -name $date -type directory
        }
    
#create authorization keys:

    $apikey="YourAsanaAPIkey"
    $authinfo=$apikey+":";
    $enc = [system.Text.Encoding]::UTF8
    $data1 = $enc.GetBytes($authinfo) 
    $mykey=[System.Convert]::ToBase64String($data1)

#send request to Asana:

    $url="https://app.asana.com/api/1.0/teams/46031119571717/projects?opt_fields=id,name,owner,color,followers,archived" #?completed_since=now
    $request = [System.Net.WebRequest]::Create($url)
    $authorization = "Authorization: Basic " + $myKey
    $request.Headers.Add($authorization)

#get response and write to .json-file:

    $Response = $Request.GetResponse()
    $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
    $StreamReader.ReadToEnd() | Out-File "$root_fld$date\projects.json"

#read created file:

    $json_projects = (Get-Content -Raw -Path $root_fld$date\projects.json) | ConvertFrom-Json


#create users.json:
<#
    $url="https://app.asana.com/api/1.0/workspaces/712734135166/users?opt_fields=email,name,id" #?completed_since=now
    $request = [System.Net.WebRequest]::Create($url)
    $authorization = "Authorization: Basic " + $myKey
    $request.Headers.Add($authorization)
    $Response = $Request.GetResponse()
    $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
    $StreamReader.ReadToEnd() | Out-File "$root_fld$date\users.json"
#>

#create or check if exist folder for projects:

    new-item -path $root_fld$date -name projects -type directory -Force


#grab IDs of projects:

    for ($index=0; $index -le ($json_projects.data.id).count ; $index++)
    {
        
       New-Item -Type Directory -Force -Path $root_fld$date\projects\ -name $json_projects.data.id[$index]

       #Write-Host $json_projects.data.id[$index]

       $project_id=$json_projects.data.id[$index]


     #grab info about each project:
         $url="https://app.asana.com/api/1.0/projects/$project_id"
        $request = [System.Net.WebRequest]::Create($url)
        $authorization = "Authorization: Basic " + $myKey
        $request.Headers.Add($authorization)

    #get response and write to .json-file:

        $Response = $Request.GetResponse()
        $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
        $StreamReader.ReadToEnd() | Out-File "$root_fld$date\projects\$project_id\project_info.json"
     
       
       
     #grab tasks list:

        $url="https://app.asana.com/api/1.0/projects/$project_id/tasks?opt_fields=id,name,completed,assignee" #?completed_since=now
        $request = [System.Net.WebRequest]::Create($url)
        $authorization = "Authorization: Basic " + $myKey
        $request.Headers.Add($authorization)

     

     #if return https errors:
     try {
       $Response = $Request.GetResponse()
     } catch [System.Net.WebException] {
       $Response = $_.Exception.Response
     }
      $res.StatusCode

    
    #get response and write to .json-file:

        #$Response = $Request.GetResponse()
        $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
        $StreamReader.ReadToEnd() | Out-File "$root_fld$date\projects\$project_id\tasks.json"

    #get task stories:
    #firstly get task-list:
        
        $json_tasks = (Get-Content -Raw -Path "$root_fld$date\projects\$project_id\tasks.json") | ConvertFrom-Json
        
        #create folder tasks for each project:
        new-item -path "$root_fld$date\projects\$project_id" -name tasks -type directory -Force

        #for each task:
        
           for ($task_index=0; $task_index -le ($json_tasks.data.id).count ; $task_index++)
            {
                #fail exception on empty project:
                if($json_tasks.data.id[$task_index] -ne $null)
                {
                    #create directory:
                    New-Item -Type Directory -Force -Path "$root_fld$date\projects\$project_id\tasks" -name $json_tasks.data.id[$task_index]

                    #grab task_id to variable:
                    $task_id=$json_tasks.data.id[$task_index]
                    #Write-Host $task_index

                 #get task info:


                    $url="https://app.asana.com/api/1.0/tasks/$task_id"
                    $request = [System.Net.WebRequest]::Create($url)
                    $authorization = "Authorization: Basic " + $myKey
                    $request.Headers.Add($authorization)

     
                    #if return https errors:
                    try {
                    $Response = $Request.GetResponse()
                    } catch [System.Net.WebException] {
                    $Response = $_.Exception.Response
                    }
                    $res.StatusCode

    
                    #get response and write to .json-file:
                    #$Response = $Request.GetResponse()
                    $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
                    $StreamReader.ReadToEnd() | Out-File "$root_fld$date\projects\$project_id\tasks\$task_id\task_info.json"


                 #and get task stories:
                                        
                    $url="https://app.asana.com/api/1.0/tasks/$task_id/stories?opt_expand=created_by,html_text,type" #?opt_fields=id,name,html_text,type&opt_expand=created_by
                    $request = [System.Net.WebRequest]::Create($url)
                    $authorization = "Authorization: Basic " + $myKey
                    $request.Headers.Add($authorization)

     

                    #if return https errors:
                    try {
                    $Response = $Request.GetResponse()
                    } catch [System.Net.WebException] {
                    $Response = $_.Exception.Response
                    }
                    $res.StatusCode

    
                #get response and write to .json-file:

                    #$Response = $Request.GetResponse()
                    $StreamReader = New-Object System.IO.StreamReader $Response.GetResponseStream()  
                    $StreamReader.ReadToEnd() | Out-File "$root_fld$date\projects\$project_id\tasks\$task_id\stories.json"

              }

           } #cycle end




    }




    #$json.data.created_by.name



# https://app.asana.com/api/1.0/teams/46031119571717/projects


#Get_data_from_Asana https://app.asana.com/api/1.0/projects/52360660688286/stories?opt_pretty

#46031119571717 #52360660688286

#to get asana converations needs to get all A tags with class='message-view-subject subject-link'

#workspace: personal or YourCompanyName.com (ID 712734135166) /GET /workspaces
#teams: UX or Farmers or Gateway Operations (ID 46031119571717)


#Get_data_from_Asana https://app.asana.com/api/1.0/organizations/712734135166/teams
#Get_data_from_Asana https://app.asana.com/api/1.0/organizations/712734135166/teams
#get project in GW workspace YourCompanyName.com: 712734135166

#Get_data_from_Asana https://app.asana.com/api/1.0/workspaces/712734135166/projects
#get_

#Get_data_from_Asana https://app.asana.com/api/1.0/organizations/712734135166/teams

#Get_data_from_Asana https://app.asana.com/api/1.0/teams/46031119571717/

#the same: get all project in GW or in YourCompanyName.com:
#Get_data_from_Asana https://app.asana.com/api/1.0/teams/46031119571717/projects
#Get_data_from_Asana https://app.asana.com/api/1.0/workspaces/712734135166/projects

#Get_data_from_Asana https://app.asana.com/api/1.0/teams/46031119571717

#get project's tasks: /projects/projectId-id/tasks
#completed_since=now - see only incompleted tasks:
#Get_data_from_Asana https://app.asana.com/api/1.0/projects/47460811985132/tasks?completed_since=now


#to better view add: ?opt_pretty&opt_expand=(this%7Csubtasks%2B)


# stories task ID 53948107669993 or for project 47273643661586 - weekend plans:
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/53948107669993/stories
#Get_data_from_Asana https://app.asana.com/api/1.0/projects/47273643661586/stories
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/stories


#get labels for task:
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/projects
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/projects

#-----------------

#task:
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118

#subtasks:
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/subtasks

#get labels for task: (projects)
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/projects

#get comments and activity:
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/stories?opt_pretty


#subtaskinfo 52389883561150 (need to obtain only uncompleted!!!!!!) :
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/52389883561150

#-----------------

#get all users of workspace: /workspaces/workspace-id/users or team !
#Get_data_from_Asana https://app.asana.com/api/1.0/teams/46031119571717/users


#tags: (only for workspace): or get all tags here -> https://app.asana.com/api/1.0/tags
#or GET tasks with tag: /tags/tag-id/tasks
#tag ID 47267242322853
#Get_data_from_Asana https://app.asana.com/api/1.0/tags/47267242322853/tasks
#Get_data_from_Asana https://app.asana.com/api/1.0/workspaces/712734135166/tags
#Get_data_from_Asana https://app.asana.com/api/1.0/tasks/51697460987118/tags


#query to find smtng in project:
#Get_data_from_Asana "https://app.asana.com/api/1.0/workspaces/712734135166/typeahead?type=project&query=a"




#| ConvertFrom-Json #| ConvertTo-Json



#Invoke-RestMethod -Uri https://app.asana.com/api/1.0/organizations/712734135166/teams | ConvertFrom-Json



<#
$apikey="YourAsanaAPIkey"
#Add colon
$authinfo=$apikey+":";

#Encoding format
$enc = [system.Text.Encoding]::UTF8

#get bytes
$data1 = $enc.GetBytes($string1) 

#convert to 64 bit
$mykey=[System.Convert]::ToBase64String($data1)

$url="https://app.asana.com/api/1.0/organizations/712734135166/teams"
$request = [System.Net.WebRequest]::Create($url)
$authorization = "Authorization: Basic " + $myKey

$request.Headers.Add($authorization)
#$request.Headers.Add("Authorization: BASIC $mykey")


$response = $request.GetResponse() | ConvertFrom-Json
Write-Host $Response  -ForeGroundColor Green 
#>