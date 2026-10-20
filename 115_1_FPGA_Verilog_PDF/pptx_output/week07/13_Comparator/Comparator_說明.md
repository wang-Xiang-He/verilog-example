# 13_Comparator 範例說明：同步 8 位元比較器

## 1. 這個範例在做什麼？

數位電路中的**比較器**，通常依據輸入的兩組二進位數的數值大小來作比較（講義第 58 頁）。
比較結果有三種情形：A > B、A = B 及 A < B，**而且這三種情況只有一個為真（True），其餘為偽（False）**。

```
        8
  A ──/──►┌──────────┐──► AGTB   (A Greater Than B)
        8 │  8 位元  │
  B ──/──►│  比較器  │──► AEQB   (A Equal to B)
          │          │
 CLK ────►│>         │──► ALTB   (A Less Than B)
          └──────────┘
```

和 week03 的 [09_Compare](../../week03/09_Compare/Comparator_說明.md) 不同：這次多了一個 **CLK**，結果在時脈正緣才更新（同步）。

---

## 2. 程式說明

### Comparator.v（講義第 59 頁，檔名 Cmp8bit.V）
```verilog
module Comparator #(
    parameter size = 8              // 易於修改
) (
    input  [size-1:0] A,
    input  [size-1:0] B,
    input             CLK,
    output reg        AGTB,
    output reg        AEQB,
    output reg        ALTB
);
    always @(posedge CLK) begin     // Behavioral Model
        AGTB <= (A >  B);
        AEQB <= (A == B);
        ALTB <= (A <  B);
    end
endmodule
```
- `parameter size = 8`：寬度易於修改（week06 的 [04_Param_Hash](../../week06/04_Param_Hash/Adder16_說明.md)）。
- **Behavioral Model**（行為模型）：直接寫 `A > B`，不必自己畫邏輯閘，由合成工具決定電路。
- 講義用阻隔式 `=`，這裡是時脈觸發的 always，改用非阻隔式 `<=`。
- 因為寫在 `always @(posedge CLK)` 裡，三個輸出其實是 **3 個 D 型正反器**：比較的結果要先存起來，到正緣才輸出。

---

## 3. 預期輸出

CLK 週期 20 ns，正緣在 10、30、50 ...；A、B 在 t=5、45、85 改變（兩個正緣中間）。

```
t=0    CLK=0  A=xxxxxxxx(x) B=xxxxxxxx(x)       ->  AGTB=x AEQB=x ALTB=x
t=5    CLK=0  A=11111111(255) B=00000001(1)     ->  AGTB=x AEQB=x ALTB=x     ← A、B 有值了，但結果還沒更新
t=10   CLK=1  A=11111111(255) B=00000001(1)     ->  AGTB=1 AEQB=0 ALTB=0     ← 正緣：A > B
...
t=45   CLK=0  A=00111111(63) B=00111111(63)     ->  AGTB=1 AEQB=0 ALTB=0     ← A = B 了，結果還是舊的
t=50   CLK=1  A=00111111(63) B=00111111(63)     ->  AGTB=0 AEQB=1 ALTB=0     ← 正緣才更新
...
t=85   CLK=0  A=00000011(3) B=10101010(170)     ->  AGTB=0 AEQB=1 ALTB=0
t=90   CLK=1  A=00000011(3) B=10101010(170)     ->  AGTB=0 AEQB=0 ALTB=1     ← A < B
```

### 觀察重點
- 三組數值和講義第 60 頁的波形相同：(11111111, 00000001)、(00111111, 00111111)、(00000011, 10101010)。
- 任何時刻三個輸出**只有一個是 1**。
- **t=5~10、45~50、85~90**：A、B 已經改變，結果卻還是上一次的，要等下一個正緣才更新。

---

## 4. 講義第 60 頁：「不同步，如何改進？」

講義的波形中，比較結果比輸入晚了一段時間出現，看起來「不同步」。原因就是上面說的：結果被存在正反器裡，要等正緣才更新。

改進方法看需求而定：

| 需求 | 做法 |
|------|------|
| 結果要立刻反映輸入 | 拿掉時脈，改成組合邏輯：`assign AGTB = (A > B);`（week03 09_Compare 的寫法） |
| 一定要同步（例如要配合其他同步電路） | 讓 A、B 也在同一個時脈邊緣更新（例如 testbench 在正緣改變 A、B，或 A、B 本身就是暫存器的輸出），輸入和結果就會固定差一個時脈，對齊時脈邊緣 |

在同步電路中，「結果晚一個時脈」是正常的設計（這就是一級管線，pipeline），重點是整個系統要用同一個時脈來對齊。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 比較器 | A > B、A = B、A < B，只有一個為真 |
| 同步輸出 | 寫在 `always @(posedge CLK)` 裡，輸出是正反器 |
| 延遲一個時脈 | 輸入改變後，下一個正緣結果才更新 |
| 行為模型 | 直接寫運算子，由合成工具產生電路 |
