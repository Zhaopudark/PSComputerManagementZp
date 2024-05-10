# Contribution Guide

Contributions are welcome. But recently, the introduction and documentation are not complete. So, please wait for a while.

A simple way to contribute is to open an issue to report bugs or request new features.

Here are some formative rules for this module's development:
- **Version Iteration**: Use [Semantic Versioning](https://semver.org/) to iterate versions.:
  - Even though this is a PowerShell, it prefers to use a Pythonic style as [PEP440](https://peps.python.org/pep-0440/).
  - Many tests on both APIs and components have been made, and they also have been run and passed on `GitHub Actions`. So it can be considered that `alpha` tests have been done. As a consequence, only `beta` tests are needed.

- **Coding:**
    - **Variable Naming**: `snake_case` is used to indicate private variables while `PascalCase` is used for non-private variables. So, in code style consistency, please consider the above rule.

    - **Comments**: This module refers to many cmdlets in [Microsoft.PowerShell.Management](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-7.3), such as [`Get-Item`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-item?view=powershell-7.3), [`Copy-Item`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/copy-item?view=powershell-7.3) and [`New-Item`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item?view=powershell-7.3). Then, we decided to use a similar comment style as theirs. The following are some specific rules::
        - `.SYNOPSIS` and `.DESCRIPTION` are both used to describe the function's usage and details.
        - `.DESCRIPTION` is mandatory while `.SYNOPSIS` is optional.
        - `.SYNOPSIS` is a brief description of key points, but `.DESCRIPTION` is a detailed description with rationales and ideas. 
        - `.SYNOPSIS` may use more normal language than `.DESCRIPTION`. 
        - `.OUTPUTS` and `.INPUTS` are used to describe the function's output and input. Even though they can contain plenty of information, we only use them to describe the type of output and input as those cmdlets in [Microsoft.PowerShell.Management](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/?view=powershell-7.3) do. Any corresponding types, except `Switch`, will be included and put in `.OUTPUTS` and `.INPUTS`. If there are multiple items, stack them.
        - In `.OUTPUTS` and `.INPUTS`, `None` is used to represent the `Void` if there is no input or output. If return `$null`, it will be noted as `Null` in the `.OUTPUTS`.
        - `.LINK` is used to post crucial links in the format `[aaaa](bbb)` without any other words.
        - Given that, at the moment, widescreen monitors are not uncommon, don't actively make length constraints on comments, and don't manually split lines in the middle of sentences. The task of constraining the length of comments can be left to editors and automation tools and not reflected in the source code.
- **Internal Behaviors:**
    - **Logging**: The principle is that when making logs, the logs will be written into files anyway. If a log needs to be displayed in the console, it will be done as a `Verbose` message. The private function `Write-FileLog` should only be used in the private function `Write-Log`, and the latter is the only logging function in all components. Also, the latter is not an API function for normal users.
- **Objects to Operate:**
    - **Hardlinks**: Although hard links can sometimes be considered normal files, in this module, it is recommended to restrict any `copy-` or `move-` operations on hard links to avoid potential problems.