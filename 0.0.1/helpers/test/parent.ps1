function test {
    param (
        [string]$content
    )
    Write-Host "This is $content" 
}

$test_list = @('111')
$global:test_list2 = @('1111')
./child.ps1 -TestVariable ([ref]$test_list)
Write-Host "In parent, test_list is $test_list"
Write-Host "In parent, test_list2 is $test_list2"

Write-Host "In parent, test_var is $test_var"
Write-Host "In parent, test_var2 is $test_var2"
Write-Host "In parent, test_var3 is $test_var3"
Write-Host "In parent, test_var4 is $test_var4"
Write-Host "In parent, before modifying test_var5, it is $test_var5"
$test_var5 += 333
Write-Host "In parent, after modifying test_var5, it is $test_var5"