# 03_Hierar 範例說明：階層式設計（Hierarchical Design）

## 1. 這個範例在做什麼？

用三個小模組（Mux、Register8、Rotate_Data）**組合成一個大模組**（Top），
示範 Verilog 的「階層式設計」：大電路由小電路拼起來，上層模組裡「實例化（instantiate）」下層模組。

同一個電路寫了兩份：

| 檔案 | 連接埠的方式 |
|------|--------------|
| `Top1.v` | **依順序**（by order）連接 |
| `Top2.v` | **依名稱**（by name）連接 |

Testbench 同時跑 Top1 和 Top2，檢查兩者輸出是否完全一樣，證明「兩種接法只是寫法不同，電路相同」。

---

## 2. 電路架構

```
            ┌──────┐  Mux_Out  ┌───────────┐  Reg_Out  ┌─────────────┐
   a ──────►│      │──────────►│           │──────────►│             │
   b ──────►│ Mux  │           │ Register8 │           │ Rotate_Data │──────► out
   Sel ────►│      │           │           │           │             │
            └──────┘           └───────────┘           └─────────────┘
                                   ▲    ▲                 ▲   ▲   ▲
                              Clock┘    └Reset       Clock┘ Reset └Left_Rotate
```

資料流向：`a / b → Mux → Register8（第 1 級）→ Rotate_Data（第 2 級）→ out`

`Mux_Out`、`Reg_Out` 是 Top 模組內部的 `wire`，用來把子模組串起來。

---

## 3. 各檔案功能

### Mux.v — 8 位元 2 選 1 多工器（組合邏輯）
```verilog
assign out = Sel ? a : b;
```
- `Sel = 1` → 輸出 `a`
- `Sel = 0` → 輸出 `b`
- 沒有時脈，輸入一變輸出立刻跟著變。

### Register8.v — 8 位元暫存器（循序邏輯）
```verilog
module Register8 (
    input            Clock,
    input            Reset,
    input      [7:0] data,
    output reg [7:0] q
);
    always @(posedge Clock) begin
        if (Reset) q <= 8'b0;
        else       q <= data;
    end
endmodule
```
- 每個時脈**正緣**（`posedge Clock`）把 `data` 存進 `q`。
- `Reset = 1` 時清為 0（**同步重置**：要等到時脈正緣才清）。
- 作用：讓資料「延遲一個時脈」。

### Rotate_Data.v — 載入 / 左旋暫存器（循序邏輯）
每個時脈正緣依優先順序：

| 條件 | 動作 |
|------|------|
| `Reset = 1` | `q <= 0` |
| `Left_Rotate = 1` | `q <= {q[6:0], q[7]}` 向左旋轉 1 位（最高位繞回最低位） |
| 其他 | `q <= data` 載入資料 |

左旋範例：`1000_0001` → `0000_0011` → `0000_0110` → ...

> 注意：Left_Rotate = 1 時**不理會** data，只轉自己內部的值。

### Top1.v — 依順序連接
```verilog
Mux Mux_1 (Sel, a, b, Mux_Out);
```
括號內的訊號**必須照子模組宣告埠的順序**排列（Mux 宣告是 `(Sel, a, b, out)`）。
- 優點：短。
- 缺點：順序排錯編譯不會報錯，但電路會接錯，很難除錯。

### Top2.v — 依名稱連接
```verilog
Mux Mux_1 (.out(Mux_Out), .Sel(Sel), .b(b), .a(a));
//          ↑子模組埠名  ↑上層的訊號
```
- 格式：`.子模組埠名(外部訊號)`，順序可以隨便排。
- 優點：清楚、不怕排錯，**實務上建議用這種**。
- 規則：**同一個實例裡**不能混用兩種方式；但**不同實例**可以各用一種
  （Top2 的 `Rotate_Data_1` 故意仍用依順序，示範這點）。

### Hierar_tb.v — 測試平台
- 同時放入 `u_top1`（依順序接）和 `u_top2`（依名稱接），吃相同輸入。
- 產生週期 10 ns 的時脈（每 5 ns 反相）。
- 在時脈**負緣**印出結果（此時正緣造成的變化已穩定）。
- 最後一欄 `same` / `DIFF!` 比較 `out1 === out2`。
- `u_top1.Reg_Out`：**階層式名稱**，直接從 testbench 看子模組內部訊號（只能用在模擬，不能合成）。

### run.do — ModelSim 一鍵執行腳本
在 Transcript 視窗 `cd` 到本資料夾後輸入 `do run.do`。

---

## 4. 測試流程與波形解讀

輸入：`a = 1000_0001`、`b = 0000_1111`

