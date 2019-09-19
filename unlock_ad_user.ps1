# creates a password usable for automated logins.
$password = ConvertTo-SecureString "sab2gpl3s" -AsPlainText -Force
# creates a login with the specified user and its password.
$cred = New-Object System.Management.Automation.PSCredential ("agplastics\administrator", $password)

# more secure way of obtaining your password so that it is not visible as pain text in your script.
# $password = Get-Content C:\Users\fdesmet\Documents\powershell\script_data.txt | ConvertTo-SecureString

# creates a session (like SSH) to the specified server.
$session = New-PSSession -ComputerName 'SRV-DC-VS-01' -Credential $cred
Import-PSSession -Session $session -Module ActiveDirectory
## Add required assembly.
Add-Type -AssemblyName PresentationFramework

# Create a Window.
$Window = New-Object Windows.Window
$Window.Height = "670"
$Window.Width = "700"
$Window.Title = "Unlocker Pro 3000"
$window.WindowStartupLocation = "CenterScreen"

# Create a grid container with 2 rows, one for the buttons, one for the datagrid.
$Grid = New-Object Windows.Controls.Grid
$Row1 = New-Object Windows.Controls.RowDefinition
$Row2 = New-Object Windows.Controls.RowDefinition
$Row1.Height = "70"
$Row2.Height = "100*"
$grid.RowDefinitions.Add($Row1)
$grid.RowDefinitions.Add($Row2)

# Create a button with the functionality to get all the locked users.
$Button_Processes = New-Object Windows.Controls.Button
$Button_Processes.SetValue([Windows.Controls.Grid]::RowProperty, 0)
$Button_Processes.Height = "50"
$Button_Processes.Width = "150"
$Button_Processes.Margin = "10,10,10,10"
$Button_Processes.HorizontalAlignment = "Left"
$Button_Processes.VerticalAlignment = "Top"
$Button_Processes.Content = "get locked users"
$Button_Processes.Background = "Aquamarine"


# creates a button with the functionality to unlock ONE specific user.
$Button_Services = New-Object Windows.Controls.Button
$Button_Services.SetValue([Windows.Controls.Grid]::RowProperty, 0)
$Button_Services.Height = "50"
$Button_Services.Width = "150"
$Button_Services.Margin = "180,10,10,10"
$Button_Services.HorizontalAlignment = "Left"
$Button_Services.VerticalAlignment = "Top"
$Button_Services.Content = "unlock users"
$Button_Services.Background = "Aquamarine"

# Create a button with the functionality to unlock all users.
$Button_unlock_all = New-Object Windows.Controls.Button
$Button_unlock_all.SetValue([Windows.Controls.Grid]::RowProperty, 0)
$Button_unlock_all.Height = "50"
$Button_unlock_all.Width = "150"
$Button_unlock_all.Margin = "350,10,10,10"
$Button_unlock_all.HorizontalAlignment = "Left"
$Button_unlock_all.VerticalAlignment = "Top"
$Button_unlock_all.Content = "unlock all"
$Button_unlock_all.Background = "Aquamarine"

# Create a datagrid.
$DataGrid = New-Object Windows.Controls.DataGrid
$DataGrid.SetValue([Windows.Controls.Grid]::RowProperty, 1)
$DataGrid.MinHeight = "100"
$DataGrid.MinWidth = "100"
$DataGrid.Margin = "10,0,10,10"
$DataGrid.HorizontalAlignment = "Stretch"
$DataGrid.VerticalAlignment = "Stretch"
$DataGrid.VerticalScrollBarVisibility = "Auto"
$DataGrid.GridLinesVisibility = "none"
$DataGrid.IsReadOnly = $true

# Add the elements to the relevant parent control.
$Grid.AddChild($DataGrid)
$grid.AddChild($Button_Processes)
$grid.AddChild($Button_Services)
$grid.AddChild($Button_unlock_all)
$window.Content = $Grid

# Adds an event on the Get locked users button.
$Button_Processes.Add_Click({
    # gets all the AD users specificaly the ones who are locked out.
    $Processes = Get-ADUser -Filter * -Properties * | Select-Object SamAccountName, LockedOut | Where-Object { $_.LockedOut -eq $True }
    $DataGrid.ItemsSource = @($Processes)
})

# Adds an event on the unlock users button.
$Button_Services.Add_Click({
# creates a pop up window witch allows users to enter a specific SAM name.
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $title = 'user'
    $msg = 'Enter the user you want to unlock:'
    $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
# unlocks the specified user.
    $Services = Unlock-ADAccount -Identity $text
    $DataGrid.ItemsSource = $Services

})

$Button_unlock_all.Add_Click({
# imports the installed module from a remote server, this prevents installations of not required modules.
    Import-PSSession -Session $session -Module ActiveDirectory -AllowClobber
    $locked_users = Get-ADUser -Filter * -Properties * | Select-Object SamAccountName, LockedOut | Where-Object { $_.LockedOut -eq $True }

# loops over the locked users and unlocks them.
    foreach ($user in $locked_users)
    {
        Unlock-AdAccount -identity $user.SamAccountName
    }

    $DataGrid.ItemsSource = @($locked_users)
})

# Shows the window.
if (!$psISE)
{
    # Hides PS console window.
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

    # Run as an application.
    $app = [Windows.Application]::new()
    $app.Run($Window)
}
Else
{
    [void]$window.ShowDialog()
}

# exits the earlier created session, this for security as well as unnescecary load.
Exit-PSSession
# invokes a command over the network, without the use of a session, this is good for small code blocks.
# replicates the changes from DC1 to DC2.
Invoke-Command -ComputerName 'SRV-DC-VS-01' -Credential $cred -ScriptBlock {
    repadmin /syncall SRV-DC-VS-01 /APeD
}
# same as above
# syncs the azure DC with OFFICE 365.
Invoke-Command -ComputerName 'SADCVS05' -Credential $cred -ScriptBlock {
    repadmin /syncall SADCVS05
    Start-sleep -s 30
    Start-ADSyncSyncCycle -PolicyType Delta
}


