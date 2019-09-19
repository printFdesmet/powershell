# TODO: remove all rdp files from the desktop
# TODO: use the %appdata%\Microsoft\Windows\Start Menu\Programs\Startup variable to remove the rdp file on start-up

$desktop_path = [System.Environment]::GetFolderPath('Desktop')

# Set-Location -Path \\agplastics.local\FileServer\Users\$env:USERNAME
Set-Location -Path $desktop_path
Copy-Item \\srv-file-vs-01\rdp\Skylux_RemoteAudioSupport.rdp -Destination $desktop_path

Remove-Item *.rdp -Exclude 'Skylux_RemoteAudioSupport.rdp'