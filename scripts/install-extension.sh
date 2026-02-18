#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VSIX_PATH="$REPO_ROOT/dist/open-unity-0.1.0.vsix"

if [ ! -f "$VSIX_PATH" ]; then
  echo "Error: VSIX not found at $VSIX_PATH"
  exit 1
fi

if ! command -v code &>/dev/null; then
  echo "Error: 'code' command not found. Make sure VS Code is installed and the 'code' CLI is in your PATH."
  exit 1
fi

if code --list-extensions 2>/dev/null | grep -qi "sean-lavery.open-unity"; then
  echo "Open Unity extension is already installed. Reinstalling..."
  code --install-extension "$VSIX_PATH" --force
else
  echo "Installing Open Unity extension..."
  code --install-extension "$VSIX_PATH"
fi

echo "Done. Restart VS Code if it's currently open."
