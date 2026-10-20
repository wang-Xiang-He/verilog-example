# 15_Counter6 範例說明：上數 / 下數計數器

## 1. 這個範例在做什麼？

具有「重置」、「載入」、「致能」及「上 / 下數」訊號控制的 8 位元（0~255）正緣觸發上數 / 下數計數器（講義第 51、52 頁）。

```
               ┌────────────────┐
     Reset ───►│ Reset          │
      Load ───►│ Load           │    8
    Enable ───►│ Enable         │───/───► Out
   Up_Down ───►│ Up/Down        │
           8   │  8 位元上數 /  │
  Data_In ─/──►│  下數計數器    │
     Clock ───►│>Clock          │
               └────────────────┘
```

**Priority：Reset > Load > Enable > Up_Down**

| Clock 正緣時 | Out |
|-------------|-----|
| Reset = 1 | 0 |
| Load = 1 | Data_In |
| Enable = 1，Up_Down = 1 | Out + 1（上數） |
| Enable = 1，Up_Down = 0 | Out - 1（下數） |
| Enable = 0 | 保持 |

講義第 40 頁：上數 / 下數計數器通常用一個「上 / 下數」（Up/Down）的控制訊號來決定電路要作上數或下數的計數。

---

## 2. 程式說明

### Counter6.v
```verilog
always @(posedge Clock) begin
    if (Reset)
        Out <= 8'd0;                // 清除為 0
    else if (Load)                  // 載入
        Out <= Data_In;
    else if (Enable) begin          // 致能計數
        if (Up_Down)                // 上數 / 下數
            Out <= Out + 1'b1;      // 計數值 +1，上數
        else
            Out <= Out - 1'b1;      // 計數值 -1，下數
    end
end
```
- 和 [12_Counter2](../12_Counter2/Counter2_說明.md) 幾乎一樣，只是在 Enable 裡再用 Up_Down 分成 +1 和 -1。
- Up_Down 在最內層，**只有 Enable = 1 時才有意義**，所以優先權最低。
- 硬體上相當於一個加法器、一個減法器，再用 **2 對 1 多工器**選一個結果（講義第 40 頁：在上 / 下數計數器內部，可以用一個 2 對 1 的多工器選擇正反器的輸入）。

### 8 位元下數也會繞回
0 - 1 = -1，在 8 位元中是 2 的補數 `1111_1111` = **255**。所以下數時 0 的下一個是 255（和上數時 255 的下一個是 0 對稱）。

---

## 3. 預期輸出

載入 254 → 上數 → 改下數 → Enable = 0 停住。在 Clock 負緣印出：

```
t=0    Reset=1 Load=0 Enable=1 Up_Down=1  ->  Out=x
t=10   Reset=0 Load=1 Enable=1 Up_Down=1  ->  Out=0      ← 重置
t=20   Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=254    ← 載入
t=30   Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=255    ← 上數
t=40   Reset=0 Load=0 Enable=1 Up_Down=1  ->  Out=0      ← 255 + 1 → 0
t=50   Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=1
t=60   Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=0      ← 改下數
t=70   Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=255    ← 0 - 1 → 255
t=80   Reset=0 Load=0 Enable=1 Up_Down=0  ->  Out=254
t=90   Reset=0 Load=0 Enable=0 Up_Down=0  ->  Out=253
t=100  Reset=0 Load=0 Enable=0 Up_Down=0  ->  Out=253    ← Enable = 0：保持
```

### 觀察重點
- 上數經過 255 → 0，下數經過 0 → 255：8 位元的值在 0~255 之間繞圈。
- 正緣在 5、15、25 ...，輸入都在負緣（10、20 ...）改變，每一行印出的 Out 是**前一個正緣**的結果：
  - t=50 那一行 Up_Down 已經是 0，但 Out = 1 是 t=45 正緣**上數**的結果；Up_Down 在 t=50 才改，t=55 的正緣才開始下數。
  - t=90 那一行 Enable 已經是 0，但 Out = 253 是 t=85 正緣**下數**的結果；t=95 的正緣才開始保持。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 上 / 下數 | Up_Down 選 +1 或 -1 |
| 優先權 | Reset > Load > Enable > Up_Down |
| 下數繞回 | 0 - 1 = 255（2 的補數） |
| 硬體 | 加法器 + 減法器 + 2 對 1 多工器 |
