# 05_DFF_Sel 範例說明：正反器選擇電路

## 1. 這個範例在做什麼？

`da`、`db` 各自先經過一個 D 型正反器存起來，再由 `sel` 決定輸出哪一個：

- `sel = 0` → `q = qa`（da 存起來的值）
- `sel = 1` → `q = qb`（db 存起來的值）

這是結合 [04_DFF](../04_DFF/dff_說明.md) 的正反器和多工器的**階層式設計**練習。

---

## 2. 電路架構

```
            ┌──────┐ qa
   da ─────►│ dff1 │─────►┌────────┐
       clk─►│ >    │      │        │
            └──────┘      │ mux2_1 │────► q
            ┌──────┐ qb   │        │
   db ─────►│ dff2 │─────►│        │
       clk─►│ >    │      └───▲────┘
            └──────┘          │
   sel ───────────────────────┘
```

---

## 3. 檔案說明

| 檔案 | 用途 |
|------|------|
| `dff.v` | D 型正反器（和 04 範例相同） |
| `mux2_1.v` | 1 位元 2 選 1 多工器（講義沒列出，依方塊圖補上） |
| `dff_sel.v` | 上層模組，接起 2 個 dff + 1 個 mux |
| `dff_sel_tb.v` | 測試平台 |

### mux2_1.v
```verilog
assign mout = s ? mb : ma;   // s=0 → ma；s=1 → mb
```

### dff_sel.v
```verilog
wire qa, qb;                                          // 內部連線
dff    dff1 (da, clk, qa);                            // 依順序
dff    dff2 (db, clk, qb);                            // 依順序
mux2_1 mux  (.ma(qa), .mb(qb), .s(sel), .mout(q));    // 依名稱
```
- 同一個 `dff` 模組實例化兩次（`dff1`、`dff2`），是兩個獨立的正反器。
- 這裡示範**不同實例可以使用不同的連接方式**：dff 用依順序，mux 用依名稱。

### dff_sel_tb.v
```verilog
always #5  clk <= !clk;    // 時脈週期 10ns
always #20 da  <= !da;     // da 每 20ns 反相
always #30 db  <= !db;     // db 每 30ns 反相
always #40 sel <= !sel;    // sel 每 40ns 切換
```
- 三個輸入用不同週期變化，讓各種組合都能出現。
- `$monitor` 裡用 `dff.qa`、`dff.qb` 這種**階層式名稱**，直接看到子模組內部的訊號
  （`dff` 是 testbench 中實例的名字）。

---

## 4. 預期輸出（節錄）

時脈正緣在 5, 15, 25 …；輸入都在 10 的倍數（負緣）變化。

```
t=0   clk=0 da=0 db=0 sel=0  qa=x qb=x  q=x   ← 尚未遇到正緣
t=5   clk=1 da=0 db=0 sel=0  qa=0 qb=0  q=0
t=20  clk=0 da=1 db=0 sel=0  qa=0 qb=0  q=0   ← da 變 1，qa 還沒變
t=25  clk=1 da=1 db=0 sel=0  qa=1 qb=0  q=1   ← 正緣存入，q 跟著 qa
t=35  clk=1 da=1 db=1 sel=0  qa=1 qb=1  q=1
t=40  clk=0 da=0 db=1 sel=1  qa=1 qb=1  q=1   ← sel 切到 qb
t=45  clk=1 da=0 db=1 sel=1  qa=0 qb=1  q=1   ← qa 變 0，但現在看 qb
t=65  clk=1 da=1 db=0 sel=1  qa=1 qb=0  q=0   ← q 跟著 qb 變 0
t=80  clk=0 da=0 db=0 sel=0  qa=1 qb=0  q=1   ← sel 切回 qa，q 立刻變 1（不是正緣）
t=85  clk=1 da=0 db=0 sel=0  qa=0 qb=0  q=0
...
```

### 觀察重點
- **sel = 0 時 q 跟 qa，sel = 1 時 q 跟 qb**。
- `da`、`db` 要等到**時脈正緣**才會反映到 `qa`、`qb`（延遲）。
- `sel` **直接進多工器、不經過正反器**，所以 sel 一變 q 就**立刻**變（例如 t=80，不在正緣也會變）。
  這就是組合邏輯與循序邏輯混合時的差異。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 同一模組多次實例化 | `dff1`、`dff2` 是兩個獨立的正反器 |
| 混用連接方式 | 不同實例可各自用依順序 / 依名稱 |
| 階層式名稱 | `dff.qa` 在 testbench 中窺看內部訊號（僅模擬用） |
| 組合 vs 循序 | 經過正反器的訊號要等時脈；直接進 mux 的訊號立即反應 |
