# 切换 Telegram Bot 并启动 Claude Code (Windows PowerShell)
# 用法: .\telegram-switch.ps1 intern-ai
#       .\telegram-switch.ps1 ai-insight

param(
    [Parameter(Position=0)]
    [string]$BotName
)

$ErrorActionPreference = "Stop"

$TelegramDir = Join-Path $env:USERPROFILE ".claude\channels\telegram"
$AccountsDir = Join-Path $TelegramDir "bots"

if (-not $BotName) {
    Write-Host "用法: .\telegram-switch.ps1 <bot名称>"
    Write-Host ""
    Write-Host "已保存的 bot:"
    if (Test-Path $AccountsDir) {
        Get-ChildItem -Path $AccountsDir -Filter "*.env" | ForEach-Object {
            Write-Host "  $($_.BaseName)"
        }
    }
    Write-Host ""
    Write-Host "添加新 bot:"
    Write-Host "  New-Item -ItemType Directory -Force -Path `"$AccountsDir`""
    Write-Host "  Set-Content -Path `"$AccountsDir\bot名称.env`" -Value 'TELEGRAM_BOT_TOKEN=你的token'"
    exit 1
}

$BotEnv = Join-Path $AccountsDir "$BotName.env"

if (-not (Test-Path $BotEnv)) {
    Write-Host "错误: 未找到 bot '$BotName'"
    Write-Host "请先创建: Set-Content -Path `"$BotEnv`" -Value 'TELEGRAM_BOT_TOKEN=xxx'"
    exit 1
}

# 备份当前 access.json（按 bot 名保存）
$AccessJson = Join-Path $TelegramDir "access.json"
$CurrentEnv = Join-Path $TelegramDir ".env"

if (Test-Path $AccessJson) {
    if (Test-Path $CurrentEnv) {
        $currentToken = Get-Content $CurrentEnv -Raw -ErrorAction SilentlyContinue
        if ($currentToken) {
            $matchedBot = Get-ChildItem -Path $AccountsDir -Filter "*.env" -ErrorAction SilentlyContinue | Where-Object {
                (Get-Content $_.FullName -Raw) -eq $currentToken
            } | Select-Object -First 1
            if ($matchedBot) {
                $backupPath = Join-Path $AccountsDir "$($matchedBot.BaseName).access.json"
                Copy-Item -Path $AccessJson -Destination $backupPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# 切换 token
Copy-Item -Path $BotEnv -Destination $CurrentEnv -Force

# 恢复目标 bot 的 access.json
$BotAccessJson = Join-Path $AccountsDir "$BotName.access.json"
if (Test-Path $BotAccessJson) {
    Copy-Item -Path $BotAccessJson -Destination $AccessJson -Force
}

$tokenPreview = (Get-Content $BotEnv -First 1).Substring(0, [Math]::Min(30, (Get-Content $BotEnv -First 1).Length))
Write-Host "✅ 已切换到 bot: $BotName"
Write-Host "   Token: $tokenPreview..."
Write-Host ""
Write-Host "启动命令:"
Write-Host "  claude --channels plugin:telegram@claude-plugins-official"
