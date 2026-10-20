# 07_Mux2to1_4Ways 範例說明：2 對 1 多工器的 4 種寫法

## 1. 這個範例在做什麼？

**多工器（Multiplexer）** 可以從多個輸入線中選取一條輸入線，把它的資訊放到單一的輸出線上，所以又叫**資料選擇器（Data Selector）**（講義第 28 頁）。

講義用 4 種寫法描述同一個 2 對 1 多工器（第 29~36 頁）。本範例把 4 種都放進同一個 testbench，看它們什麼時候一樣、什麼時候不一樣。

| 模組 | 寫法 | Select 是 x 時 |
|------|------|---------------|
| `Mux2to1_1` | `if ... else` | 沒特別處理 |
| `Mux2to1_2` | `assign` + `? :` | 沒特別處理 |
| `Mux2to1_3` | `if ... else if ... else`，多考慮 Select 不確定 | `Out = 1'bx` |
| `Mux2to1_4` | `case` + `default` | `Out = 1'bx` |

四個模組都是 **Select = 1 → Out = a；Select = 0 → Out = b**。

---

## 2. 講義第 29 頁：「程式有誤？」

講義第 28 頁的真值表是：

| Select | Out |
|--------|-----|
| 0 | a |
| 1 | b |

但第 29 頁的程式是 `if (Select) Out = a; else Out = b;`，也就是 **Select = 1 → a**，**和真值表相反**。
程式沒有語法錯誤，問題是和規格不一致。後面第 31、33、35 頁的程式也都是 Select = 1 → a，所以本資料夾 4 個模組都照**程式**的定義。

> 寫電路之前先確認規格（真值表），寫完再用 testbench 對照，這種不一致才抓得到。

---

## 3. 4 種寫法

### Mux2to1_1：if ... else（講義第 29 頁）
```verilog
always @(*) begin           // 講義：always @(a or b or Select)
    if (Select)
        Out = a;
    else
        Out = b;
end
```
講義第 29 頁：**always 的 begin ... end 內，輸出變數僅可為 reg 型態**，所以 `output reg Out`。

### Mux2to1_2：assign（講義第 31 頁）
```verilog
assign Out = Select ? a : b;
```
講義第 31 頁：**assign 指令可使用 wire 型態，不可使用 reg 型態**，所以 `output Out`（預設是 wire）。

### Mux2to1_3：考慮不確定值（講義第 33 頁）
```verilog
always @(*) begin
    if (Select == 1'b1)       Out = a;
    else if (Select == 1'b0)  Out = b;
    else                      Out = 1'bx;      // 不確定值，Unknown
end
```

### Mux2to1_4：case（講義第 35 頁）
```verilog
always @(*) begin
    case (Select)
        1'b1:    Out = a;
        1'b0:    Out = b;
        default: Out = 1'bx;
    endcase
end
```

---

## 4. 預期輸出

```
            Select a b  |  _1(if) _2(?:) _3(if,x) _4(case)
t= 10       0    0 0  |     0      0       0        0
t= 20       0    0 1  |     1      1       1        1      ← Select = 0 → b
t= 30       0    1 0  |     0      0       0        0
t= 40       0    1 1  |     1      1       1        1
t= 50       1    0 0  |     0      0       0        0
t= 60       1    0 1  |     0      0       0        0
t= 70       1    1 0  |     1      1       1        1      ← Select = 1 → a
t= 80       1    1 1  |     1      1       1        1
t= 90       x    1 0  |     0      x       x        x      ← Select 不確定，a、b 不同
t=100       x    1 1  |     1      1       x        x      ← Select 不確定，a、b 相同
t=110       z    0 1  |     1      x       x        x
```

### 觀察重點：Select 是 0 / 1 時 4 種一樣；是 x 時就不一樣了

| 寫法 | Select = x 時發生什麼 |
|------|----------------------|
| `_1` `if (Select)` | `if (x)` 被當成「**不成立**」→ 走 else → Out = b。**假裝一切正常**，最危險 |
| `_2` `Select ? a : b` | 條件是 x 時，把 a、b **逐位比較**：相同就輸出那個值，不同就輸出 x |
| `_3` `== 1'b1` / `== 1'b0` | 兩個比較的結果都是 x（不成立）→ 走最後的 else → x |
| `_4` `case` | `case` 用「完全相等」比對，x 和 1、0 都比對不到 → default → x |

- 講義第 34、36 頁波形中 Select 變成不確定值的那段，Out 也變成不確定（紅線），就是 `_3`、`_4` 的行為。
- 模擬時，`_3`、`_4` 會把「Select 沒接好」這種錯誤**明顯地顯示成 x**，比較容易除錯。
- 合成成真正的電路時，x 不存在，4 種寫法得到的硬體一樣，都是一個 2 對 1 多工器。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 多工器 | 從多條輸入選一條送到輸出（資料選擇器） |
| always 內賦值 | 輸出要宣告成 reg |
| assign 賦值 | 輸出是 wire |
| `if (x)` | 被當成不成立，會把 x 藏起來 |
| `? :` 遇到 x | a、b 相同輸出該值，不同輸出 x |
| default: x | 模擬時把不確定的選擇線明顯標出來 |
