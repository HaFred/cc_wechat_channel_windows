# Claude Code WeChat Channel

将微信消息桥接到 Claude Code 会话的 Channel 插件。

基于微信官方 ClawBot ilink API（与 `@tencent-weixin/openclaw-weixin` 使用相同协议），让你在微信中直接与 Claude Code 对话。

## 工作原理

```
微信 (iOS) → WeChat ClawBot → ilink API → [本插件] → Claude Code Session
                                                  ↕
Claude Code ← MCP Channel Protocol ← wechat_reply tool
```

## 前置要求

- [Bun](https://bun.sh) >= 1.0（见下方介绍）
- [Claude Code](https://claude.com/claude-code) >= 2.1.80
- claude.ai 账号登录（不支持 API key）
- 微信 iOS 最新版（需支持 ClawBot 插件）

### 关于 Bun

[Bun](https://bun.sh) 是新一代 JavaScript/TypeScript 运行时，本项目选择 Bun 的原因：

- **原生 TypeScript**：直接运行 `.ts` 文件，无需 `tsc` 编译或 `tsx` 转译
- **极快的启动速度**：冷启动比 Node.js 快 4 倍，适合 Channel 插件频繁重启场景
- **内置包管理器**：`bun install` 比 `npm install` 快 10-25 倍
- **兼容 Node.js API**：`fs`、`path`、`crypto` 等模块完全兼容，无需改代码

安装 Bun：

```bash
# macOS / Linux
curl -fsSL https://bun.sh/install | bash

# 或通过 npm 安装
npm install -g bun

# 验证
bun --version
```

> 如果你的环境无法安装 Bun，也可以用 `npx tsx` 替代 `bun` 来运行 `.ts` 文件，但性能会有差异。

## 最简上手方式

把本仓库交给 Claude Code，让它帮你完成全部配置：

```bash
git clone https://github.com/vansin/claude-code-wechat-channel.git
cd claude-code-wechat-channel
claude
```

进入 Claude Code 后直接说：

> 帮我配置微信 Channel，按照 README 的步骤来

Claude Code 会自动读取 README，帮你安装依赖、引导扫码登录、配置 MCP，全程不需要你手动操作。

---

## 手动配置（快速开始）

### 1. 安装依赖

```bash
git clone https://github.com/vansin/claude-code-wechat-channel.git
cd claude-code-wechat-channel
bun install
```

### 2. 微信扫码登录

```bash
bun setup.ts
```

终端会显示二维码，用微信扫描并确认。凭据保存到 `~/.claude/channels/wechat/account.json`。

### 3. 启动 Claude Code + WeChat 通道

```bash
cd claude-code-wechat-channel
claude --dangerously-load-development-channels server:wechat
```

### 4. 在微信中发消息

打开微信，找到 ClawBot 对话，发送消息。消息会出现在 Claude Code 终端中，Claude 的回复会自动发回微信。

## 文件说明

| 文件 | 说明 |
|------|------|
| `wechat-channel.ts` | MCP Channel 服务器主文件 |
| `setup.ts` | 独立的微信扫码登录工具 |
| `.mcp.json` | Claude Code MCP 服务器配置 |

## 技术细节

- **消息接收**: 通过 `ilink/bot/getupdates` 长轮询获取微信消息
- **消息发送**: 通过 `ilink/bot/sendmessage` 发送回复
- **认证**: 使用 `ilink/bot/get_bot_qrcode` QR 码登录获取 Bearer Token
- **协议**: 基于 MCP (Model Context Protocol) 的 Channel 扩展

## 注意事项

- 当前为 research preview 阶段，需要使用 `--dangerously-load-development-channels` 标志
- Claude Code 会话关闭后通道也会断开
- 微信 ClawBot 目前仅支持 iOS 最新版
- 每个 ClawBot 只能连接一个 agent 实例

## License

MIT
