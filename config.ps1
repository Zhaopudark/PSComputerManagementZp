$local:ConfigInfo= @{
    PrivateComponentsTestsDir = "${PSScriptRoot}\Tests\Components"
    PublicAPIsTestsDir = "${PSScriptRoot}\Tests\APIs"
    PrivateComponentsDocsDir = "${PSScriptRoot}\Docs\Components"
    PublicAPIsDocsDir = "${PSScriptRoot}\Docs\APIs"
    MDDocs = @{
        Release = "${PSScriptRoot}\RELEASE.md"
        Root = "${PSScriptRoot}\README.md"
        Tests = "${PSScriptRoot}\Tests\README.md"
        Components = "${PSScriptRoot}\Docs\Components\README.md"
        APIs = "${PSScriptRoot}\Docs\APIs\README.md"
        Examples = "${PSScriptRoot}\Examples\README.md"
        Contribution = "${PSScriptRoot}\CONTRIBUTION.md"
    }
}