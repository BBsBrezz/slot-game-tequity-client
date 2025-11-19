// 測試 AI Code Review 功能
// 這個文件故意包含一些問題，讓 AI 可以審查

// 問題 1: 沒有錯誤處理
function getData() {
  const data = localStorage.getItem('userData');
  return JSON.parse(data);
}

// 問題 2: 不安全的 eval
function processUserInput(input) {
  eval(input);
}

// 問題 3: 變數命名不清楚
function calc(a, b) {
  var x = a + b;
  return x;
}

// 問題 4: 沒有參數驗證
function updateUserScore(score) {
  localStorage.setItem('score', score);
}

// 問題 5: 沒有註釋的複雜邏輯
function processGameResult(result) {
  if (result.win) {
    const bonus = result.amount * 1.5;
    const total = result.balance + bonus;
    return total;
  }
  return result.balance;
}

// 好的示例：有錯誤處理和清晰的命名
function getUserDataSafely() {
  try {
    const userDataString = localStorage.getItem('userData');
    if (!userDataString) {
      return null;
    }
    return JSON.parse(userDataString);
  } catch (error) {
    console.error('Failed to parse user data:', error);
    return null;
  }
}

console.log('AI Review Test File');
