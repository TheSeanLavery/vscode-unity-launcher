const vscode = require('vscode');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

const BUNDLED_SCRIPT = 'scripts/Open-UnityProject.ps1';

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

    const script = resolveScript(context, workspaceFolder);
    if (!script) return;

    const command = buildCommand(script, workspaceFolder);

    vscode.window.withProgress(
      {
        location: vscode.ProgressLocation.Notification,
        title: 'Opening Unity project\u2026',
        cancellable: false
      },
      () =>
        new Promise((resolve) => {
          exec(command, { cwd: workspaceFolder }, (err, _stdout, stderr) => {
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

/**
 * Resolves which script to run. If the user configured a custom path, use that
 * (workspace-relative). Otherwise, use the script bundled inside the extension.
 */
function resolveScript(context, workspaceFolder) {
  const config = vscode.workspace.getConfiguration('openUnity');
  const inspected = config.inspect('scriptPath');

  const hasUserOverride =
    inspected.workspaceValue !== undefined ||
    inspected.workspaceFolderValue !== undefined ||
    inspected.globalValue !== undefined;

  if (hasUserOverride) {
    const rel = config.get('scriptPath');
    const abs = path.join(workspaceFolder, rel);
    if (!fs.existsSync(abs)) {
      vscode.window.showErrorMessage(
        `Open Unity: Custom script not found at "${abs}". Check the openUnity.scriptPath setting.`
      );
      return null;
    }
    return abs;
  }

  const bundled = path.join(context.extensionPath, BUNDLED_SCRIPT);
  if (!fs.existsSync(bundled)) {
    vscode.window.showErrorMessage(
      `Open Unity: Bundled script missing at "${bundled}". The extension may be corrupted — try reinstalling.`
    );
    return null;
  }
  return bundled;
}

/**
 * Builds the shell command to execute the launch script.
 * Passes -ProjectPath so the script targets the current workspace.
 */
function buildCommand(scriptPath, projectPath) {
  if (process.platform === 'win32') {
    return `powershell -ExecutionPolicy Bypass -File "${scriptPath}" -ProjectPath "${projectPath}"`;
  }
  if (scriptPath.endsWith('.ps1')) {
    return `pwsh -ExecutionPolicy Bypass -File "${scriptPath}" -ProjectPath "${projectPath}"`;
  }
  return `bash "${scriptPath}" "${projectPath}"`;
}

function deactivate() {}

module.exports = { activate, deactivate };
