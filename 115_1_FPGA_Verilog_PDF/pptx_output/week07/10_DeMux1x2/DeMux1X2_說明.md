# 10_DeMux1x2 範例說明：1 對 2 解多工器（assign 與 if ... else）

## 1. 這個範例在做什麼？

**解多工器（DeMultiplexer）** 的動作恰好和多工器相反（講義第 44 頁）：
從**單一條輸入線**輸入值，然後傳送到 2ⁿ 個可能輸出中的**一條**輸出線上。

```
           ┌──────┐
  D ──────►│ 1對2 │──► Y0     Y0 = Select'．D
           │ 解多 │
           │ 工器 │──► Y1     Y1 = Select ．D
           └──▲───┘
            Select
```

| Select | Y0 | Y1 |
|--------|----|----|
| 0 | D | 0 |
| 1 | 0 | D |

可以想成鐵路的轉轍器：同一班列車（D），由 Select 決定開往 Y0 還是 Y1 那條軌道。

> 多工器：多 → 一（選一個輸入）；解多工器：一 → 多（選一個輸出）。

---

## 2. 兩種寫法

### DeMux1X2_1：assign（講義第 45 頁）
```verilog
assign Y0 = (!Select) & D;
assign Y1 = Select & D;
```
直接照布林方程式寫。對應的電路是一個反向器和兩個 AND 閘（講義第 44 頁的邏輯電路圖）。

### DeMux1X2_2：if ... else（講義第 47 頁）
```verilog
always @(*) begin           // 講義：always @(D or Select)
    if (Select == 1'b0) begin
        Y0 = D;
        Y1 = 0;
    end
    else if (Select == 1'b1) begin
        Y0 = 0;
        Y1 = D;
    end
    // 講義沒有最後的 else
end
```

### 講義第 46 頁標「Error」？
第 46 頁的模擬結果圖標了「Error」：那張圖其實是 4 對 1 **多工器**的波形（A、B、C、D、S1、S0），貼錯圖了，不是本電路的結果。本範例的實際結果在第 4 節。

---

## 3. 沒有最後的 else 會怎樣？

`DeMux1X2_2` 只處理了 Select = 0 和 Select = 1。如果 Select 是 x 或 z，兩個 `if` 都不成立，**Y0、Y1 都沒有被賦值**，就會保持原來的值。

- 「保持原來的值」= 需要記憶 → 合成時會產生 **latch（閂鎖器）**。這是組合邏輯最常見的錯誤之一。
- 解決方法：每個分支都要給**所有輸出**一個值，或加上最後的 `else`。
  下一個範例的 `DeMux1to2E`（[12_DeMux1x4_By_1x2E](../12_DeMux1x4_By_1x2E/DeMux1x4_By_DeMux1to2E_說明.md)）就有補上 else。

testbench 故意讓 Select = x，看兩種寫法的差異。

---

## 4. 預期輸出

```
t=0   Select=0 D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=0
t=10  Select=0 D=1  ->  _1(assign): Y0=1 Y1=0   _2(if): Y0=1 Y1=0    ← Select=0：D 送到 Y0
t=20  Select=1 D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=0
t=30  Select=1 D=1  ->  _1(assign): Y0=0 Y1=1   _2(if): Y0=0 Y1=1    ← Select=1：D 送到 Y1
t=40  Select=x D=1  ->  _1(assign): Y0=x Y1=x   _2(if): Y0=0 Y1=1    ← 開始不一樣
t=50  Select=x D=0  ->  _1(assign): Y0=0 Y1=0   _2(if): Y0=0 Y1=1
t=60  Select=0 D=1  ->  _1(assign): Y0=1 Y1=0   _2(if): Y0=1 Y1=0
```

### 觀察重點
- Select 是 0 / 1 時，兩種寫法完全一樣。
- **t=40、50（Select = x）**：
  - `_1`：照布林方程式計算，`!x & 1 = x`，`!x & 0 = 0`，可以看出 Select 有問題。
  - `_2`：兩個 if 都不成立，Y0、Y1 **停在 t=30 的值（0、1）**；t=50 D 改成 0，輸出還是不動。這就是 latch 的行為，講義第 48 頁波形中紅、藍那段就是這個情況。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 解多工器 | 一條輸入 → 選一條輸出，其他輸出 0 |
| 布林方程式 | Y0 = Select'．D、Y1 = Select．D |
| 沒有最後的 else | 輸出保持舊值 → 產生 latch |
| 組合邏輯原則 | 每條路徑都要給所有輸出一個值 |
