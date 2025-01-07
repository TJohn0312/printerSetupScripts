$driverPath = ".\PrintDrivers\x64\Driver\CNLB0MA64.INF"

# Set-ExecutionPolicy RemoteSigned -Force

function Check-RunAsAdministrator() {
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
	Add-PrinterDriver -Name "Canon Generic Plus UFR II"
}

function install_op1 {
	# Main
	Add-PrinterPort -Name "192.168.55.10" -PrinterHostAddress 192.168.55.10
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "Main Office Printer" -PortName "192.168.55.10"

	# Sales
	Add-PrinterPort -Name "192.168.55.11" -PrinterHostAddress 192.168.55.11
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "Sales Printer" -PortName "192.168.55.11"

	# Upstairs
	Add-PrinterPort -Name "192.168.55.12" -PrinterHostAddress 192.168.55.12
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "Upstairs Printer" -PortName "192.168.55.12"
}
	
function install_op2 {
	# OP2 Large Office Printer
	Add-PrinterPort -Name "192.168.125.10" -PrinterHostAddress 192.168.125.10
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "OP2 Large Office Printer" -PortName "192.168.125.10"

	# Small Office Printer
	Add-PrinterPort -Name "192.168.125.11" -PrinterHostAddress 192.168.125.11
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "OP2 Small Office Printer" -PortName "192.168.125.11"
}

function install_raleigh {
	Add-PrinterPort -Name "192.168.145.20" -PrinterHostAddress 192.168.145.20
	Add-Printer -DriverName "Canon Generic Plus UFR II" -Name "Raleigh Printer" -PortName "192.168.145.20"
}

function clearSpooler {
	net stop spooler
	Remove-Item %systemroot%\System32\spool\printers\*
	net start spooler
}





Check-RunAsAdministrator

$prompt = @(
	" Press 1 to install OP1 Printers `n"
	"Press 2 to install OP2 Printers `n"
	"Press 3 to install Raleigh Printer `n"
	"Press 4 to install All `n"
	"Press 5 to clear Print Spooler `n"
) -join ' '

$response = Read-Host $prompt

Write-Host $response


if ($response -eq 1) {
	install_driver
	install_op1
} elseif ($response -eq 2) {
	install_driver
	install_op2
} elseif ($response -eq 3) {
	install_driver
	install_raleigh
} elseif ($response -eq 4) {
	install_driver
	install_op1
	install_op2
	install_raleigh
} elseif ($response -eq 5) {
	clearSpooler
}




$executionPrompt = Read-Host -Prompt "Set Execution Policy to Restricted? [Y/N]"

if ($executionPrompt -eq "Y" -or $executionPrompt -eq "y") {
	Set-ExecutionPolicy Restricted
	Write-Host "Execution Policy is back to Restricted"
} else {
	$currentPolicy = Get-ExecutionPolicy
	Write-Host "Execution Policy is still" $currentPolicy
}


Read-Host -Prompt "Press Enter to exit"