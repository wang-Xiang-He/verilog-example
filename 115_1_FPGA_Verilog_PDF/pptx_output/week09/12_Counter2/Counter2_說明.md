# 12_Counter2 範例說明：具重置、載入、致能的 8 位元上數計數器

## 1. 先認識計數器（講義第 40 頁）

| 種類 | 又稱 | 計數方式（3 位元為例） |
|------|------|----------------------|
| **上數計數器**（Count Up Counter） | 正數計數器 | 0、1、2 ... 6、7，再回到 0、1、2 ... |
| **下數計數器**（Count Down Counter） | 倒數計數器 | 7、6、5 ... 1、0，再回到 7、6、5 ... |
| **上數 / 下數計數器**（Up/Down Counter） | 正 / 倒數計數器 | 用一個 Up/Down 控制訊號決定要上數或下數 |

在 Verilog 裡，計數器就是一個暫存器加上 `+ 1`（或 `- 1`）：每個時脈正緣 `Out <= Out + 1`。

---

## 2. 這個範例在做什麼？

具「重置」、「載入」及「致能輸出」控制的 8 位元正緣觸發上數計數器（講義第 41、42 頁）。

```
               ┌────────────────┐
     Reset ───►│ Reset          │    8
      Load ───►│ Load           │───/───► Out
    Enable ───►│ Enable         │
           8   │                │
  Data_In ─/──►│  8 位元上數    │
               │  計數器        │
     Clock ───►│>Clock          │
               └────────────────┘
```

| Clock 正緣時（priority 由高到低） | Out |
|----------------------------------|-----|
| Reset = 1 | 0（清除為 0） |
| Load = 1 | Data_In（載入計數值） |
| Enable = 1 | Out + 1（計數值 +1） |
| 都不是 | 保持 |

---

## 3. 程式說明

### Counter2.v（講義第 41 頁）
```verilog
always @(posedge Clock) begin       // 同步控制
    if (Reset)                      // 重置
        Out <= 8'd0;
    else if (Load)                  // 載入
        Out <= Data_In;             // 從輸入埠 Data_In，載入計數值
    else if (Enable)                // 致能計數
        Out <= Out + 1'b1;          // 計數值 +1
end
```
- `if ... else if ... else if` 的順序就是 priority：Reset（high）> Load > Enable（low）。
- 三個控制都寫在 `always @(posedge Clock)` 裡，都要等正緣才有作用：**同步控制**。
- 沒有最後的 else：都不成立時 Out 沒有被賦值 → **保持**。在時脈觸發的 always 裡，「保持」就是正反器本來的功能，**不會**產生 latch（和組合邏輯不同）。

### 8 位元會繞回 0
8 位元可以表示 2⁸ = 256 種值：0 ~ 255。255 + 1 = 256 = `1_0000_0000`，只留低 8 位元 → **0**（講義第 42 頁的 2⁸ = 256 (0~255)）。

---

## 4. 預期輸出

Reset → 載入 254 → 開始數（講義第 42 頁）。在 Clock 負緣印出：

```
t=0   Reset=1 Load=0 Enable=1 Data_In=254  ->  Out=x
t=10  Reset=0 Load=1 Enable=1 Data_In=254  ->  Out=0      ← t=5 重置
t=20  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=254    ← t=15 載入（Load 優先於 Enable）
t=30  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=255
t=40  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=0      ← 255 + 1 繞回 0
t=50  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=1
t=60  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=2
t=70  Reset=0 Load=0 Enable=1 Data_In=254  ->  Out=3
t=80  Reset=0 Load=0 Enable=0 Data_In=254  ->  Out=4
t=90  Reset=0 Load=0 Enable=0 Data_In=254  ->  Out=4      ← Enable=0：保持
```

### 觀察重點
- 和講義第 42 頁一樣：0 → 254 → 255 → 0 → 1 → 2 ...
- t=10 那一行：Enable 也是 1，但 Reset 優先，所以 Out = 0，不是 +1。
- t=20：Load 和 Enable 都是 1，Load 優先，所以載入 254 而不是 +1。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 計數器 | 暫存器 + 加 1 |
| 優先權 | if ... else if 的順序 |
| 同步控制 | 所有控制都在正緣檢查 |
| 時脈 always 沒有 else | 保持，不會產生 latch |
| n 位元 | 0 ~ 2ⁿ - 1，超過繞回 0 |
