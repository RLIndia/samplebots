#A service now library:
#Features included, Read Incident, Update Incident, Get Attachment List for Incident, Get Attachment and Save
#Version: 1.0
#Developer: Vinod




#Send password in secure string format
#ConvertTo-SecureString -AsPlainText -Force "1234"

class ServiceNowApi {
    [Object] $serviceNowCredentails
    [string] $serviceNowUsername
    [string] $serviceNowInstance
    [string] $errorValue
    ServiceNowApi([string]$username,[securestring]$pass,[string]$instance){       
        $this.serviceNowUsername = $username            
        $this.serviceNowCredentails = New-Object System.Management.Automation.PSCredential -ArgumentList $username,$pass
        $this.serviceNowInstance = "https://$instance.service-now.com/api/now/"
    }

    [string]GetServiceNowGroupId([string]$groupName) {
        try{
            $url = $this.serviceNowInstance+"table/sys_user_group?sysparm_query=name%3D"+$groupName+"&sysparm_limit=1"
            
            #Write-logger $url
            $response = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method Get -ContentType "application/json" 
            $result = $response.result[0]
            return $result.sys_id            
        }
        catch{
            $ErrorMessage = $_.Exception.Message
            # Write-Logger "Error Update Ticket"
            # Write-Logger $ErrorMessage | Format-Table | Out-String
            $this.errorValue += $ErrorMessage
            return $null
        }
    }

    [string] GetServiceNowRequestAttachment([string]$sys_id,[string]$attachmentName,[string]$destinationPath) {
            $returnval = $null   
            try{
                $url = $this.serviceNowInstance+"table/sys_attachment?table_sys_id=$sys_id"
                $attachments = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method Get -ContentType "application/json"
                if($attachments -ne $null){
                    $attachments = $attachments.result
                    $lastAttachment = $null
                    $attachments | % {
                        if($_.file_name -like "$attachmentName"){
                            $_.sys_updated_on = [DateTime]$_.sys_updated_on
                            if($lastAttachment){
                                if ($_.sys_updated_on -gt $lastAttachment.sys_updated_on){
                                    $lastAttachment = $_
                                }
                            }
                            else{
                                $lastAttachment = $_
                            }                        
                        }
                    }
                    if($lastAttachment){
                        $savepath1 = ([string]$destinationPath+"-"+[string]($lastAttachment."file_name"))
                        $returnval = $this.ReadServiceNowAttachment($lastAttachment.sys_id,$savepath1)
                    }
                   
                }
                else{
                    $this.errorValue += "No Attachments found."
                    $returnval = $null
                }
               return $returnval 
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $this.errorValue += $ErrorMessage
                # Write-Logger "Error Update Ticket"
                # Write-Logger $ErrorMessage | Format-Table | Out-String
                return $null
            }
            #return $returnAttachment
    }

    [string] ReadServiceNowAttachment([string]$sys_id,[string]$dpath)  {
            try{
                $url = $this.serviceNowInstance+"attachment/$sys_id/file"            
               # $data = invoke-webrequest -Uri $url -Credential $global:serviceNowCredentails -Method Get -ContentType ""
               
               $client = new-object System.Net.WebClient
               $client.Credentials = $this.serviceNowCredentails
               $client.DownloadFile($url,$dpath)
                return $dpath                
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                $this.errorValue+= $ErrorMessage

                # Write-Logger "Error Update Ticket"
                # Write-Logger $ErrorMessage | Format-Table | Out-String
                return $null
            }
            
    }

    [string] UploadServiceNowAttachment([string]$table_name,[string]$sys_id,[string]$dpath,[string]$filename)  {
        try{
            $url = $this.serviceNowInstance+"attachment/file?table_name=$table_name&table_sys_id=$sys_id&file_name=$filename"            
           # $data = invoke-webrequest -Uri $url -Credential $global:serviceNowCredentails -Method Get -ContentType ""
           
           $upload = Invoke-RestMethod -uri $url -Method Post -InFile $dpath  -Credential $this.serviceNowCredentails -ContentType "multipart/form-data"
        #    $client = new-object System.Net.WebClient
        #    $client.
        #    $client.Credentials = $this.serviceNowCredentails
        #    $client.UploadFile($url,$dpath)
            return $dpath                
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            $this.errorValue+= $ErrorMessage

            # Write-Logger "Error Update Ticket"
            # Write-Logger $ErrorMessage | Format-Table | Out-String
            return $null
        }
        
}

    [string]GetServiceNowCatItem([string]$name) {
        try{                
            $url = "$($this.serviceNowInstance)table/sc_cat_item?sysparm_query="+$name+"&sysparm_limit=1"
            $catitem = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method Get -ContentType "application/json"
            if($catitem){
                $tmp = [pscustomobject]$catitem.result[0]
                return($tmp.sys_id)
            }
            else{
                return ($null)
            }                
        }
        catch{
            $ErrorMessage = $_.Exception.Message
            $this.errorValue += $ErrorMessage
            # Write-Logger "Error Update Ticket"
            # Write-Logger $ErrorMessage | Format-Table | Out-String
            return $null
        }        
    }

