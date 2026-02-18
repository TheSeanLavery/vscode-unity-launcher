# Changelog

## 0.2.0

- **Bundled launch script** — `Open-UnityProject.ps1` now ships inside the extension; no external script required
- Auto-detects the Unity version from `ProjectSettings/ProjectVersion.txt`
- Brings an already-running Unity instance to the foreground instead of launching a duplicate
- Falls back to a user-configured `openUnity.scriptPath` when set

## 0.1.0

- Initial release
- Status bar button to open Unity project
- Configurable script path via `openUnity.scriptPath`
- Cross-platform support (PowerShell on Windows, pwsh/bash on macOS/Linux)
