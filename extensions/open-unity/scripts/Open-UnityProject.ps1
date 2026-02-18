# Open-UnityProject.ps1
# Launches Unity with the correct version for this project, or brings it to foreground if already open

param(
    [string]$ProjectPath = (Split-Path -Parent $PSScriptRoot)
)

# Read the Unity version from ProjectVersion.txt
$versionFile = Join-Path $ProjectPath "ProjectSettings\ProjectVersion.txt"
if (-not (Test-Path $versionFile)) {
    Write-Error "Could not find ProjectVersion.txt at: $versionFile"
    exit 1
}

$versionContent = Get-Content $versionFile -Raw
if ($versionContent -match 'm_EditorVersion:\s*(\S+)') {
    $unityVersion = $Matches[1]
    Write-Host "Detected Unity version: $unityVersion"
} else {
    Write-Error "Could not parse Unity version from ProjectVersion.txt"
    exit 1
}

# Get the project folder name for window title matching
$projectName = Split-Path -Leaf $ProjectPath
Write-Host "Project name: $projectName"
Write-Host "Project path: $ProjectPath"

# Check if Unity is already running with this project
# Unity window titles typically include the project name
$unityProcesses = Get-Process -Name "Unity" -ErrorAction SilentlyContinue

$existingProcess = $null
foreach ($proc in $unityProcesses) {
    try {
        $windowTitle = $proc.MainWindowTitle
        if ($windowTitle -and $windowTitle -like "*$projectName*") {
            $existingProcess = $proc
            Write-Host "Found existing Unity process with window: $windowTitle"
            break
        }
    } catch {
        # Process might have exited or we can't access it
        continue
    }
}

if ($existingProcess) {
    Write-Host "Unity is already running with this project. Bringing to foreground..."
    
    # Use Windows API to bring window to foreground
    Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class WindowHelper {
            [DllImport("user32.dll")]
            public static extern bool SetForegroundWindow(IntPtr hWnd);
            
            [DllImport("user32.dll")]
            public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
            
            [DllImport("user32.dll")]
            public static extern bool IsIconic(IntPtr hWnd);
            
            public const int SW_RESTORE = 9;
        }
"@
    
    $hwnd = $existingProcess.MainWindowHandle
    
    if ($hwnd -ne [IntPtr]::Zero) {
        # If window is minimized, restore it first
        if ([WindowHelper]::IsIconic($hwnd)) {
            [WindowHelper]::ShowWindow($hwnd, [WindowHelper]::SW_RESTORE) | Out-Null
        }
        
        # Bring to foreground
        $result = [WindowHelper]::SetForegroundWindow($hwnd)
        if ($result) {
            Write-Host "Successfully brought Unity to foreground."
        } else {
            Write-Host "SetForegroundWindow returned false - window may not have been activated due to Windows restrictions."
            # Try alternative method using WScript.Shell
            try {
                $wshell = New-Object -ComObject wscript.shell
                $wshell.AppActivate($existingProcess.MainWindowTitle) | Out-Null
                Write-Host "Attempted activation via WScript.Shell"
            } catch {
                Write-Host "Alternative activation also failed: $_"
            }
        }
    } else {
        Write-Host "Warning: Could not get window handle. Unity may be running but window is not accessible."
    }
} else {
    Write-Host "Unity is not running with this project. Launching..."
    
    # Construct path to Unity Editor
    # Check common installation locations
    $unityHubPaths = @(
        "C:\Program Files\Unity\Hub\Editor\$unityVersion\Editor\Unity.exe",
        "D:\Program Files\Unity\Hub\Editor\$unityVersion\Editor\Unity.exe",
        "$env:ProgramFiles\Unity\Hub\Editor\$unityVersion\Editor\Unity.exe"
    )
    
    $unityExe = $null
    foreach ($path in $unityHubPaths) {
        if (Test-Path $path) {
            $unityExe = $path
            break
        }
    }
    
    if (-not $unityExe) {
        Write-Error "Could not find Unity $unityVersion. Checked paths:`n$($unityHubPaths -join "`n")"
        exit 1
    }
    
    Write-Host "Found Unity at: $unityExe"
    Write-Host "Launching Unity..."
    
    # Launch Unity with the project
    Start-Process -FilePath $unityExe -ArgumentList "-projectPath", "`"$ProjectPath`""
    
    Write-Host "Unity launch initiated."
}
