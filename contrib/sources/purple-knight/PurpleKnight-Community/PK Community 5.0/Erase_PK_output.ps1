# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
 if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
  $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
  Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
  Exit
 }
}
Add-Type -AssemblyName PresentationFramework

$ButtonType = [System.Windows.MessageBoxButton]::YesNo

$MessageboxTitle = “Erase Purple Knight Outputs”
$Messageboxbody = @“
You are about to delete all outputs created by Purple Knight runs.
The following will be deleted:
- PurpleKnight\Output (folder and all its contents)
- PurpleKnight\custom (folder and all its contents)
- ProgramData\Semperis\Logs (all logs with "PurpleKnight" in their names)
This action cannot be undone. Do you want to continue?
”@

$MessageIcon = [System.Windows.MessageBoxImage]::Warning

$res = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$messageicon)

switch  ($res) {

  'Yes' {

    $workingDir = $MyInvocation.MyCommand.Path | Split-Path | Push-Location


    $directoriesToRemove = @(".\Output",".\custom")
    $filesToRemove = @()
    $logDirectory = [IO.Path]::Combine($env:ALLUSERSPROFILE, "Semperis\Logs\")

    #Remove Directories#

    foreach ($folder in $directoriesToRemove)
    {
        if (Test-Path $folder)
        {
            Remove-Item $folder -Recurse
        }
    }

    #Remove Files#

    foreach ($file in $filesToRemove)
    {
        if (Test-Path $file)
        {
            Remove-Item $file
        }
    }

    #Remove Logs#

    $logsToRemove = Get-ChildItem $logDirectory -Filter *PurpleKnight*

    foreach ($log in $logsToRemove)
    {
        if (Test-Path $log.FullName)
        {
            Remove-Item $log.FullName -Force
        }
    }

    $ok = [System.Windows.MessageBox]::Show("All Purple Knight's user data was removed",'Purple Knight User Data Removed','OK','Information')

  }

  'No' {

    Exit

  }
}