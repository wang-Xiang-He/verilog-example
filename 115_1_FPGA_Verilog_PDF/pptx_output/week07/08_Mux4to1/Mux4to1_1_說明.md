# 08_Mux4to1 範例說明：4 對 1 多工器（case 寫法）

## 1. 這個範例在做什麼？

把 [07_Mux2to1_4Ways](../07_Mux2to1_4Ways/Mux2to1_說明.md) 的 2 選 1 擴大成 **4 選 1**（講義第 37~39 頁）：
2 條選擇線 `S1 S0` 可以表示 4 種組合，分別選 A、B、C、D。

```
 A ───►┌─────┐
 B ───►│ 4對1│
 C ───►│ MUX │───► Out
 D ───►│     │
       └─┬─┬─┘
        S1 S0
```

| S1 | S0 | Out |
|----|----|-----|
| 0 | 0 | A |
| 0 | 1 | B |
| 1 | 0 | C |
| 1 | 1 | D |

---

## 2. 程式說明

### Mux4to1_1.v（講義第 38 頁）
```verilog
module Mux4to1_1 (
    input      A, B, C, D,
    input      S1, S0,
    output reg Out
);
    always @(*) begin           // 講義：always @(A or B or C or D or S1 or S0)
        case ({S1, S0})
            2'b00: Out = A;
            2'b01: Out = B;
            2'b10: Out = C;
            2'b11: Out = D;
            default: Out = 1'bx;    // 講義沒有，補上
        endcase
    end
endmodule
```

- `case ({S1, S0})`：把兩條選擇線連結成 2 位元再比對，比寫 4 個 `if ((S1 == 0) & (S0 == 0))` 簡潔。
- **敏感清單要列出所有輸入**：講義列了 6 個（A B C D S1 S0），漏掉任何一個，模擬時那個輸入改變 Out 就不會更新。用 `@(*)` 就不用擔心漏掉。
- **default**：S1、S0 有 x 時 4 個項目都比對不到，補上讓 Out 變成 x，理由見 07 範例第 4 節。

### 其他寫法
| 寫法 | 程式 |
|------|------|
| 巢狀條件運算子 | `assign Out = S1 ? (S0 ? D : C) : (S0 ? B : A);` |
| 向量索引 | `assign Out = data[{S1, S0}];`（`data = {D, C, B, A}`，testbench 的自動檢查就是這樣寫的） |
| 兩個 2 對 1 組成 | 見 [09_Mux4_By_Mux2E](../09_Mux4_By_Mux2E/Mux4x1_By_Mux2to1E_說明.md) |

---

## 3. 測試平台

testbench 用 `D3 D2 D1 D0` 四個 reg 分別接到模組的 `D C B A`：
```verilog
Mux4to1_1 uut (.A(D0), .B(D1), .C(D2), .D(D3), .S1(S1), .S0(S0), .Out(Out));
```
1. 資料固定為 `D C B A = 0101` 和 `1010`，S1 S0 跑 00~11。兩組資料互為反相，每個輸入都會出現 0 和 1。
2. 6 個輸入的 64 種組合全部自動檢查：`Out` 必須等於 `data[{S1, S0}]`。

---

## 4. 預期輸出

```
t=0   S1S0=00  D C B A=0 1 0 1  ->  Out=1     ← 選 A = 1
t=10  S1S0=01  D C B A=0 1 0 1  ->  Out=0     ← 選 B = 0
t=20  S1S0=10  D C B A=0 1 0 1  ->  Out=1     ← 選 C = 1
t=30  S1S0=11  D C B A=0 1 0 1  ->  Out=0     ← 選 D = 0
t=40  S1S0=00  D C B A=1 0 1 0  ->  Out=0
t=50  S1S0=01  D C B A=1 0 1 0  ->  Out=1
t=60  S1S0=10  D C B A=1 0 1 0  ->  Out=0
t=70  S1S0=11  D C B A=1 0 1 0  ->  Out=1
checked 64 inputs, errors = 0
```

### 觀察重點
- Out 永遠等於 S1 S0 選到的那一個（講義第 39 頁的四個圈）。
- `$monitoroff` 關掉監看之後才跑 64 種自動檢查，避免印出 64 行。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| n 條選擇線 | 可以選 2ⁿ 個輸入 |
| `case ({S1, S0})` | 先連結再比對 |
| 敏感清單 | 所有輸入都要列，或用 `@(*)` |
| 自動檢查 | 用 for 迴圈跑遍所有組合，和預期比對 |
