# 17_FreqModN 範例說明：可程式的除 N 器（以及兩個錯誤的修正）

## 1. 這個範例在做什麼？

「除 N 器」：**可程式的除頻器**，將輸入時脈除以 N 後輸出（講義第 55~60 頁）。
N 不是寫死在電路裡，而是從輸入埠 `Data_N` 讀進來，使用者可以隨時改。

```
            ┌───────────┐
 LoadModN ─►│ LoadModN  │
          4 │           │
  Data_N ─/►│  除 N 器  │──► Clock_ModN_Out
            │           │
 Clock_In ─►│>Clock_In  │
            └───────────┘
```

講義的這一段其實包含**兩個問題**，本範例把原版和修正版都做出來，一起量測：

| 模組 | 講義 | 說明 |
|------|------|------|
| `FreqModN` | 第 55~57 頁（原版） | 講義自己指出：「÷6 ⇒ Not ÷5」 |
| `FreqModN_Fix` | 第 58 頁 | 比較對象改成 `ReadIn_Count - 1` |
| `FreqModN_Duty50` | 第 59、60 頁 | 讓輸出 50% duty cycle（照講義寫法） |
| `FreqModN_Duty50_Fix` | 講義「Do it by yourself」 | 50% duty 的修正版 |

---

## 2. 原版：FreqModN（講義第 55、56 頁）

```verilog
reg [3:0] ReadIn_Count, Now_Count;
reg       Is_Count;

always @(posedge Clock_In) begin            // 正緣脈波訊號
    if (!LoadModN) begin                    // 同步負準位載入
        Clock_ModN_Out <= 1'b0;             // 才剛要開始計數，所以輸出為 0
        Now_Count      <= 0;                // 目前計數到 0
        ReadIn_Count   <= Data_N;           // 讀入欲計數的次數（除頻數）
        Is_Count       <= 1'b1;             // 設定正在計數旗標為 1
    end
    else if (Is_Count) begin                // 正在計數
        if (Now_Count == ReadIn_Count) begin        // 如果目前計數的值 = 除頻數
            Clock_ModN_Out <= 1'b1;                 // 已到除頻值，所以輸出為 1
            Now_Count      <= 0;                    // 新設定目前計數值為 0
        end
        else begin
            Clock_ModN_Out <= 1'b0;                 // 尚未計數到除頻數，所以輸出為 0
            Now_Count      <= Now_Count + 1'b1;     // 目前的計數值 +1
        end
    end
end
```
- **LoadModN = 0**：初始化，讀入 N 並開始計數。
- 之後 Now_Count 一直數，數到 N 時輸出一個時脈寬的 1，然後歸零重數。
- `Is_Count` 確保還沒載入過 N 之前不會亂數。

### 問題 1：「÷6 ⇒ Not ÷5」（講義第 57 頁）
Now_Count 從 **0 數到 N**，是 0、1、2、3、4、5 共 **N + 1 = 6** 個時脈。所以 Data_N = 5 時實際上是**除 6**。

### 修正：FreqModN_Fix（講義第 58 頁）
```verilog
if (Now_Count == ReadIn_Count - 1) begin    // 只改這裡：- 1
```
Now_Count 從 0 數到 N - 1，共 N 個時脈 → 真正的除 N。

---

## 3. 50% duty cycle

上面兩個版本的輸出只有 **1 個時脈寬**的脈波（例如除 5：高 1、低 4），duty cycle 只有 20%。
很多場合需要高、低各一半的時脈（duty cycle = 50%），講義第 59 頁給了一個寫法，要大家「Do it by yourself」。

### FreqModN_Duty50（講義第 59 頁的寫法）
```verilog
reg [2:0] Now_Count;
...
if (Now_Count == ReadIn_Count[3:1]) begin   // 數到 N/2
    Clock_ModN_Out <= !Clock_ModN_Out;      // 輸出反相
    Now_Count      <= 0;
end
else begin
    Clock_ModN_Out <= Clock_ModN_Out;       // 保持
    Now_Count      <= Now_Count + 1'b1;
end
```
- `ReadIn_Count[3:1]` = N 右移 1 位 = **N / 2**（無條件捨去）。
- 每數到 N/2 就把輸出反相 → 每半個週期一次反相。

