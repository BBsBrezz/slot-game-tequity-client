# Tequity 標準多步驟遊戲實作說明

## 概述

本專案已完成從自定義 `/bonus_spin` 端點遷移到標準 Tequity 多步驟遊戲流程。

## 標準 Tequity 做法 vs 舊做法

### ❌ 舊做法（自定義端點）

```javascript
// 第一步
POST /play { sessionId, action: 'main', bet }
→ Response: { wager: { next: ['bonus_spin'] }, roundId }

// 第二步（自定義端點）
POST /bonus_spin { sessionId, roundId, bet }
→ Response: { wager: { next: [] }, totalWin }
```

### ✅ 新做法（標準 Tequity）

```javascript
// 第一步
POST /play { sessionId, action: 'main', bet }
→ Response: { wager: { next: ['bonus_spin'] }, roundId }

// 第二步（同一個端點，不同 action）
POST /play { sessionId, action: 'bonus_spin', roundId, bet }
→ Response: { wager: { next: [] }, totalWin }
```

## 後端修改

### 1. 整合 playHandler

**檔案**: `mock-api-server.js`

```javascript
const playHandler = (req, res) => {
    const { sessionId, action, bet, cheat, roundId } = req.body;

    // 檢查是否為 bonus_spin action
    if (action === 'bonus_spin') {
        // 處理 Bonus Spin 邏輯
        const round = rounds.get(roundId);
        // ... bonus spin 實作
        return res.json({ wager, roundId, balance, totalWin });
    }

    // 主遊戲邏輯 (action === 'main')
    // ... 主遊戲實作
    res.json({ wager, roundId, balance });
};
```

### 2. 移除獨立端點

- ✅ 移除 `bonusSpinHandler` 函數
- ✅ 移除所有 `app.post('/bonus_spin', ...)` 路由註冊

## 前端修改

### 檔案: `api-test.html`

**修改前**:
```javascript
const bonusResult = await makeHTTPRequest('/bonus_spin', {
    sessionId: currentSessionId,
    roundId: result.roundId,
    bet: betAmount
});
```

**修改後**:
```javascript
const bonusResult = await makeHTTPRequest('/play', {
    sessionId: currentSessionId,
    action: 'bonus_spin',  // 關鍵：指定 action
    roundId: result.roundId,
    bet: betAmount
});
```

## 測試流程

### 1. 命令列測試

```bash
# 認證
SESSION_ID=$(curl -s -X POST http://localhost:8080/authenticate \
  -H "Content-Type: application/json" \
  -d '{"operator":"demo","wallet":"demo","key":"test:1000:usd"}' \
  | jq -r '.sessionId')

# 第一步：BigWin
RESULT=$(curl -s -X POST http://localhost:8080/play \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\":\"$SESSION_ID\",\"action\":\"main\",\"bet\":10,\"cheat\":\"bigWin\"}")

ROUND_ID=$(echo "$RESULT" | jq -r '.roundId')

# 第二步：Bonus Spin（標準做法）
curl -s -X POST http://localhost:8080/play \
  -H "Content-Type: application/json" \
  -d "{\"sessionId\":\"$SESSION_ID\",\"action\":\"bonus_spin\",\"roundId\":\"$ROUND_ID\",\"bet\":10}"
```

### 2. 瀏覽器測試

#### 方法 A: 使用 test-bonus-spin.html

1. 開啟 `http://localhost:3004/test-bonus-spin.html`
2. 點擊「測試 BigWin 流程」按鈕
3. 觀察日誌輸出，確認自動執行 bonus spin

#### 方法 B: 使用 api-test.html

1. 開啟 `http://localhost:3004/api-test.html`
2. 點擊「測試認證」
3. 點擊「測試作弊」切換到 bigWin 模式
4. 點擊「模擬旋轉」按鈕
5. 觀察：
   - 第一次旋轉顯示 BigWin
   - 2 秒後自動執行 Bonus Spin
   - 如果 Bonus Spin 中獎，顯示 SuperWin

## 遊戲流程

### BigWin → Bonus Spin → SuperWin 流程

```
用戶操作：點擊「模擬旋轉」（啟用 bigWin 作弊碼）
    ↓
POST /play { action: 'main', cheat: 'bigWin', bet: 10 }
    ↓
回應：{ wager: { win: 100, next: ['bonus_spin'] }, roundId }
    ↓
前端檢測 next: ['bonus_spin']
    ↓
等待 2 秒（視覺效果）
    ↓
POST /play { action: 'bonus_spin', roundId, bet: 10 }
    ↓
回應：{
    wager: { win: 500, winType: 'super_win', next: [] },
    totalWin: 600,  // 100 + 500
    balance: 更新後的餘額
}
    ↓
顯示 SuperWin 結果
```

