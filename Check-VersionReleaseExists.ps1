param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $true)]
    [string]$Repository,
    
    [Parameter(Mandatory = $true)]
    [string]$GithubToken
)

# Set error action preference
$ErrorActionPreference = 'Stop'

# Function to check if release exists
function Test-ReleaseExists {
    param(
        [string]$Version,
        [string]$Repository,
        [string]$GithubToken
    )
    
    try {
        Write-Host "🔍 Checking if release $Version exists..."
        
        # Set environment variable for gh CLI
        $env:GH_TOKEN = $GithubToken
        
        # Check if release exists using GitHub CLI
        $result = gh release view $Version --repo $Repository 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Release $Version found" -ForegroundColor Green
            return @{
                Exists = $true
                Tag = $Version
                Success = $true
                Message = "Release found"
            }
        } else {
            Write-Host "Release $Version not found" -ForegroundColor Yellow
            return @{
                Exists = $false
                Tag = $null
                Success = $true
                Message = "Release not found"
            }
        }
    }
    catch {
        Write-Host "❌ Error checking release: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            Exists = $false
            Tag = $null
            Success = $false
            Message = "Error: $($_.Exception.Message)"
        }
    }
}

# Main execution
try {
    $result = Test-ReleaseExists -Version $Version -Repository $Repository -GithubToken $GithubToken
    
    # Set GitHub Actions outputs
    Write-Host "Setting GitHub Actions outputs..." -ForegroundColor Yellow
    "exists=$($result.Exists.ToString().ToLower())" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
    
    if ($result.Exists) {
        "tag=$($result.Tag)" | Out-File -FilePath $env:GITHUB_OUTPUT -Append -Encoding utf8
    }
    
    # Print all outputs for debugging
    Write-Host "📋 GitHub Actions Outputs Set:" -ForegroundColor Cyan
    Write-Host "  exists: $($result.Exists.ToString().ToLower())" -ForegroundColor Green
    if ($result.Exists) {
        Write-Host "  tag: $($result.Tag)" -ForegroundColor Green
    } else {
        Write-Host "  tag: (not set - release doesn't exist)" -ForegroundColor Yellow
    }
    
    # Exit 0 when we successfully determined the result (exists or not); only exit 1 on script error
    if ($result.Exists) {
        Write-Host "✅ Release found" -ForegroundColor Green
    } else {
        Write-Host "Release not found (exists=false)" -ForegroundColor Yellow
    }
    exit 0
}
catch {
    Write-Host "❌ Script execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}