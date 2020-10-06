# Powershell Scripts

This repository is a collection of powershell scripts that can be used for administering Windows systems. Dependencies can be installed by running the Setup.ps1 script, afterwards you can execute the scripts in the top level directory, or write your own scripts utilizing the various modules included.

# Scripts

**Change-Username** - Will change the username for a given user, as well as rename their home directory and update the registry
**Create-Admin** - Will Create a new user and add it to the Administrators group
**Delete-Admin** - Will remove a user from the Administrators group and delete the user, can optionally take a -RemoveHomeDir flag to attempt to remove the users home directory

# Modules

**AsAdmin** - Enables a script to elevate to Administrative priveleges and then call itself again
**SetAdmin** - Allows a script to add or remove a user from the Administrators group
**ColourText** - Allows output to be colourized 
