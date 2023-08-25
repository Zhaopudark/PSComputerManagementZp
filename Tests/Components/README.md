Tests for private components of the project.

Including:

- Private Functions
- Private Cmdlets
- Other Tools
- ...

Excluding:
- All public components

Configuration of the environment for testing (Adding components to testing scope):
- Only private components are allowed. Can use a command like `. "${PSScriptRoot}\..\..\Module\Config.ps1"`.
- Forbid any public component. Avoid commands like `Import-Module PSComputerManagementZp`.
- Ensure that private components are independently viable.
- Ensure that all functionalities of private components are not affected by what is defined in each testing scope.