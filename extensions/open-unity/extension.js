const vscode = require('vscode');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
  const config = vscode.workspace.getConfiguration('openUnity');

  if (config.get('showInStatusBar', true)) {
    const button = vscode.window.createStatusBarItem(
      vscode.StatusBarAlignment.Left,
      100
    );
    button.text = '$(symbol-misc) Unity';
    button.tooltip = 'Open Unity Project';
    button.command = 'openUnity.open';
    button.show();
    context.subscriptions.push(button);
  }

  const cmd = vscode.commands.registerCommand('openUnity.open', () => {
    const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceFolder) {
      vscode.window.showErrorMessage('Open Unity: No workspace folder is open.');
      return;
    }

    const relativePath = config.get('scriptPath', 'scripts/Open-UnityProject.ps1');
    const script = path.join(workspaceFolder, relativePath);

    if (!fs.existsSync(script)) {
      vscode.window.showErrorMessage(
        `Open Unity: Script not found at "${script}". ` +
        'Check the openUnity.scriptPath setting.'
      );
      return;
    }

    const shell = detectShell();
    const command = buildCommand(shell, script);

    vscode.window.withProgress(
      {
        location: vscode.ProgressLocation.Notification,
        title: 'Opening Unity project…',
        cancellable: false
      },
      () =>
        new Promise((resolve) => {
          exec(command, { cwd: workspaceFolder }, (err, stdout, stderr) => {
            if (err) {
              vscode.window.showErrorMessage(
                `Open Unity: ${stderr || err.message}`
              );
            } else {
              vscode.window.showInformationMessage('Unity project opened.');
            }
            resolve();
          });
        })
    );
  });

  context.subscriptions.push(cmd);
}

function detectShell() {
  if (process.platform === 'win32') return 'powershell';
  if (process.platform === 'darwin') return 'bash';
  return 'bash';
}

function buildCommand(shell, scriptPath) {
  if (shell === 'powershell') {
    return `powershell -ExecutionPolicy Bypass -File "${scriptPath}"`;
  }
  // On macOS/Linux, try pwsh first; fall back to bash if the script is .sh
  if (scriptPath.endsWith('.ps1')) {
    return `pwsh -ExecutionPolicy Bypass -File "${scriptPath}"`;
  }
  return `bash "${scriptPath}"`;
}

function deactivate() {}

module.exports = { activate, deactivate };