    [string]UpdateServiceNowTask([string]$task_sys_id,[string]$state,[string]$workNotes,[string]$assignedTo,[string]$assignmentGroupID,[string]$comments_info){
             try{
                $body = @{
                    "work_notes"=$workNotes;
                }
                if($state -ne $null){
                    $body.add("state",$state)
                }
                if($assignedTo -ne $null ){
                    $body.add("assigned_to",$assignedTo)
                }
    
                if($assignedTo -eq "None"){
                    $body.Remove("assigned_to")
                    $body.add("assigned_to","")
                }
    
                if($assignmentGroupID -ne $null){
                    $body.add("assignment_group",$assignmentGroupID)
                }
    
                if($comments_info -ne $null){
                    $body.add("comments",$comments_info)
                }
    
                $url = "$($this.serviceNowInstance)table/sc_task/$task_sys_id"
                $task = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method PUT -Body ($body|ConvertTo-Json) -ContentType "application/json"
                return $task
            }
            catch{
                $ErrorMessage = $_.Exception.Message
                $this.errorValue += $ErrorMessage
                # Write-Logger "Error Update Ticket"
                # Write-Logger $ErrorMessage | Format-Table | Out-String
                return $null
            }
    }

    [string]PrefixServiceNowTaskSD([string]$task_sys_id,[string]$shortDescription){ 
        try{
                     

           $url = "$($this.serviceNowInstance)table/sc_task/$task_sys_id"
           $task = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method GET -ContentType "application/json"
           if($task){
            $result = $task.result[0]
            $body = @{
                "short_description"=$shortDescription + $result.short_description;
               }
            $task = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method PUT -Body ($body|ConvertTo-Json) -ContentType "application/json"
           }
           
           return $task
       }
       catch{
           $ErrorMessage = $_.Exception.Message
           $this.errorValue += $ErrorMessage
           # Write-Logger "Error Update Ticket"
           # Write-Logger $ErrorMessage | Format-Table | Out-String
           return $null
       }
    }
    [object]CreateServiceNowRitmTask([string]$ritm_sys_id,[string]$assignment_group,[string]$shortDescription,[string]$description,[string]$assignedTo,[string]$workNotes,[string]$catitem,[string]$state){
            try{
                $body = @{
                    "parent"=$ritm_sys_id;
                    "assignment_group"=$assignment_group;
                    "request_item"=$ritm_sys_id;
                    "request"=$ritm_sys_id;
                    "short_description"=$shortDescription;
                    "description"=$description;
                    "assigned_to"=$assignedTo;
                    "u_cat_item"=$catitem;
                    "state"=$state;
                }
                if(!$assignedTo){
                    $body.Remove("assigned_to")
                }
                $url = $this.serviceNowInstance+"table/sc_task"
                
                Write-logger $url
                $task = Invoke-RestMethod -uri $url -Credential  $this.serviceNowCredentails -Method POST -Body ($body|ConvertTo-Json) -ContentType "application/json"
                if($task){
                    $rettask = $task.result
                    return($rettask)
                }else{
                    return $null
                }
            }
            catch{
                $ErrorMessage = $_.Exception.Message
                $this.errorValue += $ErrorMessage
                # Write-Logger "Error Update Ticket"
                # Write-Logger $ErrorMessage | Format-Table | Out-String
                return $null
            }
    }
}

function Get-ServiceNowIncidents {
    param(
       
        [Parameter(Mandatory=$true)] [string]$tableName,
        [Parameter(Mandatory=$false)] [string]$sys_id,
        [Parameter(Mandatory=$false)] [string]$nvquery

        )
        try{
            if($sys_id -ne ""){
                $url = $global:servicenowapi+"table/"+$tableName+"/"+$sys_id+"?sysparm_limit=1"
            }
            else{
                $url = $global:servicenowapi+"table/"+$tableName+"?sysparm_query="+$nvquery+"&sysparm_limit=10"
            }
            Write-logger $url
            $incidents = Invoke-RestMethod -uri $url -Credential  $global:serviceNowCredentails -Method Get -ContentType "application/json" 
            return $null,$incidents
        }
        catch{
            $ErrorMessage = $_.Exception.Message
            # Write-Logger "Error Update Ticket"
            # Write-Logger $ErrorMessage | Format-Table | Out-String
            return "Error:$ErrorMessage",$null
        }
    
}


function Create-ServiceNowIncidentTask {
    param(
        [Parameter(Mandatory=$true)] [string]$incident_sys_id,
        [Parameter(Mandatory=$false)] [string]$shortDescription,
        [Parameter(Mandatory=$false)] [string]$description,
        [Parameter(Mandatory=$false)] [string]$assignedTo,
        [Parameter(Mandatory=$false)] [string]$workNotes
        )
        try{
            $body = @{
                "parent"=$incident_sys_id;
                "short_description"=$shortDescription;
                "description"=$description;
                "assigned_to"=$assignedTo;
                "work_notes"=$workNotes;
            }
            $url = $global:servicenowapi+"table/incident_task"
            
            Write-logger $url
            $incidents = Invoke-RestMethod -uri $url -Credential  $global:serviceNowCredentails -Method POST -Body ($body|ConvertTo-Json) -ContentType "application/json"
            return $null,$incidents
        }
        catch{
            $ErrorMessage = $_.Exception.Message
            # Write-Logger "Error Update Ticket"
            # Write-Logger $ErrorMessage | Format-Table | Out-String
            return "Error:$ErrorMessage",$null
        }
}





#https://scholasticdev.service-now.com/api/now/table/sc_cat_item?sysparm_query=sys_name=Non-Employee Network / Email Request


