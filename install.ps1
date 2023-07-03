$module_install_path = "$(Split-Path -Path $PROFILE -Parent)\Modules\PSComputerManagementZp"
if (!(Test-Path $module_install_path)){
    New-Item -ItemType Directory -Path $module_install_path -Force
}

# to omit `.git` and other hidden items, do not use `-force`
$source_paths = Get-ChildItem $PSScriptRoot -Exclude ".*" 

Copy-Item -Path $source_paths -Destination $module_install_path -Recurse -Force 

