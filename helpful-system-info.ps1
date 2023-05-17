param(
    [switch]$Help,
    [switch]$Proc,
    [string]$O
)

# Check if the help switch was provided
if ($Help) {
    # Display help information
    Write-Host "Usage: .\system-cpu-temp.ps1 [-Help] [-Proc] [-O output_path]"
    Write-Host "Returns detailed system information. By default, it includes CPU temperature, memory usage, disk usage, network status, and system uptime."
    Write-Host "Options:"
    Write-Host "  -Help   Display this help message."
    Write-Host "  -Proc   Include information about currently running processes."
    Write-Host "  -O      Specify an output file to log the retrieved information."
    return
}

# Retrieve basic system information
$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
$os = Get-WmiObject -Class Win32_OperatingSystem
$bios = Get-WmiObject -Class Win32_BIOS
$processor = Get-WmiObject -Class Win32_Processor
$memory = Get-WmiObject -Class Win32_ComputerSystem
$disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
$network = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }

# Generate system information report
$report = @()
$report += New-Object PSObject -Property @{
    Name = "System Manufacturer"
    Value = $computerSystem.Manufacturer
}
$report += New-Object PSObject -Property @{
    Name = "System Model"
    Value = $computerSystem.Model
}
$report += New-Object PSObject -Property @{
    Name = "BIOS Version"
    Value = $bios.Version
}
$report += New-Object PSObject -Property @{
    Name = "Operating System"
    Value = $os.Caption
}
$report += New-Object PSObject -Property @{
    Name = "Processor"
    Value = $processor.Name
}
$report += New-Object PSObject -Property @{
    Name = "Memory (GB)"
    Value = "{0:N2}" -f ($memory.TotalPhysicalMemory /1GB)
}
$report += New-Object PSObject -Property @{
    Name = "Disk Usage (C:)"
    Value = "{0:N2}" -f (($disk.Size - $disk.FreeSpace) / 1GB) + " / " + "{0:N2}" -f ($disk.Size /1GB)
}
$report += New-Object PSObject -Property @{
    Name = "IP Address"
    Value = $network.IPAddress[0]
}
$report += New-Object PSObject -Property @{
    Name = "System Uptime (Days)"
    Value = "{0:N2}" -f (($os.ConvertToDateTime($os.LocalDateTime) - $os.ConvertToDateTime($os.LastBootUpTime)).TotalDays)
}

# Try to get the CPU temperature
try {
    # Use WMI to get the temperature in tenths of degrees Kelvin
    $cpuTempKelvin = (Get-WmiObject -Namespace "root\WMI" -Query "SELECT * FROM MSAcpi_ThermalZoneTemperature").CurrentTemperature

    # If the temperature was successfully retrieved
    if ($cpuTempKelvin -ne $null) {
        # Convert the temperature to Celsius (K - 273.15)
        $cpuTempCelsius = ($cpuTempKelvin / 10) - 273.15

        # Convert the temperature to Fahrenheit (C * 9/5 + 32)
        $cpuTempFahrenheit = ($cpuTempCelsius * 9/5) + 32

        # Add the temperature in both Celsius and Fahrenheit to the report
        $report += New-Object PSObject -Property @{
            Name = "CPU Temperature (Celsius)"
            Value = "{0:N2}" -f $cpuTempCelsius
        }
        $report += New-Object PSObject -Property @{
            Name = "CPU Temperature (Fahrenheit)"
            Value = "{0:N2}" -f $cpuTempFahrenheit
        }
    } else {
        $report += New-Object PSObject -Property @{
            Name = "CPU Temperature"
            Value = "Could not get CPU temperature. Not all systems support this feature."
        }
    }
}
catch {
    $report += New-Object PSObject -Property @{
        Name = "CPU Temperature"
        Value = "Could not get CPU temperature. This system may not support this feature or you may not have the necessary permissions."
    }
}

# If the Proc switch was provided, get running process information
if ($Proc) {
    $processes = Get-Process | Sort-Object CPU -Descending
    foreach ($process in $processes) {
        $report += New-Object PSObject -Property @{
            Name = "Process: " + $process.Name
            Value = "CPU: " + "{0:N2}" -f ($process.CPU) + " - Memory: " + "{0:N2}" -f ($process.WorkingSet64 / 1MB) + " MB"
        }
    }
}

# Display the report
foreach ($item in $report) {
    Write-Host $item.Name -NoNewline -ForegroundColor Cyan
    Write-Host " : " -NoNewline
    Write-Host $item.Value -ForegroundColor White
}

# If an output file was specified, log the report
if ($O) {
    # Convert the colored report to plain text for the log file
    $log = $report | ForEach-Object { "$($_.Name): $($_.Value)" }
    $log | Out-File -FilePath $O -Append
}

