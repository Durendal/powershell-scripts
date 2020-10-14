# Powershell Scripts

This repository is a collection of powershell scripts that can be used for administering Windows systems. Dependencies can be installed by running the Setup.ps1 script, afterwards you can execute the scripts in the top level directory, or write your own scripts utilizing the various modules and classes included.

The classes are designed to have as few properties as possible, opting instead to favour generating results on the fly via different powershell commands. Leaving state management to the operating system and reducing the chance of any potential race conditions or inconsistencies introduced by storing a local copy of the object and syncing at intervals. They are also designed to inter-operate with eachother. e.g. you can pass a user object to a group object or vise versa to add/remove the user from the group.

# Scripts

**Change-Username** - Will change the username for a given user, as well as rename their home directory, update the registry with the new home directory, and change the user password

**Create-Admin** - Will Create a new user and optionally add it to the Administrators group

**Delete-Admin** - Will optionally remove a user from the Administrators group, then delete the user, can also take an optional -RemoveHomeDir flag to attempt to remove the users home directory

# Modules

**AsAdmin** - Enables a script to elevate to Administrative priveleges and then call itself again

**SetAdmin** - Allows a script to add or remove a user from the Administrators group

**ColourText** - Allows output to be colourized

# Classes

**LocalUser** - An object for inspecting and manipulating Local User Accounts

**Computer** - An object for inspecting and manipulating the Local Computer

**Group** - An object for inspecting and manipulating Local Groups
