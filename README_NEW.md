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
```bash
npm install
```

### 啟動開發服務器
```bash
npm start
```

遊戲將在 http://localhost:3004 啟動

### 文件結構
```
slot-game-tequity-client/
├── dist/
│   ├── index.html      # 主遊戲頁面 (HTTP API)
│   └── api-test.html   # API測試頁面
├── node_modules/       # 依賴包
└── package.json        # 專案配置
```

## 🎯 遊戲說明

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

### HTTP API 端點
```javascript
// 主要 API 端點
const API_BASE = "http://localhost:8080";
const endpoints = {
    authenticate: "/authenticate",
    info: "/info", 
    play: "/play"
};
```

### 開發環境
- **Client Port**: 3004
- **API Server Port**: 8080
- **通信協議**: HTTP REST API

## 🖥️ 頁面說明

### index.html
- 主要遊戲界面
- 使用HTTP API通信
- 完整的遊戲功能和UI

### api-test.html  
- API測試和調試頁面
- 用於驗證API端點
- 開發和調試工具

## 🔗 相關專案

- **服務器端**: [slot-game-tequity-server](../slot-game-tequity-server)
- **原始遊戲**: [slot-game-master-original](../slot-game/slot-game-master-original)

## 📋 變更歷史

### v2.0 - Remove WebSocket Code
- 移除所有WebSocket相關程式碼
- 專注於HTTP API通信
- 簡化專案結構
- 提升穩定性和可維護性

---

*基於HTTP API的穩定遊戲體驗，完美整合Tequity平台*
