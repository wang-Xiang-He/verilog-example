# 13_Counter3 範例說明：兩個 always 區塊的計數器（Carry_In / Carry_Out）

## 1. 這個範例在做什麼？

具「載入」及「進位」訊號的 8 位元（0~255）正緣觸發上數計數器（講義第 43~45 頁）。
這次把計數器拆成**兩個 always 區塊**，這是設計循序電路的標準手法：

```
                    ┌──────────────────────────┐
  Data_In ─────────►│  第二個 Block（組合邏輯）│
  Load ────────────►│  {Carry_Out, Pre_Out}    │──► Carry_Out
  Carry_In ────────►│      = Out + Carry_In    │
            ┌──────►│  if (Load) Pre_Out=Data_In│
            │       └────────────┬─────────────┘
            │                    │ Pre_Out（下一個狀態）
            │       ┌────────────▼─────────────┐
            │       │  第一個 Block（暫存器）   │
            └───────┤  Clock 正緣：Out = Pre_Out│──► Out
                    └──────────────────────────┘
```

| 區塊 | 類型 | 工作 |
|------|------|------|
| 第一個 Block | 時脈觸發（暫存器） | Clock 正緣時，把 Pre_Out 的值傳至 Out |
| 第二個 Block | 組合邏輯 | 計算下一個狀態 Pre_Out，以及 Carry_Out |

- **Carry_In = 1 才計數**，相當於致能；Carry_In = 0 時 Pre_Out = Out，計數器停住。
- **Carry_Out**：Out + Carry_In 超過 255 時為 1，可以接到下一顆計數器的 Carry_In，串成 16 位元計數器。
- 講義第 43 頁方塊圖的 Reset 被打了叉：這個計數器沒有重置，靠 Load 給初值。

---

## 2. 程式說明

### Counter3.v（講義第 43、44 頁）
```verilog
reg [7:0] Pre_Out;                  // 下一個狀態

// 第一個 Block：產生一個 8 位元的暫存器
always @(posedge Clock)             // 當 Clock 正緣觸發時
    Out <= Pre_Out;                 // 更新 Out 值

// 第二個 Block：計算下一個計數器的狀態及 Carry_Out 的值
always @(*) begin                   // 講義：always @(Load or Data_In or Carry_In or Out)
    {Carry_Out, Pre_Out} = Out + Carry_In;
    if (Load)                       // 載入
        Pre_Out = Data_In;
end
```
- `{Carry_Out, Pre_Out} = Out + Carry_In;`：9 位元的結果，最高位是進位（week03 [01_FullAdd](../../week03/01_FullAdd/FullAdd_說明.md) 的寫法）。
- **基於「效能」上的考量，我們不希望 Load 訊號影響 Carry_Out**（講義第 44 頁）：所以 `if (Load)` 只改 Pre_Out，不改 Carry_Out。
- 組合邏輯的 always 用**阻隔式 `=`**：第 2 行要「覆蓋」第 1 行算出的 Pre_Out，必須照順序執行。
- 時脈的 always 用 `<=`，組合的 always 用 `=`：這是兩個 always 分開寫的好處，規則很清楚。

---

## 3. 預期輸出

先載入 11111110（254），然後 Carry_In = 1 開始數（講義第 45 頁）：

```
t=0   Load=1 Carry_In=1 Data_In=11111110  ->  Out=xxxxxxxx (x)    Pre_Out=11111110  Carry_Out=x
t=10  Load=0 Carry_In=1 Data_In=11111110  ->  Out=11111110 (254)  Pre_Out=11111111  Carry_Out=0
t=20  Load=0 Carry_In=1 Data_In=11111110  ->  Out=11111111 (255)  Pre_Out=00000000  Carry_Out=1   ← Out=255：下一個正緣會溢位
t=30  Load=0 Carry_In=1 Data_In=11111110  ->  Out=00000000 (0)    Pre_Out=00000001  Carry_Out=0
t=40  Load=0 Carry_In=1 Data_In=11111110  ->  Out=00000001 (1)    Pre_Out=00000010  Carry_Out=0
t=50  Load=0 Carry_In=0 Data_In=11111110  ->  Out=00000010 (2)    Pre_Out=00000010  Carry_Out=0   ← Carry_In=0：停住
t=60  Load=0 Carry_In=0 Data_In=11111110  ->  Out=00000010 (2)    Pre_Out=00000010  Carry_Out=0
```

### 觀察重點
- Pre_Out 永遠比 Out「領先一步」：它是下一個正緣要存進去的值。
- 講義第 45 頁在 Carry_Out 上標了「**Wrong?**」：Carry_Out 在 **Out = 255 的那一個時脈**就是 1，而不是 Out 變成 0 的時候。
  這是正確的：Carry_Out 是組合邏輯，表示「**目前的值加 Carry_In 會溢位**，下一個正緣會進位歸零」。
  要串接下一顆計數器時，下一顆就是要在**同一個正緣**一起加 1，所以必須提前知道。
- t=0：Out 還沒有值（x），所以 Carry_Out 也是 x；Pre_Out 因為 Load = 1 已經是 Data_In。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 兩個 always | 時脈的存狀態，組合的算下一個狀態 |
| Pre_Out | 下一個狀態（next state） |
| Carry_In | 進位輸入 = 計數致能 |
| Carry_Out | 組合邏輯，提前一個時脈指出即將溢位 |
| `=` 與 `<=` | 組合 always 用 `=`，時脈 always 用 `<=` |
