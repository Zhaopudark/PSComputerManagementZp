BeforeAll {
    if ($env:GH_TOKEN -and $env:GH_USER_NAME -and $env:GH_REPO_NAME) {
        Write-Warning 'Warning: GH_TOKEN environment variable is set. Avoid running this test in an insecure environment.'
    } else {
        throw 'Environment variable GH_TOKEN, GH_USER_NAME, GH_REPO_NAME are not set completely. Test cannot proceed.'
    }
}

Describe 'Test the third party assister' {
    Context 'Get response from GitHub' {
        It 'Test Get-GitHubRepoInfoSnapshot' {
            $snapshot = Get-GitHubRepoInfoSnapshot -UserName $env:GH_USER_NAME -RepoName $env:GH_REPO_NAME -GithubPAT $env:GH_TOKEN
            $snapshot | Should -Not -BeNullOrEmpty
            $snapshot | Should -BeOfType 'PSModuleHelperZp.GitHubRepoInfoSnapshot'
        }
    }
}