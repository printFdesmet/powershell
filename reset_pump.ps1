Get-Process 'hl.exe' | Stop-Process 

Get-Service -Name 'GirHLSrv' | ForEach-Object {$_.Stop()}
Get-Service -Name 'GirHLSrv' | ForEach-Object {$_.Status}
Get-Service -Name 'GirHLSrv' | ForEach-Object {$_.Start()}
