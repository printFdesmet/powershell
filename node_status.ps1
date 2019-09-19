# todo: get the following data from the node: hostname, cpu(%), ram(%), diskspace(%).
# todo: cpu cores have to be the total average of the cores joined.
# todo: for each disk get the free space
# todo: upload the gathered data to the database, for each record
try
{
Set-ExecutionPolicy RemoteSigned
}
catch
{

}


if (Get-Module -ListAvailable -Name 'sqlserver') {
    Import-Module -Name 'sqlserver'
}
else {
    Install-Module -Name 'sqlserver'
}

# function that pushes the query to the correct database.
function push_query
{
    param($servername, $stat, $value)
    $insertquery = "insert into ServerStats ([ServerName],[Stat],[Value],[Time]) values ('$servername', '$stat', '$value', GETDATE())"
    Invoke-SQLcmd -ServerInstance '192.168.64.12\Production' -query $insertquery -U sa -P !Skylux -Database Dashboard
}

$os = Get-Ciminstance Win32_OperatingSystem # get all the general information of the operation system.
$username = $env:COMPUTERNAME # gets the hostname of the local machine.
[INT]$CPU = Get-WmiObject win32_processor -ComputerName $env:COMPUTERNAME | Measure-Object -Property LoadPercentage -Average | ForEach-Object { $_.Average } # percentage of CPU load.
$RAM = [INT]([math]::Round(($os.FreePhysicalMemory/$os.TotalVisibleMemorySize)*100, 2)) # percentage of free random access memory.
$disks = Get-WmiObject -ComputerName . -Class Win32_LogicalDisk -Filter "DriveType = 3"

# for each disk extract the correct data and push it to the database.
foreach ($disk in $disks)
{

    [INT64]$size = $disk.Size;
    [INT64]$freespace = $disk.FreeSpace;
    $disk_ID = $disk.DeviceID;

    [INT]$percentFree = 100 - [MATH]::Round(($freespace / $size)*100, 2);
   # Write-Host $disk_ID[0]
   # Write-Host $percentFree

    push_query -servername $username -stat $disk_ID[0] -value $percentFree

}

# Write-Host $RAM
push_query -servername $username -stat 'MEM' -value $RAM

# Write-Host $CPU
push_query -servername $username -stat 'CPU' -value $CPU


exit