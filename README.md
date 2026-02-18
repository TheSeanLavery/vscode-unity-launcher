# Open Unity — VS Code Extension

A lightweight VS Code extension that adds a **Unity** button to the status bar. Clicking it runs your project's `Open-UnityProject.ps1` script (or any custom script) to launch Unity with the correct project path.
<img width="353" height="177" alt="image" src="https://github.com/user-attachments/assets/33e76e66-2eae-49c1-b7fd-0fab323e9191" />

## Quick Install (VSIX)

The pre-built `.vsix` file lives at `dist/open-unity-0.1.0.vsix`. Install it with a single command:

```bash
code --install-extension ./dist/open-unity-0.1.0.vsix
```

Or from within VS Code: **Extensions** sidebar → `⋯` menu → **Install from VSIX…** → select `dist/open-unity-0.1.0.vsix`.

### Using in Another Project

Copy `dist/open-unity-0.1.0.vsix` into the target repo (e.g. `tools/open-unity-0.1.0.vsix`) and run:

```bash
code --install-extension ./tools/open-unity-0.1.0.vsix
```

You only need to do this once per machine — the extension is installed globally into VS Code.

To make it easy for teammates, add a setup script or Makefile target (see [Automation](#automation) below).

## What It Does

| Feature | Details |
|---|---|
| **Status bar button** | Shows `$(symbol-misc) Unity` on the left side of the status bar |
| **Command** | `Open Unity Project` available from the Command Palette (`Ctrl+Shift+P`) |
| **Script execution** | Runs a configurable PowerShell/bash script to open Unity |
| **Cross-platform** | Uses `powershell` on Windows, `pwsh` on macOS/Linux for `.ps1` files, `bash` for `.sh` files |

## Configuration

Open **Settings** (`Ctrl+,`) and search for `openUnity`:

| Setting | Type | Default | Description |
|---|---|---|---|
| `openUnity.scriptPath` | `string` | `scripts/Open-UnityProject.ps1` | Workspace-relative path to the script that opens Unity |
| `openUnity.showInStatusBar` | `boolean` | `true` | Show/hide the status bar button |

### Example: Custom Script Path

In your project's `.vscode/settings.json`:

```json
{
  "openUnity.scriptPath": "tools/launch-unity.sh"
}
```

## Recommending to Your Team

Add a `.vscode/extensions.json` to your project so VS Code prompts teammates to install:

```json
{
  "recommendations": [
    "sean-lavery.open-unity"
  ]
}
```

> **Note:** This recommendation only works if the extension is already installed via the `.vsix`. VS Code will remind users who don't have it installed yet.

## Automation

### Install Script (Bash)

Create a `scripts/setup.sh` in your project:

```bash
#!/usr/bin/env bash
set -euo pipefail

VSIX_PATH="tools/open-unity-0.1.0.vsix"

if ! code --list-extensions | grep -qi "sean-lavery.open-unity"; then
  echo "Installing Open Unity extension..."
  code --install-extension "$VSIX_PATH"
else
  echo "Open Unity extension already installed."
fi
```

### Install Script (PowerShell)

Create a `scripts/Setup.ps1` in your project:

```powershell
$vsix = "tools\open-unity-0.1.0.vsix"

$installed = code --list-extensions | Where-Object { $_ -match "sean-lavery.open-unity" }
if (-not $installed) {
    Write-Host "Installing Open Unity extension..."
    code --install-extension $vsix
} else {
    Write-Host "Open Unity extension already installed."
}
```

## Building from Source

If you need to modify the extension and rebuild the `.vsix`:

```bash
# Install the packaging tool (once)
npm install -g @vscode/vsce

# Package
cd extensions/open-unity
vsce package --out ../../dist/open-unity-0.1.0.vsix
```

## Project Structure

```
├── dist/
│   └── open-unity-0.1.0.vsix   # Pre-built extension (install this)
├── extensions/
│   └── open-unity/
│       ├── package.json         # Extension manifest
│       ├── extension.js         # Extension entry point
│       ├── .vscodeignore        # Files excluded from VSIX
│       ├── CHANGELOG.md
│       └── LICENSE
├── .gitattributes
├── LICENSE
└── README.md
```

## Uninstalling

```bash
code --uninstall-extension sean-lavery.open-unity
```

## License

MIT — see [LICENSE](LICENSE).
