$location="C:\newLogFile.txt"
$logfile=[System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$instanceIP = $args[0]

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
    $text = "[$pid] "+$tstamp + ' ' + ' - ' + $Level + ' - ' + $logfile + ' - ' + $text
    $text | Out-File $location  -Append
}

Write-Logger "Initializing Logger"
Write-Host "Hello,This is powershell Bot for test purpose and this is your first paramter $instanceIP "
Write-Logger "Completed."
