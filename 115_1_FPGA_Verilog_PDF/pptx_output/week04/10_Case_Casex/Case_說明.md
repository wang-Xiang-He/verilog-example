# 10_Case_Casex 範例說明：case / casex

## 1. 這個範例在做什麼？

講義第 30~33 頁的三種 case 用法：

| 模組 | 內容 | 講義 |
|------|------|------|
| Case_Prio | `case (2'b11)`：運算式是常數、項目是變數 → **有優先權** | 第 31 頁 範例 1 |
| Mux_Case | `case (select)`：一般的 4 選 1 多工器，各項互斥 → **平行** | 第 32 頁 範例 3 |
| Casex_Prio | `casex` + 不在乎位元 `x` → 多項同時符合時取第一個 | 第 32 頁 範例 4 |

### case 語法
```verilog
case (運算式)
    項目1   : 敘述;
    項目2   : 敘述;
    default : 敘述;      // 以上都不符合時
endcase
```
由上往下比對，**第一個相等的項目**被執行，其餘略過。

---

## 2. 檔案說明

### Case_Prio.v
```verilog
case (2'b11)
    u       : Out = 3'b001;
    v       : Out = 3'b010;
    w       : Out = 3'b100;
    default : Out = 3'b000;
endcase
```
意思是「u、v、w 中，**第一個等於 11 的是誰**」。u 最先比對 → 優先權最高。
和講義第 31 頁範例 2 的 `if (u == 2'b11) ... else if (v == 2'b11) ...` 功能相同。

### Mux_Case.v
```verilog
case (select)
    2'b00 : Out = in1;
    2'b01 : Out = in2;
    2'b10 : Out = in3;     // 講義沒有這一行
    2'b11 : Out = in4;
    default : Out = 4'bx;
endcase
```
- `select` 同一時間只會等於其中一個值，各項**互斥**，合成為平行的多工器。
- 講義只列 00、01、11。`select = 10` 時沒有任何一行給 `Out` 值 → `Out` 必須「記住」舊值 →
  合成器會產生 **Latch**（不想要的記憶元件）。所以 case 要列完整，或加 `default`。
- `// synopsys parallel_case` 是寫給 Synopsys 合成工具看的註解，對模擬沒有影響。

### Casex_Prio.v
```verilog
temp = {X, Y, Z};
casex (temp)
    3'b1xx  : Value = Result1;   // X = 1
    3'bx1x  : Value = Result2;   // Y = 1
    3'bxx1  : Value = Result3;   // Z = 1
    default : Value = Result4;
endcase
```
- `casex` 中，項目的 `x`（和 `z`、`?`）代表**不在乎**：該位元 0 或 1 都算符合。
- XYZ = 111 時三項都符合，取**第一個** → Result1，所以 X 優先權最高。
- 注意這裡的優先順序（X 最高）和 08_Priority_If（Z 最高）剛好相反。

---

## 3. 預期輸出

```
--- (1) Case_Prio: case (2'b11) ---
u=11 v=11 w=11  ->  Out=001      ← u 最優先
u=01 v=11 w=11  ->  Out=010
u=01 v=10 w=11  ->  Out=100
u=00 v=00 w=00  ->  Out=000      ← default
--- (2) Mux_Case: in1=A in2=B in3=C in4=D ---
select=00  ->  Out=a
select=01  ->  Out=b
select=10  ->  Out=c
select=11  ->  Out=d
--- (3) Casex_Prio: 1xx / x1x / xx1 ---
XYZ=000  ->  Value=Result4
XYZ=001  ->  Value=Result3
XYZ=010  ->  Value=Result2
XYZ=011  ->  Value=Result2       ← x1x 和 xx1 都符合，取前面的
XYZ=100  ->  Value=Result1
XYZ=101  ->  Value=Result1
XYZ=110  ->  Value=Result1
XYZ=111  ->  Value=Result1
```

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `case` | 由上往下比對，取第一個相等的項目 |
| `default` | 都不符合時執行；組合邏輯中可避免 Latch |
| 項目互斥 | 合成為平行多工器（Parallel Decoder） |
| 項目可能重疊 | 有優先權（Priority Decoder） |
| `casex` | 項目中的 x / z / ? 都是不在乎位元 |
| 項目不完整 | 組合邏輯中會產生 Latch |
