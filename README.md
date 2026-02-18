# Open Unity — VS Code Extension

A lightweight VS Code extension that adds a **Unity** button to the status bar. Click it (or run the command from the palette) and the extension will:

1. Read `ProjectSettings/ProjectVersion.txt` to detect the required Unity version
2. Find the matching Unity Hub installation on disk
3. Launch Unity with the correct project path — or **bring it to the foreground** if it's already running

Everything is self-contained: the launch script ships inside the extension, so there's nothing extra to set up in your project.

---

## Quick Install (VSIX)

The pre-built `.vsix` lives at `dist/open-unity-0.2.0.vsix`.

```bash
code --install-extension ./dist/open-unity-0.2.0.vsix
```

Or from within VS Code: **Extensions** sidebar → `⋯` menu → **Install from VSIX…** → select `dist/open-unity-0.2.0.vsix`.

### Using in Another Project

Copy `dist/open-unity-0.2.0.vsix` into the target repo (e.g. `tools/open-unity-0.2.0.vsix`) and run:

```bash
code --install-extension ./tools/open-unity-0.2.0.vsix
```

You only need to do this **once per machine** — the extension installs globally into VS Code and works in every workspace.

---

## What It Does

| Feature | Details |
|---|---|
| **Status bar button** | `$(symbol-misc) Unity` on the left side of the status bar |
| **Command palette** | `Open Unity Project` (`Ctrl+Shift+P`) |
| **Version detection** | Reads `ProjectSettings/ProjectVersion.txt` automatically |
| **Smart launch** | Brings an already-running Unity instance to the foreground instead of opening a duplicate |
| **Cross-platform** | `powershell` on Windows, `pwsh` on macOS/Linux |

### How the Bundled Script Works

The extension includes `scripts/Open-UnityProject.ps1` which:

- Parses `m_EditorVersion` from `ProjectSettings/ProjectVersion.txt`
- Searches Unity Hub install paths (`C:\Program Files\Unity\Hub\Editor\<version>\...`)
- If Unity is already open for the project, focuses that window (via Win32 `SetForegroundWindow` with `WScript.Shell` fallback)
- Otherwise launches Unity with `-projectPath`

---

## Configuration

Open **Settings** (`Ctrl+,`) and search for `openUnity`:

| Setting | Type | Default | Description |
|---|---|---|---|
| `openUnity.scriptPath` | `string` | *(empty — uses bundled script)* | Workspace-relative path to a custom launch script. Leave empty to use the built-in one. |
| `openUnity.showInStatusBar` | `boolean` | `true` | Show/hide the status bar button |

### Overriding with a Custom Script

If your project needs a different launch flow, point to your own script in `.vscode/settings.json`:

```json
{
  "openUnity.scriptPath": "tools/my-custom-launch.ps1"
}
```

When `scriptPath` is set, the extension runs that workspace-relative script instead of the bundled one.

---

## Recommending to Your Team

Add a `.vscode/extensions.json` to your Unity project:

```json
{
  "recommendations": [
    "sean-lavery.open-unity"
  ]
}
```

VS Code will prompt teammates who don't have the extension installed.

## Automation

### Install Script (Bash)

```bash
#!/usr/bin/env bash
set -euo pipefail
VSIX="tools/open-unity-0.2.0.vsix"
if ! code --list-extensions | grep -qi "sean-lavery.open-unity"; then
  code --install-extension "$VSIX"
else
  echo "Open Unity already installed."
fi
```

### Install Script (PowerShell)

```powershell
$vsix = "tools\open-unity-0.2.0.vsix"
if (-not (code --list-extensions | Where-Object { $_ -match "sean-lavery.open-unity" })) {
    code --install-extension $vsix
} else {
    Write-Host "Open Unity already installed."
}
```

---

## Building from Source

```bash
# Install the packaging tool (once)
npm install -g @vscode/vsce

# Package
cd extensions/open-unity
vsce package --out ../../dist/open-unity-0.2.0.vsix
```

---

## Project Structure

```
├── dist/
│   └── open-unity-0.2.0.vsix       # Pre-built extension (install this)
├── extensions/
│   └── open-unity/
│       ├── package.json             # Extension manifest
│       ├── extension.js             # Extension entry point
│       ├── scripts/
│       │   └── Open-UnityProject.ps1  # Bundled launch script
│       ├── .vscodeignore
│       ├── CHANGELOG.md
│       └── LICENSE
├── scripts/
│   ├── install-extension.sh         # Helper: install VSIX (bash)
│   └── Install-Extension.ps1        # Helper: install VSIX (PowerShell)
├── .vscode/
│   └── extensions.json              # Workspace extension recommendation
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
