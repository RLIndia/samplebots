$location="C:\newLogFiles.txt"
$logfile=[System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$instanceIP = $args[0]
$taskId = $args[1]

function Write-Logger{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [string]
        $text,
        [Parameter(Mandatory=$False)]
        [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
        [String]
        $Level = "INFO"
    )

    $tstamp = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
    $text = $tstamp + ' - ' + "$pid" + ' - ' + $Level + ' - ' + $logfile + ' - ' + $text
    $text | Out-File $location  -Append -Encoding "utf8"
}

try{
	Write-Logger "Initializing Logger"
	$taskIdJson = @{"taskId" = $taskId} 
	$json = ($taskIdJson| ConvertTo-Json)
	Write-Logger $json
	if([string]::IsNullOrEmpty($instanceIP)){            
   		Write-Logger "Your parameter is NULL or EMPTY."
		$divisor = 0
    		[int]$a = 1/$divisor
	} else {            
   		Write-Logger "Your parameter is not EMPTY."           
	}
	Write-Host "Hello,This is powershell Bot for test purpose and this is the parameter $instanceIP"
	Write-Host "Task ID $taskId"
	Write-Logger "Completed."
}catch{
	$ErrorMessage = "You have not provided Instance IP"
	Write-Logger "Error occured in the powershell_test_bot : $ErrorMessage" "ERROR"
}

