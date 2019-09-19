# creates a variable that stores a string that is password enabled
$password = ConvertTo-SecureString "sab2gpl3s" -AsPlainText -Force
# creates a login object making it possible to login remotly behind the scenes.
$cred = New-Object System.Management.Automation.PSCredential ("agplastics\administrator", $password )

# this enables remoting on the client where the script is executed.
Enable-PSRemoting
# this sets the computer as a trusted host in the list, this enables communication over the network with Kerberos.
Set-item wsman:localhost\client\trustedhosts -value * -Force
# this invokes a command on multiple remote locations, using the previously created credentials.
invoke-command -ComputerName 'SRV-SQLPRD-VS01', 'SRV-AOSPRD-VS01', 'SRV-AOSPRD-VS02', 'SRV-APP-VS-01', 'SRV-APP-VS-02', 'SRV-CAD-VS-02', 'SRV-SCRIB-VS-01', 'SGPSVS01' -Credential $cred -scriptblock {
    # Commands to be executed on remote machine
    # gets the running services piped in a condition where it checks if the status is stopped, then it starts the respective services. If something gives an error it continues without interrupting (silently continue).
    Get-Service `
    'SQL Server Browser', 'SQL Server Agent (AX_PRD)', 'SQL Server (AX_PRD)', 'SQL Server Integration Services 11.0', 'MSSQLFDLauncher$AX_PRD', # SRV-SQLPRD-VS01
    'Dynamics AX Object Server 5.0$01-AX2K9_AGP_LIVE', # SRV-AOSPRD-VS01, SRV-AOSPRD-VS02
    'NablePatchRepositoryService', 'EPIntegrationService', 'EPProtectedService', 'epredline', #SRV-APP-VS-01
    'SQL Server (FLAGSTONE)', 'SQL Server (IDE)', 'SQL Server (SCRIBE)', 'SQL Server Agent (FLAGSTONE)', 'SQL Server Agent (IDE)',
    'SQL Server Agent (SCRIBE)', 'SQL Server CEIP service (FLAGSTONE)', 'SQL Server CEIP service (IDE)', 'SQL Server CEIP service (SCRIBE)', 'SQL Server Launchpad (IDE)',
    'EPSecurityService', 'EPUpdateService', 'PTC Windchill Directory Server', 'PTC_SolrServer',
    'Thingworx-IntegrationRuntime', 'Thingworx-Foundation', 'GirHLSrv', # SRV-APP-VS-02
    'PTC WFS Controller', # SRV-APP-CAD-02
    'Scribe MonitorServer', 'Scribe MessageServer', 'Scribe EventManager', 'Scribe BridgeServer', 'Scribe AdminServer', # SRV-SCRIB-VS-01
    'GPS-Mailing', 'GPS Communication Service' -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Stopped' } | Start-Service -ErrorAction SilentlyContinue # SGPSVS01
}

