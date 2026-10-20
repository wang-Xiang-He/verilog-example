# 12_DeMux1x4_By_1x2E 範例說明：用兩個 1 對 2 解多工器擴充成 1 對 4

## 1. 這個範例在做什麼？

講義第 52 頁：**我們可以使用二個「1×2 的解多工器」來擴充成一個 1×4 的解多工器**。
做法和 [09_Mux4_By_Mux2E](../09_Mux4_By_Mux2E/Mux4x1_By_Mux2to1E_說明.md)（多工器的擴充）一樣，靠**致能（Enable）**讓兩顆輪流工作：

```
                 ┌─────────────┐
  D ──┬─────────►│ D        Y0 │──► Y0
      │          │ DeMux1to2E  │
      │   ┌─────►│ En  (My1) Y1│──► Y1
      │   │      │ Sel         │
      │ Not_S1   └──▲──────────┘
      │   │         │
 S1 ──┼──[NOT]      S0
      │             │
      │          ┌──▼──────────┐
      └─────────►│ D        Y0 │──► Y2
                 │ DeMux1to2E  │
 S1 ────────────►│ En  (My2) Y1│──► Y3
                 │ Sel         │
                 └─────────────┘
```

| S1 | 動作的那顆 | 輸出 | 另一顆 |
|----|-----------|------|-------|
| 0 | My1（Not_S1 = 1） | S0 決定 Y0 = D 或 Y1 = D | My2：Y2 = Y3 = 0 |
| 1 | My2 | S0 決定 Y2 = D 或 Y3 = D | My1：Y0 = Y1 = 0 |

和多工器的擴充不同：解多工器的兩顆各自有自己的輸出，**不需要 OR**，直接接到 Y0~Y3 就好。

---

## 2. 程式說明

### DeMux1to2E.v：具有輸出致能的 1X2 解多工器（講義第 54、55 頁）
```verilog
module DeMux1to2E (
    input      Enable,
    input      Select,
    input      D,
    output reg Y0,
    output reg Y1
);
    always @(*) begin
        if (Enable == 1'b1) begin           // 輸出致能
            if (Select == 1'b0) begin       // 輸出到 Y0
                Y0 = D;   Y1 = 0;
            end
            else if (Select == 1'b1) begin  // 輸出到 Y1
                Y0 = 0;   Y1 = D;
            end
            else begin
                Y0 = 1'b0;  Y1 = 1'b0;      // 輸出為 0
            end
        end
        else begin                          // Enable == 1'b0，不致能
            Y0 = 1'b0;  Y1 = 1'b0;          // 輸出為 0
        end
    end
endmodule
```
- **每一條路徑都給了 Y0、Y1 值**，包括 Select 不確定的那個 else，所以這顆不會產生 latch（和 [10_DeMux1x2](../10_DeMux1x2/DeMux1X2_說明.md) 的 `DeMux1X2_2` 不同）。
- 不致能時輸出 0（講義第 55 頁紅圈：Enable == 1'b0 不致能）。

### DeMux1x4_By_DeMux1to2E.v（講義第 53 頁）
```verilog
`include "DeMux1to2E.v"

module DeMux1x4_By_DeMux1to2E (
    input  S1, S0,
    input  D,
    output Y0, Y1, Y2, Y3
);
    wire Not_S1;                // 內部的接線

    assign Not_S1 = !S1;

    // Port Mapping - in order：DeMux1to2E (Enable, Select, D, Y0, Y1)
    DeMux1to2E My1_DeMux1to2E (Not_S1, S0, D, Y0, Y1);
    DeMux1to2E My2_DeMux1to2E (S1,     S0, D, Y2, Y3);
endmodule
```
- 講義寫 `` `include "DeM1to2E.V" ``，但模組名稱是 `DeMux1to2E`。這裡讓檔名和模組名稱一致，改成 `DeMux1to2E.v`。
- 講義第 53 頁的註解寫「使用二個 2X1 的多工器擴充成一個 4X1 的多工器」，是從 09 範例複製過來沒改。這裡其實是**解**多工器，1X2 → 1X4。
- 講義第 53 頁 `wire Y0, Y1, Y2, Y3;`：輸出接在子模組的輸出埠上，ANSI 寫法的 `output` 預設就是 wire，不用另外宣告。

---

## 3. 預期輸出

```
t=0   S1S0=00 D=1  |  Not_S1=1  ->  Y3..Y0=0001     ← S1=0：My1 動作，S0=0 → Y0
t=10  S1S0=00 D=0  |  Not_S1=1  ->  Y3..Y0=0000
t=20  S1S0=01 D=1  |  Not_S1=1  ->  Y3..Y0=0010     ← S0=1 → Y1
t=30  S1S0=01 D=0  |  Not_S1=1  ->  Y3..Y0=0000
t=40  S1S0=10 D=1  |  Not_S1=0  ->  Y3..Y0=0100     ← S1=1：My2 動作，S0=0 → Y2
t=50  S1S0=10 D=0  |  Not_S1=0  ->  Y3..Y0=0000
t=60  S1S0=11 D=1  |  Not_S1=0  ->  Y3..Y0=1000     ← S0=1 → Y3
t=70  S1S0=11 D=0  |  Not_S1=0  ->  Y3..Y0=0000
checked 8 inputs, errors = 0
```

### 觀察重點
- 結果和 [11_DeMux1x4](../11_DeMux1x4/DeMux1X4_說明.md) 完全一樣；testbench 也拿布林方程式比對 8 種輸入，errors = 0。
- 講義第 57 頁的波形中有不少 x（紅、藍線），是因為講義的 testbench 讓 D 有一段時間是 x；本範例的 D 一直是 0 或 1。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 擴充解多工器 | 兩顆 1×2 + 致能 → 1×4 |
| S1 → 致能 | 一顆接 S1、一顆接 ~S1，保證只有一顆動作 |
| 不需要 OR | 每顆有自己的輸出線 |
| 每條路徑都給值 | 避免 latch |
