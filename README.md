> [!NOTE]
> **YOUR 24-7 Personal Assistant on WeChat**
> 
> This project is a fork from [vansin/claude-code-wechat-channel](https://github.com/vansin/claude-code-wechat-channel), which was originally for MacOS. The readme below will be in Chinese for better readbility in WeChat.
>
> **KEY FEATURES**
> 1. Claude Code API mode supported
> 2. Heartbeat system done, automatically grabbing instructions from your WeChat chatbox

# Claude Code WeChat Channel (Windows 11)

将微信消息桥接到 Claude Code 会话的 Channel 插件。**本版本已适配 Windows 11。**

基于微信官方 ClawBot ilink API（与 `@tencent-weixin/openclaw-weixin` 使用相同协议），让你在微信中直接与 Claude Code 对话。

## 工作原理

```
微信 (iOS) → WeChat ClawBot → ilink API → [本插件] → Claude Code Session
                                                  ↕
Claude Code ← MCP Channel Protocol ← wechat_reply tool
```

## 与 macOS 原版的区别

本 Windows 版做了以下适配：

| 变更项 | macOS 原版 | Windows 版 |
|--------|-----------|------------|
| 主目录路径 | `process.env.HOME` (`~/`) | `os.homedir()` (`%USERPROFILE%`) |
| 文件权限 | `fs.chmodSync(0o600)` | 保留调用但 Windows 上为无害 no-op |
| Shell 脚本 | `telegram-switch.sh` (Bash) | `telegram-switch.ps1` (PowerShell) |
| 环境变量语法 | `WECHAT_ACCOUNT=work claude ...` | `$env:WECHAT_ACCOUNT='work'; claude ...` |
| 安装命令 | `curl -fsSL https://bun.sh/install \| bash` | `powershell -c "irm bun.sh/install.ps1 \| iex"` |
| 凭据路径 | `~/.claude/channels/wechat/` | `%USERPROFILE%\.claude\channels\wechat\` |

## 前置要求

- [Bun](https://bun.sh) >= 1.0（见下方安装说明）
- [Claude Code](https://claude.com/claude-code) >= 2.1.80
- claude.ai 账号登录（不支持 API key）
- 微信 iOS 最新版（需支持 ClawBot 插件）

### 在 Windows 11 上安装 Bun

在 **PowerShell** 中运行：

```powershell
# 官方安装脚本
powershell -c "irm bun.sh/install.ps1 | iex"

# 或者使用 npm 全局安装
npm install -g bun

# 或者使用 scoop
scoop install bun

# 或者使用 winget
winget install Oven-sh.Bun

# 验证安装
bun --version
```

> 如果你的环境无法安装 Bun，也可以用 `npx tsx` 替代 `bun` 来运行 `.ts` 文件，但性能会有差异。

## 最简上手方式

把本目录交给 Claude Code，让它帮你完成全部配置：

```powershell
cd D:\fredcode\Dev_framworklab_vllm\claude_code_related_repo\ccwechatchannel_windowsversion
claude
```

进入 Claude Code 后直接说：

> 帮我配置微信 Channel，按照 README 的步骤来

Claude Code 会自动读取 README，帮你安装依赖、引导扫码登录、配置 MCP，全程不需要你手动操作。

---

## 手动配置（快速开始）

### 1. 安装依赖

```powershell
cd D:\fredcode\Dev_framworklab_vllm\claude_code_related_repo\ccwechatchannel_windowsversion
bun install
```

### 2. 微信扫码登录

```powershell
bun setup.ts              # 默认账号
```

终端会显示二维码，用微信扫描并确认。凭据保存到 `%USERPROFILE%\.claude\channels\wechat\accounts\default.json`。

### 3. 启动 Claude Code + WeChat 通道

```powershell
claude --dangerously-load-development-channels server:wechat
```

### 4. 在微信中发消息

打开微信，找到 ClawBot 对话，发送消息。消息会出现在 Claude Code 终端中，Claude 的回复会自动发回微信。

## 多微信账号支持

支持同一台机器登录多个微信号，每个账号独立运行：

### 登录多个账号

```powershell
bun setup.ts               # 默认账号（default）
bun setup.ts work           # 工作号
bun setup.ts personal       # 个人号
```

每次扫码登录一个微信号，凭据分别保存到：
```
%USERPROFILE%\.claude\channels\wechat\accounts\default.json
%USERPROFILE%\.claude\channels\wechat\accounts\work.json
%USERPROFILE%\.claude\channels\wechat\accounts\personal.json
```

### 查看已登录的账号

```powershell
bun setup.ts --list
```

### 启动指定账号 (PowerShell)

```powershell
# 默认账号（不需要环境变量）
claude --dangerously-load-development-channels server:wechat

# 指定账号（PowerShell 设置环境变量语法）
$env:WECHAT_ACCOUNT='work'; claude --dangerously-load-development-channels server:wechat
```

### 多账号同时运行

在不同 PowerShell 窗口分别启动不同账号，每个账号的消息互不干扰：

```powershell
# 终端 1：默认账号 → vincent 项目
cd C:\Users\you\vincent
claude --dangerously-load-development-channels server:wechat

# 终端 2：工作号 → intern-ai 项目
cd C:\Users\you\intern-ai
$env:WECHAT_ACCOUNT='work'; claude --dangerously-load-development-channels server:wechat

# 终端 3：个人号 → ai-insight 项目
cd C:\Users\you\ai-insight
$env:WECHAT_ACCOUNT='personal'; claude --dangerously-load-development-channels server:wechat
```

每个账号独立维护：凭据、消息同步状态、图片缓存目录。

## 进阶用法

### 恢复已有会话

Claude Code 支持恢复之前的会话，让微信通道接入已有的对话上下文：

```powershell
# 恢复指定 session（通过 session ID）
claude --dangerously-load-development-channels server:wechat --resume <session-id>

# 交互式选择要恢复的 session
claude --dangerously-load-development-channels server:wechat --resume
```

### 跳过权限确认

在可信环境下（如个人电脑），可以跳过所有工具调用的权限确认弹窗，实现全自动化：

```powershell
claude --dangerously-load-development-channels server:wechat --allow-dangerously-skip-permissions
```

### 作为 Teammate 接入

将微信通道作为 teammate 模式运行，与其他 Claude Code 进程协作：

```powershell
claude --dangerously-load-development-channels server:wechat `
  --allow-dangerously-skip-permissions `
  --resume <session-id> `
  --teammate-mode in-process
```

> **注意**: PowerShell 中多行命令使用反引号 `` ` `` 作为续行符（而非 bash 的 `\`）。

### 组合示例

```powershell
# 完整示例：恢复会话 + 跳过权限 + 指定账号 + 指定项目目录
cd D:\my-project
$env:WECHAT_ACCOUNT='work'; claude --dangerously-load-development-channels server:wechat `
  --allow-dangerously-skip-permissions `
  --resume <session-id>
```

### 常用 CLI 参数参考

| 参数 | 说明 |
|------|------|
| `--dangerously-load-development-channels server:wechat` | 加载微信 Channel（必需） |
| `--resume <session-id>` | 恢复指定会话的上下文 |
| `--allow-dangerously-skip-permissions` | 跳过所有权限确认 |
| `--teammate-mode in-process` | Teammate 模式运行 |
| `--model <model>` | 指定模型（如 `opus`、`sonnet`） |
| `--permission-mode bypassPermissions` | 绕过权限模式 |
| `$env:WECHAT_ACCOUNT='<name>'` | PowerShell 环境变量，指定微信账号 |

## 配合 Telegram Bot 使用

Claude Code 官方提供了 Telegram Channel 插件，可以和微信 Channel 同时使用。

### 安装 Telegram 插件

```powershell
claude plugin install telegram@claude-plugins-official
```

### 创建 Telegram Bot

1. 打开 Telegram，搜索 [@BotFather](https://t.me/BotFather)
2. 发送 `/newbot`，输入 bot 名称和用户名
3. 获得 token（格式：`123456789:AAH...`）

### 配置 Bot Token (PowerShell)

```powershell
# 创建配置目录
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\channels\telegram"

# 写入 token
Set-Content -Path "$env:USERPROFILE\.claude\channels\telegram\.env" -Value "TELEGRAM_BOT_TOKEN=你的token"
```

### 启动

```powershell
claude --channels plugin:telegram@claude-plugins-official
```

启动后给 bot 发一条消息获取配对码，在 Claude Code 中输入：
```
/telegram:access pair <配对码>
/telegram:access policy allowlist
```

### 多 Telegram Bot 配置

每个 bot 一个独立目录，通过 `TELEGRAM_STATE_DIR` 环境变量指定：

```
%USERPROFILE%\.claude\channels\
├── telegram\                  # 默认 bot
│   ├── .env                   # TELEGRAM_BOT_TOKEN=token1
│   └── access.json            # {"dmPolicy":"allowlist","allowFrom":["你的用户ID"]}
├── telegram-project-a\        # 项目 A 的 bot
│   ├── .env                   # TELEGRAM_BOT_TOKEN=token2
│   └── access.json
└── telegram-project-b\        # 项目 B 的 bot
    ├── .env                   # TELEGRAM_BOT_TOKEN=token3
    └── access.json
```

access.json 格式：
```json
{
  "dmPolicy": "allowlist",
  "allowFrom": ["你的Telegram用户ID"],
  "groups": {},
  "pending": {}
}
```

> 获取你的 Telegram 用户 ID：给 [@userinfobot](https://t.me/userinfobot) 发消息。

```powershell
# 启动不同 bot 连接不同项目（各开一个 PowerShell 窗口）

# 终端 1：默认 bot
cd D:\project-a
claude --channels plugin:telegram@claude-plugins-official

# 终端 2：项目 B 的 bot
cd D:\project-b
$env:TELEGRAM_STATE_DIR="$env:USERPROFILE\.claude\channels\telegram-project-b"
claude --channels plugin:telegram@claude-plugins-official
```

### 切换 Telegram Bot (PowerShell)

使用 `telegram-switch.ps1` 快速切换：

```powershell
.\telegram-switch.ps1 intern-ai
.\telegram-switch.ps1 ai-insight
```

### 微信 + Telegram 同时运行

```powershell
# 终端 1：微信 Channel
claude --dangerously-load-development-channels server:wechat

# 终端 2：Telegram Channel
claude --channels plugin:telegram@claude-plugins-official
```

两个通道可以连到同一个项目目录的不同 session，互不干扰。

## 文件说明

| 文件 | 说明 |
|------|------|
| `wechat-channel.ts` | MCP Channel 服务器主文件 (Windows 适配) |
| `setup.ts` | 独立的微信扫码登录工具 (Windows 适配) |
| `.mcp.json` | Claude Code MCP 服务器配置 |
| `telegram-switch.ps1` | Telegram Bot 切换脚本 (PowerShell) |

## 技术细节

- **消息接收**: 通过 `ilink/bot/getupdates` 长轮询获取微信消息
- **消息发送**: 通过 `ilink/bot/sendmessage` 发送回复
- **认证**: 使用 `ilink/bot/get_bot_qrcode` QR 码登录获取 Bearer Token
- **协议**: 基于 MCP (Model Context Protocol) 的 Channel 扩展

## Windows 特别注意事项

- 凭据存储在 `%USERPROFILE%\.claude\channels\wechat\` 下（通常为 `C:\Users\<你的用户名>\.claude\channels\wechat\`）
- PowerShell 中设置环境变量使用 `$env:VARIABLE='value'` 语法
- 多行命令使用反引号 `` ` `` 续行（非 bash 的反斜杠 `\`）
- `fs.chmodSync` 在 Windows 上不起作用，但不影响功能
- 路径分隔符由 `path.join` / `path.resolve` 自动处理，无需担心 `/` vs `\`

## 通用注意事项

- 当前为 research preview 阶段，需要使用 `--dangerously-load-development-channels` 标志
- Claude Code 会话关闭后通道也会断开
- 微信 ClawBot 目前仅支持 iOS 最新版
- 每个 ClawBot 只能连接一个 agent 实例

## License

MIT
