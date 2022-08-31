# This script is intended to be run on an Active Directory Domain Controller and
# will add 101 users from the employees.txt file.

# The password needs to be converted to a secure string or we'll get an error message
# Each user will have the generic password:  Pass1234
# This can be changed at first logon, but for this lab, it is not necessary
# Created by Aldo Oliveri - 8/25/2022

$password = ConvertTo-SecureString "Pass1234" -AsPlainText -Force

# This is the directory where employees.txt is located on the Domain Controller 
$ADUsers = Get-Content C:\Users\Administrator\Documents\employees.txt


# Create a for loop to create a username of format: first name initial and last name.

foreach ($User in $ADUsers)
{
	$first_name = $User.Split(" ")[0].ToLower()
	$last_name = $User.Split(" ")[1].ToLower()
	$username = "$($first_name.Substring(0,1))$($last_name)".ToLower()

	
	# Check if the user account already exists in AD
       
	if (Get-ADUser -F {SamAccountName -eq $username})
	{
   		# If user does exist, output a warning message

    	Write-Warning "Cannot create user account $username since it already exists."
   	}
       
	else
	{
		# If a user does not exist then create a new user account
       	# This next line will change the background and font color when output user created:

    	Write-Host "Creating user: $($username)" -BackgroundColor Black -ForegroundColor Cyan
       
		# This cmdlet will create the new user with the properties shown

		New-AdUser -AccountPassword $password `
		-GivenName $first_name `
		-Surname $last_name `
		-DisplayName $username `
		-Name $username `
		-EmployeeID $username `
		-PasswordNeverExpires $true `
		-Path "OU=Users-Test,DC=abc,DC=com" `
		-Enabled $true
	}
}
