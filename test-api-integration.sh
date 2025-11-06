#!/bin/bash

echo "================================================"
echo "🎰 Tequity Slot Game API 整合測試"
echo "================================================"
echo ""

# 測試後端 API Server
echo "📡 測試後端 Mock API Server (http://localhost:8080)"
echo "------------------------------------------------"

# 測試 1: 健康檢查
echo "✓ 測試 1: 健康檢查 (GET /health)"
HEALTH=$(curl -s http://localhost:8080/health)
if [ "$HEALTH" == "OK" ]; then
    echo "  ✅ 成功: $HEALTH"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 2: 配置 API
echo "✓ 測試 2: 配置 API (GET /config)"
CONFIG=$(curl -s http://localhost:8080/config)
if echo "$CONFIG" | jq -e '.symbols' > /dev/null 2>&1; then
    echo "  ✅ 成功: 返回了 $(echo $CONFIG | jq -r '.symbols | length') 個符號"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 3: 下注選項
echo "✓ 測試 3: 下注選項 (GET /bets)"
BETS=$(curl -s http://localhost:8080/bets)
if echo "$BETS" | jq -e '.bets.main' > /dev/null 2>&1; then
    echo "  ✅ 成功: 返回了 $(echo $BETS | jq -r '.bets.main.available | length') 個下注選項"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 4: 作弊碼
echo "✓ 測試 4: 作弊碼 (GET /cheats)"
CHEATS=$(curl -s http://localhost:8080/cheats)
if echo "$CHEATS" | jq -e '.main' > /dev/null 2>&1; then
    echo "  ✅ 成功: 返回了 $(echo $CHEATS | jq -r '.main | length') 個作弊碼"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 5: 認證
echo "✓ 測試 5: 認證 (POST /authenticate)"
AUTH=$(curl -s -X POST http://localhost:8080/authenticate \
  -H "Content-Type: application/json" \
  -d '{"operator":"demo","wallet":"demo","key":"test-player-123:1000:eur"}')
SESSION_ID=$(echo $AUTH | jq -r '.sessionId')
if [ ! -z "$SESSION_ID" ] && [ "$SESSION_ID" != "null" ]; then
    echo "  ✅ 成功: SessionID = $SESSION_ID"
    echo "  ✅ 餘額 = $(echo $AUTH | jq -r '.balance') $(echo $AUTH | jq -r '.currency')"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 6: 遊戲玩法
echo "✓ 測試 6: 遊戲玩法 (POST /play)"
PLAY=$(curl -s -X POST http://localhost:8080/play \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\":\"$SESSION_ID\",\"action\":\"main\",\"bet\":5}")
SYMBOLS=$(echo $PLAY | jq -r '.wager.data.symbols | join(", ")')
IS_WIN=$(echo $PLAY | jq -r '.wager.data.isWin')
WIN_AMOUNT=$(echo $PLAY | jq -r '.wager.win')
NEW_BALANCE=$(echo $PLAY | jq -r '.balance')
if [ ! -z "$SYMBOLS" ]; then
    echo "  ✅ 成功: 符號 = [$SYMBOLS]"
    echo "  ✅ 結果 = $([ "$IS_WIN" == "true" ] && echo "贏了 💰" || echo "沒中 😢")"
    echo "  ✅ 獲勝金額 = $WIN_AMOUNT"
    echo "  ✅ 新餘額 = $NEW_BALANCE"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 7: 驗證
echo "✓ 測試 7: 驗證 (POST /validate)"
VALIDATE=$(curl -s -X POST http://localhost:8080/validate \
  -H "Content-Type: application/json" \
  -d '{"action":"main","bet":10}')
IS_VALID=$(echo $VALIDATE | jq -r '.valid')
if [ "$IS_VALID" == "true" ]; then
    echo "  ✅ 成功: 驗證結果 = 有效"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 8: 動作
echo "✓ 測試 8: 動作 (POST /action)"
ACTION=$(curl -s -X POST http://localhost:8080/action \
  -H "Content-Type: application/json" \
  -d '{"next":["main"],"config":{}}')
ACTION_RESULT=$(echo $ACTION | jq -r '.action')
if [ "$ACTION_RESULT" == "main" ]; then
    echo "  ✅ 成功: 返回動作 = $ACTION_RESULT"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 9: 評估 (Portugal regulatory)
echo "✓ 測試 9: 評估 - 葡萄牙合規 (POST /evaluate)"
EVALUATE=$(curl -s -X POST http://localhost:8080/evaluate \
  -H "Content-Type: application/json" \
  -d '{"type":"regulatory-pt","wagers":[{"data":{"symbols":["SYM1","SYM2","SYM3"]},"win":0,"bet":5}]}')
SM_RESULT=$(echo $EVALUATE | jq -r '.sm_result')
if [ ! -z "$SM_RESULT" ] && [ "$SM_RESULT" != "null" ]; then
    echo "  ✅ 成功: sm_result = $SM_RESULT"
    echo "  ✅ descr_ap = $(echo $EVALUATE | jq -r '.descr_ap')"
else
    echo "  ❌ 失敗"
    exit 1
fi

# 測試 10: 校驗碼
echo "✓ 測試 10: 校驗碼 (GET /criticalFileChecksum)"
CHECKSUM=$(curl -s "http://localhost:8080/criticalFileChecksum?criticalFilePath=games/slot-game/index.ts")
CHECKSUM_VALUE=$(echo $CHECKSUM | jq -r '.checksum')
if [ ! -z "$CHECKSUM_VALUE" ] && [ "$CHECKSUM_VALUE" != "null" ]; then
    echo "  ✅ 成功: checksum = $CHECKSUM_VALUE"
else
    echo "  ❌ 失敗"
    exit 1
fi

echo ""
echo "================================================"
echo "🎉 所有 API 測試通過！"
echo "================================================"
echo ""
echo "📊 測試結果摘要:"
echo "  ✅ 健康檢查: OK"
echo "  ✅ 配置 API: OK"
echo "  ✅ 下注選項: OK"
echo "  ✅ 作弊碼: OK"
echo "  ✅ 認證: OK"
echo "  ✅ 遊戲玩法: OK"
echo "  ✅ 驗證: OK"
echo "  ✅ 動作: OK"
echo "  ✅ 評估: OK"
echo "  ✅ 校驗碼: OK"
echo ""
echo "🌐 前端測試頁面:"
echo "  • Connector 版本: http://localhost:3004/index.html"
echo "  • API 測試版本: http://localhost:3004/api-test.html"
echo ""
echo "🔗 後端 API 服務:"
echo "  • Mock API Server: http://localhost:8080"
echo "  • API 文檔: http://localhost:8080/"
echo ""
