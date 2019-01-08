#$apiKey = "YourKey"
#$resource = "https://app.asana.com/api/1.0/projects/53033518081799"

#$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("Authorization","Basic $apiKey")

#Invoke-RestMethod -Method Get -Uri $resource -Headers $headers

#create authorization keys:

    $apikey="YourKey"
    $authinfo=$apikey+":";
    $enc = [system.Text.Encoding]::UTF8
    #$enc = [system.Text.Encoding]::ASCII
    $data1 = $enc.GetBytes($authinfo) 
    $mykey=[System.Convert]::ToBase64String($data1)

#send request to Asana:

    $url="https://app.asana.com/api/1.0/tasks" #?workspace=62960631772681
    $request = [System.Net.WebRequest]::Create($url)
    $request.Method='POST';
    $authorization = "Authorization: Basic " + $myKey
    $request.Headers.Add($authorization)
    
    $request.ContentType="application/json";
    
    
    $data = (New-Object PSObject |
    Add-Member -PassThru NoteProperty notes 'testNotes' |
    Add-Member -PassThru NoteProperty name 'testTaskName' |
    Add-Member -PassThru NoteProperty workspace '62960631772681'
) | ConvertTo-JSON

$bytes = [System.Text.Encoding]::ASCII.GetBytes($data)

$request.ContentLength = $bytes.Length

$requestStream = [System.IO.Stream]$request.GetRequestStream()
$requestStream.write($bytes, 0, $bytes.Length)
$requestStream.Close()

$response = $request.GetResponse()


