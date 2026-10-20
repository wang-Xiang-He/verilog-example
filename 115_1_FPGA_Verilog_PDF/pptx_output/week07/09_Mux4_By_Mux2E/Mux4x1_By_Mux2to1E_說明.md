# 09_Mux4_By_Mux2E 範例說明：用兩個 2 對 1 多工器擴充成 4 對 1 多工器

## 1. 這個範例在做什麼？

講義第 40 頁：**使用二個 2X1 的多工器擴充成一個 4X1 的多工器**。
關鍵是給 2 對 1 多工器加上**致能（Enable）**腳，讓兩顆輪流工作：

```
         I0 ──►┌───────────┐
         I1 ──►│ Mux2to1E  │──► Out0 ──┐
               │  (My1)    │           │
    ┌── Not_S1►│ E       S │◄── S0     │
    │          └───────────┘          OR ──► Out
 S1 ┤                                  │
    │    I2 ──►┌───────────┐           │
    │    I3 ──►│ Mux2to1E  │──► Out1 ──┘
    │          │  (My2)    │
    └───── S1 ►│ E       S │◄── S0
               └───────────┘
```

| S1 | 誰動作 | 誰不動作（輸出 0） | Out |
|----|-------|-------------------|-----|
| 0 | 上面那顆（Not_S1 = 1），由 S0 選 I0 或 I1 | 下面那顆 | Out0 |
| 1 | 下面那顆，由 S0 選 I2 或 I3 | 上面那顆 | Out1 |

兩顆的輸出做 **OR**：不動作的那顆是 0，`0 | X = X`，所以 OR 的結果就是動作的那顆的輸出。

---

## 2. 程式說明

### Mux2to1E.v：具有輸出致能的 2X1 多工器（講義第 42 頁）
```verilog
module Mux2to1E (
    input      Enable,
    input      Select,
    input      I0,
    input      I1,
    output reg Y
);
    always @(*) begin
        if (Enable == 1'b1) begin       // 輸出致能
            case (Select)
                1'b0:    Y = I0;
                1'b1:    Y = I1;
                default: Y = 1'bx;
            endcase
        end
        else begin
            Y = 1'b0;   // 講義寫 Y = 1'bx;，並註明「有誤？修正為 0 即可」
        end
    end
endmodule
```

### Mux4x1_By_Mux2to1E.v（講義第 41 頁）
```verilog
`include "Mux2to1E.v"           // 編譯命令引用 Mux2to1E.v

module Mux4x1_By_Mux2to1E (
    input      S1, S0,
    input      I3, I2, I1, I0,
    output reg Out
);
    wire Out0, Out1;
    wire Not_S1;                // 內部的接線

    assign Not_S1 = !S1;

    // Port Mapping - in order：Mux2to1E (Enable, Select, I0, I1, Y)
    Mux2to1E My1_Mux2to1 (Not_S1, S0, I0, I1, Out0);
    Mux2to1E My2_Mux2to1 (S1,     S0, I2, I3, Out1);

    always @(*) begin           // 講義：always @(Out0 or Out1)
        Out = Out0 | Out1;      // 將 2X1 多工器的輸出訊號作 OR 的連接
    end
endmodule
```
- `` `include `` 的用法見 week06 [01_Include](../../week06/01_Include/FullAdd4_說明.md)：vlog 只編譯 `Mux4x1_By_Mux2to1E.v`，`Mux2to1E.v` 不要列。
- 講義寫 `` `include "Mux2to1E.V" ``（大寫 V）。Windows 不分大小寫，但最好和實際檔名完全一樣。
- 用 `Not_S1 = !S1` 產生反相：S1 一條線同時控制兩顆，一顆接正相、一顆接反相，**保證只有一顆在工作**。

---

## 3. 講義第 42 頁：「有誤？修正為 0 即可」

講義原本寫：不致能時 `Y = 1'bx`。把它改回 `1'bx` 實際模擬：
```
t=0   S1S0=00  I3..I0=0101  |  Out0=1 Out1=x  ->  Out=1     ← 1 | x = 1，剛好對
t=10  S1S0=01  I3..I0=0101  |  Out0=0 Out1=x  ->  Out=x     ← 0 | x = x，錯！
t=20  S1S0=10  I3..I0=0101  |  Out0=x Out1=1  ->  Out=1
t=30  S1S0=11  I3..I0=0101  |  Out0=x Out1=0  ->  Out=x
...
checked 64 inputs, errors = 32
```
講義第 43 頁的結論：

| OR 運算 | 結果 |
|--------|------|
| x \| 1 | 1 |
| x \| 0 | **x** |

被選到的資料是 1 時剛好對，是 0 時就變成 x，64 種輸入錯了一半（32 個）。
不動作的那顆必須輸出 **0**（OR 的「不影響」值），才能讓 OR 的結果等於另一顆。

> 如果最後是用 AND 來合併，不動作的那顆就要輸出 1。

---

## 4. 預期輸出（修正為 0 之後）

```
t=0   S1S0=00  I3..I0=0101  |  Out0=1 Out1=0  ->  Out=1     ← S1=0：上面那顆選 I0
t=10  S1S0=01  I3..I0=0101  |  Out0=0 Out1=0  ->  Out=0     ← 選 I1
t=20  S1S0=10  I3..I0=0101  |  Out0=0 Out1=1  ->  Out=1     ← S1=1：下面那顆選 I2
t=30  S1S0=11  I3..I0=0101  |  Out0=0 Out1=0  ->  Out=0     ← 選 I3
t=40  S1S0=00  I3..I0=1010  |  Out0=0 Out1=0  ->  Out=0
t=50  S1S0=01  I3..I0=1010  |  Out0=1 Out1=0  ->  Out=1
t=60  S1S0=10  I3..I0=1010  |  Out0=0 Out1=0  ->  Out=0
t=70  S1S0=11  I3..I0=1010  |  Out0=0 Out1=1  ->  Out=1
checked 64 inputs, errors = 0
```

### 觀察重點
- S1 = 0 時 Out1 一直是 0，S1 = 1 時 Out0 一直是 0，不動作的那顆不會干擾。
- 結果和 [08_Mux4to1](../08_Mux4to1/Mux4to1_1_說明.md) 的 case 寫法完全一樣，64 種輸入 errors = 0。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 擴充 | 用小的多工器 + 致能組成大的 |
| 致能（Enable） | 不致能時輸出固定值，讓出位置給另一顆 |
| OR 合併 | 不動作的那顆要輸出 0 |
| x \| 0 = x | 不致能輸出 x 會讓結果錯一半 |
| `` `include `` | 引用另一個檔案的模組 |
