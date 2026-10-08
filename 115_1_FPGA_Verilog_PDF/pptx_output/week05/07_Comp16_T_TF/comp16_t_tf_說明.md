# 07_Comp16_T_TF 範例說明：任務呼叫函數與任務 — 16 位元比較器（範例練習 6-005）

## 1. 這個範例在做什麼？

比較兩個 16 位元數 A、B 的大小，輸出 3 位元 `Yout`：

| Yout | 意義 |
|------|------|
| 100 | A > B |
| 010 | A = B |
| 001 | A < B |

做法和人比較兩個數字一樣：**從最高位開始比，分出大小就停；相等才往下一段比。**

### 呼叫關係（講義第 30 頁程序圖）
```
        16 位元比較器（主模組 always）
              │ 呼叫 2 次
              ▼
        8 位元比較器 任務 compare8
          │                 │
          ▼                 ▼
 4 位元比較器 任務       4 位元比較器 函數
   compare4_T             compare4_F
  （比高 4 位元）        （比低 4 位元）
```
4 位元比較器故意寫了**任務版**和**函數版**各一個，功能完全相同，用來對照兩種寫法。

---

## 2. 檔案說明

### 主模組
```verilog
always @(*) begin
    A8bit = A[15:8];
    B8bit = B[15:8];
    compare8(A8bit, B8bit, Yout);
    if (Yout == 3'b010) begin        // 高 8 位元相等 → 再比低 8 位元
        A8bit = A[7:0];
        B8bit = B[7:0];
        compare8(A8bit, B8bit, Yout);
    end
end
```

### 任務 compare8
```verilog
task compare8 (
    input  [7:0] I_A,
    input  [7:0] I_B,
    output [2:0] S
);
    reg [3:0] A4bit;
    reg [3:0] B4bit;
    begin
        A4bit = I_A[7:4];
        B4bit = I_B[7:4];
        compare4_T(A4bit, B4bit, S);            // 任務 → 任務
        if (S == 3'b010) begin
            A4bit = I_A[3:0];
            B4bit = I_B[3:0];
            S = compare4_F(A4bit, B4bit);       // 任務 → 函數
        end
    end
endtask
```

### 任務版與函數版的 4 位元比較器
```verilog
// 任務：結果寫到 output S               // 函數：結果寫到函數名稱
task compare4_T (                        function [2:0] compare4_F (
    input  [3:0] I_A,                        input [3:0] I_A,
    input  [3:0] I_B,                        input [3:0] I_B
    output [2:0] S                       );
);                                           begin
    begin                                        if (I_A > I_B)       compare4_F = 3'b100;
        if (I_A > I_B)       S = 3'b100;         else if (I_A == I_B) compare4_F = 3'b010;
        else if (I_A == I_B) S = 3'b010;         else                 compare4_F = 3'b001;
        else                 S = 3'b001;     end
    end                                  endfunction
endtask
```
呼叫方式的差別：
```verilog
compare4_T(A4bit, B4bit, S);        // 任務：一行敘述，結果從第 3 個引數出來
S = compare4_F(A4bit, B4bit);       // 函數：放在等號右邊
```

### 幾個細節
- 三個副程式都有叫 `I_A`、`I_B`、`S` 的引數，但各自獨立，互不影響（都是自己的區域名稱）。
- 任務的 **output 是在任務結束時才複製回去**，所以 `compare8` 裡面可以先讀 `S` 再改寫 `S`。
- 講義把 `compare4_T` 的引數寫成 `input [7:4] I_A`，寬度一樣是 4 位元但編號是 7~4，容易誤會；這裡改成 `[3:0]`。
- 當然，實際設計直接寫 `A > B` 就好；這個範例是為了練習任務 / 函數的階層呼叫。

### comp16_t_tf_tb.v
講義沒有列出測試平台，自行補上：6 筆例子讓差異依序出現在 4 個區段，再用 `$random` 產生 10000 筆自動檢查。

---

## 3. 預期輸出

```
A=0000 B=0000  ->  Yout=010    ← 相等
A=aaaa B=aaaa  ->  Yout=010
A=5000 B=1fff  ->  Yout=100    ← 最高 4 位元 5 > 1，後面再大也沒用
A=1234 B=1934  ->  Yout=001    ← 第 2 段 2 < 9
A=1254 B=1234  ->  Yout=100    ← 第 3 段 5 > 3
A=1234 B=1235  ->  Yout=001    ← 最後一段 4 < 5
check 10000 random inputs: errors = 0
```

### 觀察重點
- 第 3 筆：`5000` 和 `1fff`，最高一段就分出大小，低位元 `fff` 比 `000` 大也不影響結果。
- 後 4 筆的差異分別落在 4 個不同的區段，代表 4 條比較路徑（T、F、T、F）都有被測到。
- 10000 筆亂數和 `A > B` / `A == B` 的結果比對 0 個錯誤。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 任務可以呼叫 | 任務和函數 |
| 函數可以呼叫 | 只有函數 |
| 任務呼叫 | `t(in1, in2, out);` |
| 函數呼叫 | `out = f(in1, in2);` |
| 階層式比較 | 高位先比，相等才比低位 |
| `$random` | 產生 32 位元亂數，用來做大量自動測試 |
