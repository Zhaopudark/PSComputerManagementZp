Import-Module PSCustomPCManagement -Force
Merge-EnvPathFromLocalMachineToCurrentUser
Add-EnvPathToCurrentProcess -Path = "C:\Users"
Remove-EnvPathByMatchingPattern
Remove-EnvPathByTarge
Remove-Module PSCustomPCManagement