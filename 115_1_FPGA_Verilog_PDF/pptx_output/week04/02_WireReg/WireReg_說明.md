# 02_WireReg 範例說明：wire 與 reg 的使用時機

## 1. 這個範例在做什麼？

講義第 8 頁的規則：

| 寫在哪裡被賦值 | 左邊的訊號要宣告成 |
|----------------|-------------------|
| `assign a = ...;` | **wire** |
| `always` / `initial` 區塊裡的 `a = ...;` | **reg** |

本範例用兩種寫法做同一個 4 位元加法器，再接一個「是否為 0」的偵測電路。

```
  a ─┬─► Add_Reg  ──► z_reg ──► Zero_Detect ──► zero
  b ─┤
     └─► Add_Wire ──► z_wire
```

---

## 2. 檔案說明

### Zero_Detect.v（講義第 7 頁）
```verilog
module Zero_Detect (
    input      [3:0] sum,
    output reg       zero      // 在 always 裡被賦值 → reg
);
    always @(*) begin
        if (sum == 0) zero = 1;
        else          zero = 0;
    end
endmodule
```
- 雖然宣告成 `reg`，但 `always @(*)` 是**組合邏輯**，合成出來只是比較器，**不是暫存器**。
  `reg` 只是語法要求，是不是真的「存」東西要看 always 怎麼觸發（對照 week03 的 04_DFF）。
- `if` 和 `else` 兩邊都有給 `zero` 值，所以不會產生 Latch。

### Add_Reg.v / Add_Wire.v
```verilog
// Add_Reg：always 寫法            // Add_Wire：assign 寫法
output reg [3:0] z                 output [3:0] z
always @(*) z = a + b;             assign z = a + b;
```
兩個合成出來的電路**完全一樣**，只是寫法不同。

### 敏感清單 `@(*)`
講義寫 `always @(sum)`、`always @(a or b)`，要自己列出所有輸入；
Verilog-2001 的 `@(*)` 會自動包含區塊裡讀到的所有訊號，不會漏列。

---

## 3. 預期輸出

```
t=0   a=3 b=4  ->  z_reg=7  z_wire=7   zero=0
t=10  a=0 b=0  ->  z_reg=0  z_wire=0   zero=1
t=20  a=9 b=6  ->  z_reg=15 z_wire=15  zero=0
t=30  a=9 b=7  ->  z_reg=0  z_wire=0   zero=1   ← 9+7=16 溢位
```

### 觀察重點
- `z_reg` 和 `z_wire` 每一行都相同。
- t=30：16 = `1_0000`，4 位元只留 `0000`，所以 zero 也變成 1。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `wire` | 用 `assign` 驅動，或接模組輸出 |
| `reg` | 在 `always` / `initial` 裡被賦值 |
| reg ≠ 暫存器 | `always @(*)` 的 reg 合成為組合邏輯 |
| `@(*)` | 自動敏感清單，避免漏列訊號 |
| 預設型態 | 沒寫型態的埠 / 訊號預設為 wire |
