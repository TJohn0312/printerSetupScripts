$driverPath = ".\PrintDrivers\x64\Driver\CNLB0MA64.INF"
$driverName = "Canon Generic Plus UFR II"

$op1_printers = @(	
	[PSCustomObject]@{Name = 'Main Office Printer'; IP = '192.168.55.10'}
	[PSCustomObject]@{Name = 'Sales Printer'; IP = '192.168.55.11'}
	[PSCustomObject]@{Name = 'Upstairs Printer'; IP = '192.168.55.12'}
)
$op2_printers = @(	
	[PSCustomObject]@{Name = 'Large Office Printer'; IP = '192.168.125.10'}
	[PSCustomObject]@{Name = 'Small Office Printer'; IP = '192.168.125.11'}
)
$raleigh_printers = @(	
	[PSCustomObject]@{Name = 'Raleigh Printer'; IP = '192.168.145.20'}
)

function Check-RunAsAdministrator {
  #Get current user context
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  #Check user is running the script is member of Administrator Group
  if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
       Write-host "Script is running with Administrator privileges!"
  }
  else
    {
       #Create a new Elevated process to Start PowerShell
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
       # Specify the current script path and name as a parameter
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
       #Set the Process to elevated
       $ElevatedProcess.Verb = "runas"
 
       #Start the new elevated process
       [System.Diagnostics.Process]::Start($ElevatedProcess)
 
       #Exit from the current, unelevated, process
       Exit
 
    }
}

function install_driver {
	pnputil /add-driver $driverPath
	Add-PrinterDriver -Name $driverName
}

function install_printer {
	param (
		[object] $MyObject
	)

	foreach ($printer in $MyObject){
		Add-PrinterPort -Name $printer.IP -PrinterHostAddress $printer.IP
		Add-Printer -DriverName $driverName -Name $printer.Name -PortName $printer.IP
	}
}

function clearSpooler {
	net stop spooler
	Remove-Item -Path C:\Windows\System32\spool\PRINTERS\* -Force -Recurse

	# Remove-Item %systemroot%\System32\spool\printers\*
	net start spooler
}





Check-RunAsAdministrator

$prompt = @(
	" Press 1 to install OP1 Printers `n"
	"Press 2 to install OP2 Printers `n"
	"Press 3 to install Raleigh Printer `n"
	"Press 4 to install All `n"
	"Press 5 to clear Print Spooler `n"
)
$response = Read-Host $prompt


if ($response -eq 1) {
	install_driver
	install_printer $op1_printers
} elseif ($response -eq 2) {
	install_driver
	install_printer $op2_printers
} elseif ($response -eq 3) {
	install_driver
	install_printer $raleigh_printers
} elseif ($response -eq 4) {
	install_driver
	install_printer $op1_printers
	install_printer $op2_printers
	install_printer $raleigh_printers
} elseif ($response -eq 5) {
	clearSpooler
}



# Prompt to Set-ExecutionPolicy Restricted
$executionPrompt = Read-Host -Prompt "Set Execution Policy to Restricted? [Y/N]"

if ($executionPrompt -eq "Y" -or $executionPrompt -eq "y" -or $executionPrompt -eq "") {
	Set-ExecutionPolicy Restricted
	Write-Host "Execution Policy is back to Restricted"
} else {
	$currentPolicy = Get-ExecutionPolicy
	Write-Host "Execution Policy is still" $currentPolicy
}


Read-Host -Prompt "Press Enter to exit"