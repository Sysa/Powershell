import-module "C:\Microsoft.Lync.Model.Dll"
import-module "C:\Microsoft.Office.Uc.dll"

$client = [Microsoft.Lync.Model.LyncClient]::GetClient()

#$contact = $client.ContactManager.GetContactByUri("alexh@companyName.com")
#$contact = $client.ContactManager.GetContactByUri("lyudmila@companyName.com")
#$contact = $client.ContactManager.GetContactByUri("sergeyl@companyName.com")
#$contact = $client.ContactManager.GetContactByUri("antons@companyName.com")


$ArrayOfClients=@("lyudmila@companyName.com","sergeyl@companyName.com","antons@companyName.com");
#$ArrayOfClients=@("lyudmila@companyName.com","sergeyl@companyName.com");
$ArrayOfOFFlineCodes=@(15500,18500);
$allOfflineFlag=1;
$htmlToEmail="<html><body>";
$MessageToTelegram="";

$recipients = @(59048780,80398373,204482824,183380331,311228323);
#63516418 - Helena
#59048780 - me?
#80398373 - Nik
#204482824 - stas
#-128263750 - ops Cube
#183380331 - ANdrew
#114559669 - garry #--- NOW OFF --- 114559669
#311228323 - shura


foreach ($cleint_from_array in $ArrayOfClients)
{
    $contact = $client.ContactManager.GetContactByUri($cleint_from_array)

    #check for online:
    if($ArrayOfOFFlineCodes -contains $contact.GetContactInformation("Availability") -eq "True")
    {
        #Write-Host "OFFLINE!!!"
        #User offline:
    }
    else
    {
        #ONLINE:
        #Write-Host "on online"
        #break;
        $allOfflineFlag=0;
    }



    $contact.GetContactInformation("DisplayName")
    $contact.GetContactInformation("Availability")
    [Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability")

    #$contact.GetContactInformation("IdleStartTime")
    #$contact.GetContactInformation("IsOutOfOffice")

    $htmlToEmail=$htmlToEmail + $contact.GetContactInformation("DisplayName") + " - " + [Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability") + "<br>"
    $MessageToTelegram = $MessageToTelegram + $contact.GetContactInformation("DisplayName") + " - " + [Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability") + " since " + $contact.GetContactInformation("IdleStartTime") + "`n`r" ;    
}


$htmlToEmail=$htmlToEmail + "</body></html>"

write-host $allOfflineFlag

if($allOfflineFlag -eq 1)
    {
        Write-Host "everybody is OFFFFFFline"


      
        #set flag=1

        $TriggerFilePath="C:\CHPONG-PONG\SendFlag.trigger"
        If (Test-Path $TriggerFilePath){
          Write-Host "Exists";
        }Else{
          Write-Host "None";
          #sending message: #
          $ccList=@("vlads@companyName.com","asidorov@companyName.com");
          send-mailmessage -to "alexh@companyName.com" -Cc $ccList -from "CHPONG@PONG" -subject "Let's play!" -SmtpServer mail.companyName.com -Body "They are Offline! <br> $htmlToEmail" -BodyAsHtml
          New-Item -name SendFlag.trigger -type "file" -Path "C:\CHPONG-PONG\"

          foreach ($one_recipient in $recipients)
            {

            $postParams = @{chat_id=$one_recipient;text=$MessageToTelegram}
            Invoke-WebRequest -Uri https://api.telegram.org/botID:BotKEY/sendMessage -Method POST -Body $postParams

            }

        }

    }
    else
    {
        Write-Host "everybody is online :/"

         $TriggerFilePath="C:\CHPONG-PONG\SendFlag.trigger"
        If (Test-Path $TriggerFilePath){
          Write-Host "Exists";
          remove-item -path "C:\CHPONG-PONG\SendFlag.trigger"

        }Else{
         # Write-Host "None";
         # New-Item -name SendFlag.trigger -type "file" -Path "C:\CHPONG-PONG\"
        }

    }


Write-Host $htmlToEmail

#$contact.GetContactInformation("Availability")
#$contact.GetContactInformation("DisplayName")


#[Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability")




#smile code: \ud83c\udfd3





#send-mailmessage -to "alexh@companyName.com" -from "CHPONG@PONG" -subject "Test mail PS" -SmtpServer mail.companyName.com -Body "ttttt"



<# 


[enum]::GetValues([Microsoft.Lync.Model.ContactAvailability]) | %{ "{0,3} {1}" -f $([int]$_),$_ }


  0 None
3500 Free
5000 FreeIdle
6500 Busy
7500 BusyIdle
9500 DoNotDisturb
12500 TemporarilyAway
15500 Away
18500 Offline
 -1 Invalid


#>


<# 
ContactInformationType:

 Availability,
  ActivityId,
   LocationName,
    TimeZone,
     TimeZoneBias, 
      MeetingSubject,
       MeetingLocation,

 Activity,
  CustomActivity,
   IdleStartTime,
!!!  DisplayName,
     Reserved1,
      PrimaryEmailAddress,
       EmailAddresses,
        Title,
         Company,

 Department, 
 Office,
  HomePageUrl,
   Photo,
    DefaultNote,
     DefaultNoteType,
      PersonalNote,
       OutOfficeNote, 
       SourceNetwork,
        Ico
nUrl, 
IconStream,
 ContactEndpoints,
  Reserved2,
   Reserved3,
    NextCalendarStateStartTime, 
    Reserved4,
     CapabilityString, 
     Cap
abilities,
 ContactType, 
 Description,
  Reserved5,
   FirstName,
    LastName,
     Reserved6,
      Reserved7, Reserved8, Reserved9, Reser
ved10,
 CapabilityDetails,
  DefaultNotePublishedTime,
   CurrentCalendarState,
    NextCalendarState,
     AttributionString, 
     InstantMessageAddresses, 
     IsOutOfOffice,
      Reserved11,
       Reserved12,
        Reserved13,
         Reserved14,
         Reserved15, 
         Invalid"

#>