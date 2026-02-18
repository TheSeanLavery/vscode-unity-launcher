$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$vsixPath = Join-Path $repoRoot "dist\open-unity-0.1.0.vsix"

if (-not (Test-Path $vsixPath)) {
    Write-Error "VSIX not found at $vsixPath"
    exit 1
}

$codeCmd = Get-Command code -ErrorAction SilentlyContinue
if (-not $codeCmd) {
    Write-Error "'code' command not found. Make sure VS Code is installed and the 'code' CLI is in your PATH."
    exit 1
}

$installed = code --list-extensions | Where-Object { $_ -match "sean-lavery.open-unity" }
if ($installed) {
    Write-Host "Open Unity extension is already installed. Reinstalling..."
    code --install-extension $vsixPath --force
} else {
    Write-Host "Installing Open Unity extension..."
    code --install-extension $vsixPath
}

Write-Host "Done. Restart VS Code if it's currently open."
