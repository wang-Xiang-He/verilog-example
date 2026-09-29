# 01_FullAdd 範例說明：1 位元全加器（Full Adder）

## 1. 這個範例在做什麼？

設計一個**1 位元全加器**：把三個 1 位元的數 `a`、`b`、`Carry_In`（前一位來的進位）相加，
輸出「和」`Sum` 與「進位」`Carry_Out`。

全加器是所有加法器的基本積木，下一個範例 [02_FullAdd4](../02_FullAdd4/FullAdd4_說明.md) 就是用 4 個全加器串成 4 位元加法器。

```
   a ────────►┌─────────┐
   b ────────►│ FullAdd │────► Sum
   Carry_In ─►│         │────► Carry_Out
              └─────────┘
```

---

## 2. 檔案說明

| 檔案 | 用途 |
|------|------|
| `FullAdd.v` | 電路本體 |
| `FullAdd_tb.v` | 測試平台（testbench），跑遍 8 種輸入組合 |
| `run.do` | ModelSim 一鍵執行腳本 |

### FullAdd.v
```verilog
assign {Carry_Out, Sum} = a + b + Carry_In;
```

- `a + b + Carry_In` 最大是 1+1+1 = 3，也就是二進位 `11`，需要 **2 個位元**才放得下。
- `{Carry_Out, Sum}` 用**連結運算子** `{ }` 把兩個 1 位元訊號接成一個 2 位元的值：
  - 高位元（MSB）→ `Carry_Out`
  - 低位元（LSB）→ `Sum`
- 所以加出來的 2 位元結果自動拆成「進位」和「和」。

這是**行為 / 資料流層次**的寫法：直接寫算式，由合成工具決定要用哪些邏輯閘。
若用邏輯閘表示，等同於：
```
Sum       = a ^ b ^ Carry_In
Carry_Out = (a & b) | (a & Carry_In) | (b & Carry_In)
```

### FullAdd_tb.v
```verilog
for (i = 0; i < 8; i = i + 1) begin
    {a, b, Carry_In} = i;   // 把 0~7 拆成 3 個位元
    #10;
end
```
- testbench **沒有輸入輸出埠**。
- 要餵給電路的訊號宣告成 `reg`（因為在 `initial` 裡被賦值）；從電路接出來的宣告成 `wire`。
- `{a, b, Carry_In} = i`：用連結運算子把整數 `i` 的低 3 位拆給三個訊號，一行就跑遍所有組合。
- `$monitor`：只要列出的訊號有變化就自動印一行。
- `$stop`：暫停模擬，波形保留。

---

## 3. 預期輸出（真值表）

```
t=0   a=0 b=0 Cin=0  ->  Cout=0 Sum=0
t=10  a=0 b=0 Cin=1  ->  Cout=0 Sum=1
t=20  a=0 b=1 Cin=0  ->  Cout=0 Sum=1
t=30  a=0 b=1 Cin=1  ->  Cout=1 Sum=0
t=40  a=1 b=0 Cin=0  ->  Cout=0 Sum=1
t=50  a=1 b=0 Cin=1  ->  Cout=1 Sum=0
t=60  a=1 b=1 Cin=0  ->  Cout=1 Sum=0
t=70  a=1 b=1 Cin=1  ->  Cout=1 Sum=1
```

### 觀察重點
- 把 `Cout Sum` 當成 2 位元二進位數，剛好等於三個輸入中 1 的個數。
- **Sum = 1**：1 的個數為奇數（這就是 XOR 的特性）。
- **Cout = 1**：至少有兩個 1。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 連結運算子 `{ }` | 把多個訊號接成一個較寬的值，放在等號左邊可以「拆」結果 |
| `assign` | 連續指定，描述組合邏輯 |
| testbench 的 reg / wire | 餵入用 `reg`，接出用 `wire` |
| `for` 迴圈窮舉 | 用 `{a,b,c} = i` 一次跑完所有輸入組合 |
| `$monitor` | 訊號有變化就自動印出 |
