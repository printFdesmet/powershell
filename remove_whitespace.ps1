# Import active directory module for running AD cmdlets
# Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Get-LocalUser

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
    $Lastname 	= $User.Surname
	$Firstname 	= $User.GivenName
    $Username 	= $User.SamAccountName
    
    $mod_lastname = $Lastname
    $mod_firstname = $Firstname
    $mod_username = $Username
	#This field refers to the OU the user account is to be created in

	#Check to see if the user already exists in AD

		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		# New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@agplastics.local" -Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" -Enabled $True -DisplayName "$Lastname, $Firstname" -OfficePhone "$Phone"
            
	
}
