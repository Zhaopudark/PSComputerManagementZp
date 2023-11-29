All tests have been partitioned into 3 parts:
1. [Installation Tests](../.github/workflows/Intsallation-Tests-on-Windows.yaml), testing the installations of the module. 
    - Path: /install.ps1
    - No additional test files are required.

2. [Components Tests](../.github/workflows/Components-Tests-on-Windows.yaml), testing all the private components of the project.
    - Paths: /Tests/Components/*.Tests.ps1
    - Including:
        - Private Functions
        - Private Cmdlets
        - Other Tools
        - ...
    - Excluding:
        - All public components
    - Testing configuration, adding components to testing scope(environment):
        - Only private components are allowed.
        - Forbid any public component. Avoid commands like `Import-Module PSComputerManagementZp`.

3. [APIs Tests](../.github/workflows/APIs-Tests-on-Windows.yaml), testing all the public components of the project.
    - Paths: /Tests/APIs/*.Tests.ps1
    - Including:
        - Public Functions
        - Public Cmdlets
        - ...
    - Excluding:
        - All private components
    - Testing configuration, adding components to testing scope(environment):
        - Only public components are allowed. Can use a command like `Import-Module PSComputerManagementZp`.
        - Forbid any direct private component. Import them with a special prefix before using them.