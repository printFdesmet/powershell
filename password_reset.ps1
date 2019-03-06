$user_name = (Read-Host -Prompt "enter the designated user: ")
$new_password = (Read-Host -Prompt "enter new password: " -AsSecureString)

Set-ADAccountPassword -Identity $user_name -NewPassword $new_password -Reset