#!/bin/bash
# 切换 Telegram Bot 并启动 Claude Code
# 用法: ./telegram-switch.sh intern-ai
#       ./telegram-switch.sh ai-insight

set -e

TELEGRAM_DIR="$HOME/.claude/channels/telegram"
ACCOUNTS_DIR="$TELEGRAM_DIR/bots"

if [ -z "$1" ]; then
  echo "用法: $0 <bot名称>"
  echo ""
  echo "已保存的 bot:"
  if [ -d "$ACCOUNTS_DIR" ]; then
    for f in "$ACCOUNTS_DIR"/*.env; do
      [ -f "$f" ] && echo "  $(basename "$f" .env)"
    done
  fi
  echo ""
  echo "添加新 bot:"
  echo "  mkdir -p $ACCOUNTS_DIR"
  echo "  echo 'TELEGRAM_BOT_TOKEN=你的token' > $ACCOUNTS_DIR/bot名称.env"
  exit 1
fi

BOT_NAME="$1"
BOT_ENV="$ACCOUNTS_DIR/$BOT_NAME.env"

if [ ! -f "$BOT_ENV" ]; then
  echo "错误: 未找到 bot '$BOT_NAME'"
  echo "请先创建: echo 'TELEGRAM_BOT_TOKEN=xxx' > $BOT_ENV"
  exit 1
fi

# 备份当前 access.json（按 bot 名保存）
if [ -f "$TELEGRAM_DIR/access.json" ]; then
  CURRENT_BOT=$(grep -l "$(cat "$TELEGRAM_DIR/.env" 2>/dev/null)" "$ACCOUNTS_DIR"/*.env 2>/dev/null | head -1 | xargs basename 2>/dev/null | sed 's/\.env$//')
  if [ -n "$CURRENT_BOT" ]; then
    cp "$TELEGRAM_DIR/access.json" "$ACCOUNTS_DIR/$CURRENT_BOT.access.json" 2>/dev/null || true
  fi
fi

# 切换 token
cp "$BOT_ENV" "$TELEGRAM_DIR/.env"
chmod 600 "$TELEGRAM_DIR/.env"

# 恢复目标 bot 的 access.json
if [ -f "$ACCOUNTS_DIR/$BOT_NAME.access.json" ]; then
  cp "$ACCOUNTS_DIR/$BOT_NAME.access.json" "$TELEGRAM_DIR/access.json"
fi

echo "✅ 已切换到 bot: $BOT_NAME"
echo "   Token: $(head -1 "$BOT_ENV" | cut -c1-30)..."
echo ""
echo "启动命令:"
echo "  claude --channels plugin:telegram@claude-plugins-official"
