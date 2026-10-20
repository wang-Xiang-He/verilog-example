# 05_Encoder2_3 範例說明：優先權編碼器（assign 寫法與 if ... else 寫法）

## 1. 這個範例在做什麼？

和 [04_Encoder1](../04_Encoder1/Encoder1_說明.md) 相同的 8 對 3 優先權編碼器，換成另外兩種寫法（講義第 18~22 頁）：

| 模組 | 寫法 | 講義的評語 |
|------|------|-----------|
| `Encoder2` | `assign` + 巢狀條件運算子 `? :` | 簡單，但浪費（第 19 頁） |
| `Encoder3` | `always` + `if ... else if` | **Good Design**（第 21 頁） |

8 個輸入改成 8 個獨立的 1 位元訊號 `a`~`h`：**h 優先權最高，a 最低**。

```
h ─►┌──────────┐
g ─►│          │──► Out_Vect[3:0]
f ─►│  8 對 3  │
e ─►│  優先權  │──► None_ON  (= Out_Vect[3])
d ─►│  編碼器  │──► Out2     (= Out_Vect[2])
c ─►│          │──► Out1     (= Out_Vect[1])
b ─►│          │──► Out0     (= Out_Vect[0])
a ─►└──────────┘
```

---

## 2. Encoder2：巢狀條件運算子（講義第 19 頁）

```verilog
assign Out_Vect = h ? 4'b0111 :     // 如果 h = 1，則 Out_Vect = 4'b0111     ↑ High
                  g ? 4'b0110 :     // 否則如果 g = 1 ...                     │
                  f ? 4'b0101 :     //                                        │ Priority
                  ...
                  a ? 4'b0000 :     //                                        │ Low
                      4'b1000;      // 否則：None_ON = 1

assign None_ON = Out_Vect[3];
assign Out2    = Out_Vect[2];
assign Out1    = Out_Vect[1];
assign Out0    = Out_Vect[0];
```

- `? :` 一個接一個串下去：**最先判斷的 h 優先權最高**。
- 4 位元 `Out_Vect` 一起算，最高位就是 None_ON：全部是 0 時是 `1000`。

### 講義第 19 頁：「此種設計簡單，但浪費記憶體，可考慮修正為 Pin = 3 bits」
`Out_Vect` 和 `None_ON / Out2 / Out1 / Out0` 是**同樣的 4 個位元**，卻都接成輸出埠，等於同一個訊號輸出了兩次。
放到 FPGA 上會多佔 4 支接腳。輸出埠只要保留 3 位元的 Out 加上 None_ON 就夠了。

---

## 3. Encoder3：if ... else if（講義第 21 頁）

```verilog
assign {None_ON, Out2, Out1, Out0} = Out_Vect;     // 連結運算子放在等號左邊，一次拆成 4 個

always @(*) begin           // 講義：always @(a or b or c or d or e or f or g or h)
         if (h) Out_Vect = 4'b0111;     // High
    else if (g) Out_Vect = 4'b0110;
    ...
    else if (a) Out_Vect = 4'b0000;     // Low
    else        Out_Vect = 4'b1000;
end
```

- `if ... else if` 的「**先寫的先判斷**」就是優先權，一眼就看得出來，所以講義說是 Good Design。
- 最後一定要有 `else`，否則全部是 0 時 `Out_Vect` 沒有被賦值，就會產生 latch。
- `{None_ON, Out2, Out1, Out0} = Out_Vect;`：連結運算子放在等號**左邊**，把 4 位元拆給 4 條線（講義第 21 頁的箭頭）。

> 和 Encoder1 的 for 迴圈比較：Encoder1 從低位往高位掃，靠「後面蓋掉前面」得到優先權；
> Encoder3 從高位開始判斷，找到就停。兩者結果相同，但 Encoder3 好讀很多。

---

## 4. 預期輸出

```
  h g f e d c b a  |  Encoder2: None_ON Out[2:0]  |  Encoder3: None_ON Out[2:0]
  0 0 0 0 0 0 0 1  |      0      000         |      0      000     ← 講義第 20 頁：a = 1
  0 0 0 0 0 1 1 0  |      0      010         |      0      010     ← 講義第 20 頁：b、c = 1 → 取 c
  0 0 0 0 0 0 0 0  |      1      000         |      1      000     ← 全部是 0
  0 0 0 0 0 0 0 1  |      0      000         |      0      000
  0 0 0 0 0 0 1 0  |      0      001         |      0      001
  ...
  1 0 0 0 0 0 0 0  |      0      111         |      0      111
  1 1 1 1 1 1 1 1  |      0      111         |      0      111     ← 全部是 1 → 取 h
checked 256 inputs, errors = 0
```

### 觀察重點
- 第 2 行：b 和 c 同時是 1，取優先權較高的 c → `010`（和講義第 20、22 頁的 0001 → 0010 波形一致）。
- 256 種輸入全部比對，兩種寫法 `errors = 0`：寫法不同，電路功能完全相同。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 巢狀 `? :` | 先判斷的優先，適合簡短的情況 |
| `if ... else if` | 先判斷的優先，最清楚（Good Design） |
| 最後的 else | 一定要有，否則產生 latch |
| 輸出埠不重複 | 同樣的訊號不要接兩組輸出，浪費接腳 |
| `{a, b} = x;` | 連結運算子放在左邊可以拆訊號 |
