# 14_Concate 範例說明：連結運算子（交換高低 4 位元）

## 1. 這個範例在做什麼？

把兩個 4 位元資料 `byte1`、`byte2` 拼成一個 8 位元 `word`，由 `swap` 決定誰放高位：

| swap | word |
|------|------|
| 0 | `{byte1, byte2}`：byte1 在高 4 位 |
| 1 | `{byte2, byte1}`：byte2 在高 4 位 |

重點在介紹**連結運算子（Concatenation）** `{ , }`。

---

## 2. 連結運算子

用大括號把多個訊號**依序接在一起**，寫在**左邊的放在高位**：

```
byte1 = 1000, byte2 = 0001

{byte1, byte2} = 1000_0001
                 ^^^^ ^^^^
                byte1 byte2

{byte2, byte1} = 0001_1000
```

結果寬度 = 各部分寬度相加（4 + 4 = 8）。

### 常見用法

| 用法 | 例子 |
|------|------|
| 拼接 | `{a, b}` |
| 拆解（放在等號左邊） | `{Carry_Out, Sum} = a + b + c;`（[01_FullAdd](../01_FullAdd/FullAdd_說明.md)） |
| 旋轉 | `{q[6:0], q[7]}`（[03_Hierar](../03_Hierar/Hierar_說明.md) 左旋） |
| 補位 | `{8'b0, Word}`、`{{8{Word[7]}}, Word}`（[13_Sign_Ext](../13_Sign_Ext/Sign_Extend_說明.md)） |
| 迴圈拆位元 | `{a, b, Carry_In} = i;`（testbench） |

> 注意：連結裡的每個值都要有**明確寬度**。寫 `{a, 1}` 會出錯，要寫 `{a, 1'b1}`。

---

## 3. 檔案說明

### Concate.v
```verilog
module Concate (
    input            swap,
    input      [3:0] byte1,
    input      [3:0] byte2,
    output reg [7:0] word
);
    always @(*) begin
        if (swap)
            word = {byte2, byte1};   // 等於 (byte2 << 4) + byte1
        else
            word = {byte1, byte2};   // 等於 (byte1 << 4) + byte2
    end
endmodule
```
- 講義的敏感清單寫 `@(swap or byte1 or byte2)`，這裡改成 `@(*)`，自動列出所有輸入（見 [13_Sign_Ext](../13_Sign_Ext/Sign_Extend_說明.md)）。
- 用 `always` + `if-else` 描述組合邏輯，敏感清單列出所有輸入，用阻隔式 `=`。
- 硬體上其實只是**接線交叉**，再加一組多工器依 `swap` 選擇，沒有任何運算。

### Concate_tb.v
兩組資料各測 `swap = 1` 和 `swap = 0`。

---

## 4. 預期輸出

```
t=0   swap=1 byte1=1000 byte2=0001  ->  word=00011000   ← {byte2, byte1}
t=10  swap=0 byte1=1000 byte2=0001  ->  word=10000001   ← {byte1, byte2}
t=20  swap=1 byte1=0101 byte2=1010  ->  word=10100101
t=30  swap=0 byte1=0101 byte2=1010  ->  word=01011010
```

### 觀察重點
- 同一組輸入，`swap` 切換後 `word` 的**高低 4 位互換**。
- 以 16 進位看：`0x18` ↔ `0x81`、`0xA5` ↔ `0x5A`，就是交換兩個 16 進位數字。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 連結運算子 `{ , }` | 依序拼接，左邊為高位 |
| 寬度 | 結果寬度為各部分寬度總和，每部分須有明確寬度 |
| 放在等號左邊 | 可把結果拆給多個訊號 |
| 硬體成本 | 只是接線，不需要邏輯閘 |
