# Slot Game Tequity Client

這是一個為Tequity平台開發的老虎機遊戲客戶端，基於HTTP API通信，提供現代化的UI體驗。

## 🎮 功能特色

### 用戶界面
- **現代化設計**: 漸變背景、圓角設計、陰影效果
- **響應式布局**: 適配各種螢幕尺寸
- **動畫效果**: 轉輪旋轉動畫、結果過渡效果
- **多語言**: 中文界面支持

### 遊戲功能
- **HTTP API通信**: 基於REST API的穩定通信
- **狀態顯示**: 連接狀態、餘額、遊戲結果
- **下注選擇**: $1-$200多種下注金額
- **結果展示**: 清晰的贏輸提示和金額顯示

### Tequity整合
- **HTTP API**: 使用標準HTTP API端點
- **完整流程**: 認證→資訊→遊戲→餘額管理
- **錯誤處理**: 完善的錯誤提示機制

## 🚀 快速開始

### 安裝依賴
\`\`\`bash
npm install
\`\`\`

### 啟動開發服務器
\`\`\`bash
npm start
\`\`\`

遊戲將在 http://localhost:3004 啟動

### 文件結構
\`\`\`
slot-game-tequity-client/
├── dist/
│   ├── index.html    # Tequity整合版本
│   └── demo.html     # WebSocket演示版本
├── node_modules/     # 依賴包
└── package.json      # 專案配置
\`\`\`

## �� 遊戲說明

### 符號對應
- 🍀 SYM1 (萬能符號)
- 🍎 SYM2
- 🍊 SYM3  
- 🍇 SYM4
- 🍓 SYM5
- 🥝 SYM6

### 贏法規則
1. **三個相同**: 三個相同符號(除🍀) → 2倍贏金
2. **萬能組合**: 兩種符號 + 🍀 → 2倍贏金

## 🔧 配置說明

### Tequity設定
\`\`\`javascript
const settings = {
    game: "slot-game",
    provider: "slot-game-provider",
    operator: "demo",
    wallet: "demo",
    server: "http://localhost:8081",
    // ... 其他配置
};
\`\`\`

### 開發環境
- **Client Port**: 3004
- **Server Port**: 8080 (WebSocket演示)
- **Tequity Server**: 8081 (生產環境)

## 🖥️ 版本說明

### index.html
- 使用Tequity Connector SDK
- 適用於正式整合環境
- 需要完整的Tequity後端服務

### demo.html  
- 使用WebSocket直接連接
- 適用於開發測試
- 連接到原始遊戲服務器

## 🔗 相關專案

- **服務器端**: [slot-game-tequity-server](../slot-game-tequity-server)
- **原始遊戲**: [slot-game-master-original](../slot-game/slot-game-master-original)

---

*提供優質的遊戲體驗，完美整合Tequity平台*
