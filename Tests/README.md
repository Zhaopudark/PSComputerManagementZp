All tests have been partitioned into 3 parts:
1. [Installation Tests](/.github/workflows/APIs-Tests.yaml), testing the installations of the module. 
    - Path: /install.ps1
    - No additional test files are required.

2. [Components Tests](/.github/workflows/Components-Tests.yaml), testing all the private components of the project.
    - Paths: /Tests/Components/*.Tests.ps1
    - Including:
        - Private Functions
        - Private Cmdlets
        - Other Tools
        - ...
    - Excluding:
        - All public components
    - Testing configuration, adding components to testing scope(environment):
        - Only private components are allowed. Can use a command like `. "${PSScriptRoot}\..\..\Module\Config.ps1"`.
        - Forbid any public component. Avoid commands like `Import-Module PSComputerManagementZp`.
        - Ensure that all functionalities of private components are not affected by what is defined in each testing scope.

3. [APIs Tests](/.github/workflows/APIs-Tests.yaml), testing all the public components of the project.
    - Paths: /Tests/APIs/*.Tests.ps1
    - Including:
        - Public Functions
        - Public Cmdlets
        - ...
    - Excluding:
        - All private components
    - Testing configuration, adding components to testing scope(environment):
        - Only public components are allowed. Can use a command like `Import-Module PSComputerManagementZp`.
        - Forbid any private component. Avoid direct commands like `. "${PSScriptRoot}\..\..\Module\Config.ps1"`.
        - If some private components are needed, mimic them with a different name before using them.
        - Ensure that all functionalities of public components are not affected by what is defined in each testing scope.