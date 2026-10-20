# 01_Mux4_UDP 範例說明：自定組合邏輯 UDP（4 對 1 多工器，範例練習 8-001）

## 1. 這個範例在做什麼？

Verilog 內建 `and`、`or`、`not` 這些邏輯閘（primitive）。除了內建的，我們也可以**用真值表自己定義一個邏輯閘**，
叫做 **UDP（User-Defined Primitive，使用者自定基本元件）**（講義第 1 頁「自定邏輯的設計技術」）。

本範例（講義第 1~6 頁）：
1. 先用真值表定義一個 2 對 1 多工器 `mux2_1pr`
2. 再用 **3 顆** `mux2_1pr` 組成 4 對 1 多工器 `mux4_1pr`

```
DI[0] ─┐
        mux2_1pr2 ── Y0 ─┐
DI[1] ─┘   S=Sel[0]      │
                          mux2_1pr0 ── OUT
DI[2] ─┐                 │   S=Sel[1]
        mux2_1pr1 ── Y1 ─┘
DI[3] ─┘   S=Sel[0]
```

| Sel | OUT |
|-----|-----|
| 00 | DI[0] |
| 01 | DI[1] |
| 10 | DI[2] |
| 11 | DI[3] |

---

## 2. UDP 的寫法

### mux2_1pr.v（講義第 3 頁）
```verilog
primitive mux2_1pr (Y, I1, I0, S);
    output Y;
    input  I1, I0;
    input  S;

    table
    //  I1  I0   S  :  Y        // Look-up table
         ?   0   0  :  0 ;      // S = 0：輸出 I0
         ?   1   0  :  1 ;
         0   ?   1  :  0 ;      // S = 1：輸出 I1
         1   ?   1  :  1 ;
         ?   ?   x  :  x ;      // S 不確定 → 輸出不確定
    endtable
endprimitive
```

### UDP 的規則
| 規則 | 說明 |
|------|------|
| 寫在哪裡 | `primitive ... endprimitive`，寫在 `module` 的**外面** |
| 輸出 | **只能有 1 個**，而且一定是第 1 個埠 |
| 輸入 | 可以很多個，但每個都只能是 **1 位元**（不能是向量） |
| 真值表 | `<輸入1> <輸入2> ... : <輸出> ;` |
| 輸入順序 | 必須和**埠宣告的順序**一樣（這裡是 `I1 I0 S`），否則輸出會錯（講義第 1 頁的提醒） |
| 可用符號 | `0`、`1`、`x`，以及 `?`（= 0、1、x 任何一個） |
| 沒列出的組合 | 輸出一律是 **x** |

`?` 讓真值表變短：`? 0 0 : 0` 表示「S = 0、I0 = 0 時，不管 I1 是什麼，輸出都是 0」，一行抵三行。

---

## 3. 使用 UDP

### mux4_1pr.v（講義第 4 頁）
```verilog
module mux4_1pr (
    output       OUT,
    input  [3:0] DI,
    input  [1:0] Sel
);
    wire Y1, Y0;

    mux2_1pr mux2_1pr1 (Y1,  DI[3], DI[2], Sel[0]);
    mux2_1pr mux2_1pr2 (Y0,  DI[1], DI[0], Sel[0]);
    mux2_1pr mux2_1pr0 (OUT, Y1,    Y0,    Sel[1]);
endmodule
```

### UDP 只能依順序連接
講義第 5 頁：**Primitive 使用必須 call by order，call by name 不可以**。

但講義第 4 頁卻寫成依名稱 `mux2_1pr mux2_1pr1(.Y(Y1), .I1(DI[3]), ...)`。實際用 ModelSim 試：
- `vlog` 編譯**會過**
- `vsim` 載入模擬時出錯：
```
** Fatal: (vsim-3367) UDP ports cannot be connected by name.This is not LRM complaint behavior.
```
所以這裡用第 5 頁的依順序寫法。內建的 `and`、`or` 也是一樣，只能依順序。

> 一般的 `module`（例如 `mux4_1pr`）就可以依名稱連接：testbench 裡寫的是 `mux4_1pr uut (.OUT(OUT), .DI(DI), .Sel(Sel));`。

---

## 4. 預期輸出

測試數值和講義第 5 頁相同，DI 故意放 x：

```
t=0   Sel=00  DI[3:0]=0000  ->  OUT=0
t=10  Sel=00  DI[3:0]=xx00  ->  OUT=0     ← 看 DI[0] = 0
t=20  Sel=00  DI[3:0]=xx01  ->  OUT=1     ← DI[0] = 1
t=30  Sel=00  DI[3:0]=00xx  ->  OUT=x     ← DI[0] = x
t=40  Sel=00  DI[3:0]=01xx  ->  OUT=x
t=50  Sel=10  DI[3:0]=xx00  ->  OUT=x     ← 改看 DI[2] = x
t=60  Sel=10  DI[3:0]=xx01  ->  OUT=x
t=70  Sel=10  DI[3:0]=00xx  ->  OUT=0     ← DI[2] = 0
t=80  Sel=10  DI[3:0]=01xx  ->  OUT=1     ← DI[2] = 1
t=90  Sel=10  DI[3:0]=xxxx  ->  OUT=x
```

### 觀察重點
- 和講義第 6 頁一樣：Sel = 00 時 OUT = DI[0] = 0、1、X、X；Sel = 10 時 OUT = DI[2] = X、X、0、1、X。
- **沒被選到的位元就算是 x 也不影響輸出**：t=10 的 DI[3:2] 是 xx，但 OUT = 0。這是真值表裡 `?` 的作用。
- 講義用 `` `timescale 1ps/1ps ``、每 `#1` 換一組；這裡改成 1ns、每 `#10` 換一組，數字比較好讀，結果相同。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| UDP | 用真值表自己定義邏輯閘：`primitive ... table ... endtable endprimitive` |
| 1 個輸出 | 輸出只能 1 個、1 位元，放在第 1 個埠 |
| 輸入順序 | 真值表的欄位順序 = 埠宣告順序 |
| `?` | 0、1、x 都可以，用來縮短真值表 |
| 只能依順序連接 | 依名稱會在 vsim 載入時 Fatal（vsim-3367） |
