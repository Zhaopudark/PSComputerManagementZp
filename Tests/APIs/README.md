Tests for all public components of the project. 

Including:

- Public Functions
- Public Cmdlets
- ...

Excluding:
- All private components

Configuration of the environment for testing (Adding components to testing scope):
- Only public components are allowed. Can use a command like `Import-Module PSComputerManagementZp`.
- Forbid any private component. Avoid direct commands like `. "${PSScriptRoot}\..\..\Module\Config.ps1"`.
- If some private components are really needed, mimic them with a different name before using them.
- Ensure that all functionalities of public components are not affected by what is defined in each testing scope.