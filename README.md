# PowerShell System Information Script

This PowerShell script retrieves detailed information about your system, such as manufacturer, model, BIOS version, operating system, processor, memory, disk usage, IP address, system uptime, and CPU temperature. It also has the ability to retrieve information about running processes and log all the information to a file.

## Usage

```powershell
.\system-cpu-temp.ps1 [-Help] [-Proc] [-O output_path]
```

- `Help`: Display help information.
- `Proc`: Include information about currently running processes.
- `O`: Specify an output file to log the retrieved information.

## Examples
To simply get the system information:

```powershell
.\system-cpu-temp.ps1
```
To get the system information and current running processes:
```powershell
.\system-cpu-temp.ps1 -Proc

```
To get the system information and log it to a file:
```powershell
.\system-cpu-temp.ps1 -O system_info.log

```
## Output
```powershell
System Manufacturer : ASUS
System Model : System Product Name
BIOS Version : ALASKA - 1072009
Operating System : Microsoft Windows 11 Pro
Processor : 13th Gen Intel(R) Core(TM) i7-13700KF
Memory (GB) : 31.82
Disk Usage (C:) : 208.37 / 237.64
IP Address : SYSTEM_IP ADDRESS
System Uptime (Days) : 1.37
CPU Temperature (Celsius) : 27.85
CPU Temperature (Fahrenheit) : 82.13
```

If the -Proc switch is used, information about running processes is also displayed:
```powershell
Running Processes:
    Process1 - CPU: 12.34 - Memory: 567.89 MB
    Process2 - CPU: 0.12 - Memory: 345.67 MB
    ...
```

# Note
The script uses the Windows Management Instrumentation (WMI) to get the system information. Not all systems support all features. For example, some systems may not support retrieving the CPU temperature.
Also, the accuracy of the information retrieved (like CPU temperature) can depend on the system's hardware and drivers. Always cross-check the information with other system tools.
Please adjust the content as necessary to match your actual script and its features.


