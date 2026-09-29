# 04_DFF 範例說明：D 型正反器（D Flip-Flop）

## 1. 這個範例在做什麼？

設計最基本的**記憶元件**：D 型正反器。

- 在時脈 `clk` **正緣**（0 → 1 的瞬間）把輸入 `din` 存進 `q`。
- 其他時間不管 `din` 怎麼變，`q` 都**保持不變**。

前面的範例都是**組合邏輯**（輸入一變輸出立刻變），這是第一個**循序邏輯**（有記憶、跟著時脈動作）。

```
   din ──►┌─────┐
          │ DFF │──► q
   clk ──►│ >   │
          └─────┘
```

---

## 2. 檔案說明

### dff.v
```verilog
module dff (
    input      din,
    input      clk,
    output reg q               // 在 always 裡被賦值 → 必須是 reg
);
    always @(posedge clk)      // 只在 clk 正緣執行
        q <= din;
endmodule
```

- 埠宣告使用 **Verilog-2001** 寫法：方向和型態直接寫在埠列表裡。
  講義是舊寫法 `module dff (din, clk, q); input din, clk; output q; reg q;`，功能相同
  （比較見 [03_Hierar 說明第 6 節](../03_Hierar/Hierar_說明.md)）。
- `always @(posedge clk)`：**敏感清單**只有 `posedge clk`，所以區塊只在時脈正緣時執行一次。
- `q` 在 `always` 裡被賦值，所以要宣告成 `reg`。
  （`reg` 只是 Verilog 語法上的要求，不一定代表合成出暫存器；這裡因為是 `posedge` 觸發，才真的合成成正反器。）
- 講義寫 `q = din`，這裡改成 **`q <= din`（非阻隔式賦值）**。
  正反器一律用 `<=`，原因見 [03_Hierar 說明第 5 節](../03_Hierar/Hierar_說明.md)。

### dff_tb.v
```verilog
always #5  clk <= !clk;    // 時脈週期 10ns，正緣在 5, 15, 25 ...
always #10 din <= !din;    // din 每 10ns 反相，變化在 10, 20, 30 ...
```
- 用兩個 `always` 產生週期性訊號：`clk` 每 5 ns 反相，`din` 每 10 ns 反相。
- `din` 的變化點（10, 20, 30…）剛好都在 `clk` 的**負緣**，和正緣錯開，避免同時變化造成混淆。
- `#60 $stop`：講義沒有寫結束條件，`always` 會無限執行下去，所以補上。

---

## 3. 預期輸出

```
t=0   clk=0 din=0  q=x    ← 還沒遇到正緣，q 是未知值 x
t=5   clk=1 din=0  q=0    ← 正緣：存入 din=0
t=10  clk=0 din=1  q=0    ← din 變了，但不是正緣，q 不動
t=15  clk=1 din=1  q=1    ← 正緣：存入 din=1
t=20  clk=0 din=0  q=1
t=25  clk=1 din=0  q=0
t=30  clk=0 din=1  q=0
t=35  clk=1 din=1  q=1
...
```

### 觀察重點
- **q 只在 clk 由 0 變 1 時改變**，其他時間 din 怎麼變都不影響 q。
- **t=0 的 `q=x`**：`x` 代表未知值。正反器上電時的內容不確定，要等第一個正緣才有值。
  實際電路通常會加上 Reset 來給初始值（見 03_Hierar 的 Register8）。
- 從波形看，`q` 就像是 `din` **延遲了半個時脈**後再「對齊」到正緣。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 循序邏輯 | 有記憶，輸出依時脈更新 |
| `always @(posedge clk)` | 在時脈正緣觸發 |
| `reg` | 在 `always` / `initial` 中被賦值的訊號必須宣告為 reg |
| 非阻隔式 `<=` | 正反器 / 暫存器一律使用 |
| `x` | 未知值，未初始化的 reg 預設為 x |
| 用 `always #N` 產生時脈 | testbench 常用寫法 |
