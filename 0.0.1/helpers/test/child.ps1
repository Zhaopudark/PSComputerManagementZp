param (
    [ref]$TestVariable
)
$local:test_var = 'lalala'
$script:test_var2 = 'lalala2'
$test_var3 = 'lalala3'
$global:test_var4 = 'lalala4'
$global:test_var5 = @(111,'222')
test -content "Child"

$TestVariable.Value += 222

Write-Output "In child, partent's var is $($TestVariable.Value)"
Write-Output "In child, before modifying test_list, it is $test_list"
$test_list += '222'
Write-Output "In child, after modifying test_list, it is $test_list"

Write-Output "In child, before set test_list2, it is $test_list2"
$test_list2 += 1
Write-Output "In child, after directly modifying test_list2, it is $test_list2"