BeforeAll {
    
    
    Import-Module PSComputerManagementZp -Force
 
        
}

Describe '[Test AuthorizationTools]' {
    Context '[Test Reset-Authorization]' {
        It '[Test on Windows]' -Skip:(!$IsWIndows){
            $maybe_c = (Get-ItemProperty ${Home}).PSDrive.Name
            {Reset-Authorization "$maybe_c`:\"} | Should -Throw "Reset-Authorization: Cannot validate argument on parameter 'Path'. If maybe_c`:\ is in SystemDisk, it has to be or in `${Home}: ${Home}, unless it will not be supported."

        }
    }
        
}

AfterAll {
    Remove-Module PSComputerManagementZp -Force
}