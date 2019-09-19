add-type -AssemblyName System.Web

#instantiate variables. 
$random_password = [System.Web.Security.Membership]::GeneratePassword(8,0)
#output generated password
Write-Output $random_password

# read-host -prompt reads the user input and stores it in the assigned variable.
$user_name = (Read-Host -Prompt "enter the designated user: ")

# converts the generated password to a secure string
$new_password =  ConvertTo-SecureString -String $random_password  -AsPlainText -Force


#commandlet to reset the designated users password.
# url   https://docs.microsoft.com/en-us/powershell/module/addsadministration/set-adaccountpassword?view=win10-ps
Set-ADAccountPassword -Identity $user_name -NewPassword $new_password -Reset