### 獲勝倍率

- **win**: 2x 倍率
- **bigWin**: 10x 倍率 + 觸發 Bonus Spin
- **superWin** (透過 Bonus Spin): 50x 倍率

### Bonus Spin 觸發條件

1. **使用 bigWin 作弊碼**：100% 觸發
2. **正常遊戲中獎**：10% 機率升級為 bigWin 並觸發 Bonus Spin

### Bonus Spin 特性

- **免費旋轉**：不扣除玩家下注金額
- **SuperWin 機制**：如果 Bonus Spin 中獎，自動升級為 SuperWin (50x)
- **回合完成**：Bonus Spin 執行後，回合標記為完成 (`finished: true`)
- **總獎金計算**：`totalWin` 包含主遊戲 + Bonus Spin 的累計獎金

## 符合的 Tequity 規範

### 文件參考

根據 `Tequity整合完整指南.md` 第 50 行：

> **POST /api/games/{game}/action** (可選，用於多步驟遊戲)
> 決定下一個動作

### 標準多步驟遊戲流程

1. **POST /play** 返回 `next` 陣列表示後續動作
2. **客戶端檢測 `next`**，判斷是否需要後續步驟
3. **再次調用 /play** 並傳遞 `action` 參數執行後續步驟
4. **回合完成** 時返回 `next: []`

### Response 格式

```javascript
{
  "wager": {
    "data": { "symbols": [...], "isWin": true, "winType": "big_win" },
    "win": 100,
    "next": ["bonus_spin"]  // 後續動作
  },
  "roundId": "uuid",
  "balance": 1090,
  "action": "main"
}
```

## 驗證成功標準

### 後端

✅ `/bonus_spin` 端點已移除
✅ `playHandler` 處理所有 action 類型
✅ `action === 'bonus_spin'` 執行 bonus spin 邏輯
✅ 回合狀態正確管理 (`finished`, `pendingActions`)
✅ 累計獎金正確計算 (`totalWin`)

### 前端

✅ 檢測 `wager.next` 陣列
✅ 自動觸發 bonus spin（2 秒延遲）
✅ 使用標準 `/play` 端點 + `action: 'bonus_spin'`
✅ 傳遞正確的 `roundId` 參數
✅ 視覺效果完整（旋轉動畫、結果顯示）

### 測試結果

從後端日誌可以確認：

```
Play request: { sessionId, action: 'main', cheat: 'bigWin', bet: 5 }
🎰 使用作弊碼: bigWin, 符號: SYM2,SYM2,SYM2, 獲勝金額: 50

Play request: { sessionId, action: 'bonus_spin', roundId, bet: 5 }
🎆 觸發 SuperWin！超級大獎: 250
```

✅ **完全符合 Tequity 標準多步驟遊戲流程！**

## 故障排除

### 問題：按下「測試作弊」後，「模擬旋轉」沒有自動 bonus spin

**解決方案**：

1. **強制重新載入頁面**：Ctrl+Shift+R (Windows) 或 Cmd+Shift+R (Mac)
2. **檢查瀏覽器 Console**：按 F12 打開開發者工具，查看是否有 JavaScript 錯誤
3. **確認後端運行**：訪問 `http://localhost:8080/health` 應返回 "OK"
4. **查看後端日誌**：確認是否有收到兩次 `/play` 請求

### 問題：Bonus Spin 失敗

**檢查項目**：

1. 確認 `roundId` 有正確傳遞
2. 檢查 `action` 參數是否為 `'bonus_spin'`
3. 查看後端日誌確認請求內容

## 相關檔案

### Backend
- `/Users/harry_lu/WorkingProject/slot-game-tequity-server/mock-api-server.js`
- `/Users/harry_lu/WorkingProject/slot-game-tequity-server/mock-api-server-enhanced.js` (開發版)

### Frontend
- `/Users/harry_lu/WorkingProject/slot-game-tequity-client/dist/api-test.html`
- `/Users/harry_lu/WorkingProject/slot-game-tequity-client/dist/test-bonus-spin.html` (測試頁面)

### Documentation
- `/Users/harry_lu/Downloads/gemmis_tequity/Tequity整合完整指南.md`
- `/Users/harry_lu/WorkingProject/slot-game-tequity-client/INTEGRATION_COMPLETE.md`

## 完成日期

2025-11-07

## 狀態

✅ **已完成標準 Tequity 多步驟遊戲流程實作**
