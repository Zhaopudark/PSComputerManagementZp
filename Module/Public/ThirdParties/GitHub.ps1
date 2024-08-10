function Get-GitHubRepoInfoSnapshot{
<#
.DESCRIPTION
    Get some information's snapshot of a GitHub repository, and return a record of it.
.PARAMETER UserName
    The user name of the repo.
.PARAMETER RepoName
    The repo name.
.PARAMETER GithubPAT
    The GitHub Personal Access Token(PAT).
    The PAT is needed to access the GitHub API.
.INPUTS
    String.
    String.
    String.
.OUTPUTS
    [GitHubRepoInfoSnapshot].
#>
    param(
        [Parameter(Mandatory)]
        [string]$UserName,
        [Parameter(Mandatory)]
        [string]$RepoName,
        [Parameter(Mandatory)]
        [string]$GithubPAT
    )
    service = [GitHubService]::new($GithubPAT)
    return service.GetRepoInfoSnapshot($UserName,$RepoName)
}