| 時間 | 事件 |
|------|------|
| 0 ns | Reset = 1、Sel = 1（選 a）、Left_Rotate = 0 |
| 12 ns | 放開 Reset |
| 32 ns | Sel = 0（改選 b） |
| 52 ns | Sel = 1（選回 a） |
| 72 ns | Left_Rotate = 1（開始左旋） |
| 122 ns | `$stop` 停止模擬 |

時脈正緣在 5、15、25、35 … ns；顯示在負緣 10、20、30 … ns。

```
t=0    Reset=1 Sel=1 Rot=0  Reg_Out=xxxxxxxx  out=xxxxxxxx   ← Clock 由 x 變 0 也算負緣；還沒遇到正緣，暫存器是 x
t=10   Reset=1 Sel=1 Rot=0  Reg_Out=00000000  out=00000000   ← 5ns 正緣時同步重置
t=20   Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out=00000000   ← a 進到第 1 級
t=30   Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out=10000001   ← a 到第 2 級（晚 1 拍）
t=40   Reset=0 Sel=0 Rot=0  Reg_Out=00001111  out=10000001   ← b 進到第 1 級
t=50   Reset=0 Sel=0 Rot=0  Reg_Out=00001111  out=00001111   ← b 到 out
t=60   Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out=00001111
t=70   Reset=0 Sel=1 Rot=0  Reg_Out=10000001  out=10000001
t=80   Reset=0 Sel=1 Rot=1  Reg_Out=10000001  out=00000011   ← 開始左旋
t=90                                          out=00000110
t=100                                         out=00001100
t=110                                         out=00011000
t=120                                         out=00110000
```

### 觀察重點
1. **兩級管線延遲**：Sel 改變後，`Reg_Out` 下一個正緣就變，`out` 要再晚一個正緣。
   資料從輸入到 `out` 共需 **2 個時脈**。
2. **左旋**：Left_Rotate = 1 後，`out` 每個時脈左轉 1 位；`Reg_Out` 不受影響（仍持續載入 a）。
3. **out1 與 out2 每一行都是 `same`**：依順序與依名稱接出的電路完全相同。

---

## 5. 為什麼暫存器用 `<=`（非阻隔式賦值）？

講義原本寫 `q = data`，本範例改成 `q <= data`。

Register8 和 Rotate_Data 在**同一個時脈正緣**更新，而 Rotate_Data 讀的是 Register8 的輸出。
- 用 `=`（blocking）：兩個 always 區塊誰先執行由模擬器決定 → **競爭條件（race condition）**，
  Rotate_Data 可能讀到「新值」，造成少延遲一拍。
- 用 `<=`（non-blocking）：所有暫存器都先讀「舊值」，最後才一起更新 → 行為和真實正反器一致。

**口訣：循序邏輯（`always @(posedge Clock)`）一律用 `<=`；組合邏輯用 `=` 或 `assign`。**

---

## 6. 埠宣告：Verilog-1995 舊寫法 vs Verilog-2001 新寫法

本資料夾的程式已改成 **Verilog-2001（ANSI 風格）**；講義用的是 **Verilog-1995** 舊寫法。兩者功能完全相同。

**舊寫法（講義）**：先列埠名，再到下面分別宣告方向和型態，同一個名字要寫 3 次
```verilog
module Register8 (Clock, Reset, data, q);
    input        Clock, Reset;
    input  [7:0] data;
    output [7:0] q;
    reg    [7:0] q;
    ...
```

**新寫法（本範例）**：方向、型態、寬度都寫進埠列表，每個名字只寫一次
```verilog
module Register8 (
    input            Clock,
    input            Reset,
    input      [7:0] data,
    output reg [7:0] q
);
    ...
```

- 新寫法不會發生「埠列表和下面宣告對不上」的錯誤，也是現在 Quartus / Vivado 範本和業界的主流。
- **埠的順序沒有變**，所以 Top1 依順序連接的寫法完全不用改。
- 下面的 `always`、`<=`、實例化語法都不受影響。

---

## 7. 重點整理

| 觀念 | 說明 |
|------|------|
| 階層式設計 | 上層模組實例化下層模組，用內部 `wire` 串接 |
| 實例化語法 | `模組名 實例名 (連接埠);`，例如 `Mux Mux_1 (...)` |
| 依順序連接 | 照宣告順序排，短但易錯 |
| 依名稱連接 | `.埠名(訊號)`，清楚安全，建議使用 |
| 階層式名稱 | `u_top1.Reg_Out`，testbench 中窺看內部訊號 |
| 管線延遲 | 每經過一級暫存器延遲 1 個時脈 |
| 非阻隔式賦值 | 暫存器用 `<=` 避免競爭條件 |
| ANSI 埠宣告 | `output reg [7:0] q` 直接寫在埠列表（Verilog-2001） |