### 問題 2：和問題 1 一樣多數了一格
Now_Count 從 0 數到 N/2，每半個週期是 **N/2 + 1** 個時脈，所以週期 = 2 × (N/2 + 1)：
- N = 5：N/2 = 2 → 半週期 3 → **週期 6**（講義第 60 頁的波形確實是 6 個時脈）
- N = 6：N/2 = 3 → 半週期 4 → **週期 8**

### 修正：FreqModN_Duty50_Fix
```verilog
if (Now_Count == ReadIn_Count[3:1] - 1) begin   // 數到 N/2 - 1
```
每半個週期剛好 N/2 個時脈 → 週期 = N（**N 為偶數時**）。

### N 是奇數時呢？
除 5 要 50% duty，半週期就是 **2.5** 個時脈。只用正緣，最小單位是 1 個時脈，做不出 2.5。
所以 N 為奇數時 Duty50_Fix 的結果是週期 4（除 4）。真正的奇數 50% 除頻器要**同時用正緣和負緣**（各做一個計數器，再把兩個輸出 OR 起來），這超出講義的範圍。

---

## 4. 預期輸出

### (1) N = 5，前 14 個時脈的波形
```
after posedge   : orig Fix Duty50 Duty50_Fix
  t= 30          :   0    0     0       0
  t= 40          :   0    0     0       1
  t= 50          :   0    0     1       1
  t= 60          :   0    0     1       0
  t= 70          :   0    1     1       0
  t= 80          :   1    0     0       1
  t= 90          :   0    0     0       1
  t=100          :   0    0     0       0
  t=110          :   0    0     1       0
  t=120          :   0    1     1       1
  t=130          :   0    0     1       1
  t=140          :   1    0     0       0
  ...
```
- 原版（orig）的 1 出現在 t=80、140：間隔 6 個時脈。
- Fix 的 1 出現在 t=70、120：間隔 5 個時脈。

### (2) 自動量測的週期與高電位時間（單位：Clock_In 的時脈數）
```
N = 5:
  FreqModN            (original)  period = 6 clocks, high = 1 clocks
  FreqModN_Fix        (- 1)       period = 5 clocks, high = 1 clocks
  FreqModN_Duty50     (slide 59)  period = 6 clocks, high = 3 clocks
  FreqModN_Duty50_Fix (N/2 - 1)   period = 4 clocks, high = 2 clocks
N = 6:
  FreqModN            (original)  period = 7 clocks, high = 1 clocks
  FreqModN_Fix        (- 1)       period = 6 clocks, high = 1 clocks
  FreqModN_Duty50     (slide 59)  period = 8 clocks, high = 4 clocks
  FreqModN_Duty50_Fix (N/2 - 1)   period = 6 clocks, high = 3 clocks
```

### 觀察重點
| 模組 | N = 5 | N = 6 | 結論 |
|------|-------|-------|------|
| 原版 | 除 6 | 除 7 | 一律除 N + 1 |
| Fix | **除 5** | **除 6** | 正確，但 duty 只有 1/N |
| Duty50（講義） | 除 6，50% | 除 8，50% | duty 對，頻率錯 |
| Duty50_Fix | 除 4，50% | **除 6，50%** | N 為偶數時完全正確 |

- 這兩個錯誤是同一種：**從 0 開始數到 K，共 K + 1 個時脈**。計數器的「差一」錯誤（off-by-one）非常常見，一定要用模擬確認。
- testbench 用 `generate` 產生 4 組量測電路，自動記錄每個輸出的上升、下降時間，算出週期和高電位時間，不用自己從波形數格子。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 可程式除頻器 | N 從輸入讀入，可以隨時改 |
| 從 0 數到 K | 共 K + 1 個時脈（off-by-one） |
| 除 N | 數到 N - 1 歸零 |
| 50% duty | 每 N/2 個時脈反相一次 |
| 奇數 50% | 只用正緣做不到，需要正、負緣一起用 |
