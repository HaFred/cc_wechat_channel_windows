# start-wechat-agent.ps1
# Launches Claude Code in the remote workspace with WeChat MCP server active.
# The CLAUDE.md in the workspace instructs Claude to auto-poll WeChat messages.

$ErrorActionPreference = "Stop"

# Refresh PATH to pick up bun and claude
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$WorkspaceDir = "D:\fredcode\Dev_framworklab_vllm\claude_code_related_repo\remote_wechat_safe_workspace"

# Ensure workspace exists
if (-not (Test-Path $WorkspaceDir)) {
    New-Item -ItemType Directory -Path $WorkspaceDir -Force | Out-Null
}

Write-Host "============================================" -ForegroundColor Green
Write-Host "  WeChat Auto-Agent for Claude Code" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Workspace: $WorkspaceDir" -ForegroundColor Yellow
Write-Host "MCP Server: wechat (bun wechat-channel.ts)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Once Claude Code starts:" -ForegroundColor Cyan
Write-Host '  Type "start" to begin auto-monitoring WeChat messages' -ForegroundColor Cyan
Write-Host '  Type "stop" to pause monitoring' -ForegroundColor Cyan
Write-Host ""

Set-Location $WorkspaceDir
claude
