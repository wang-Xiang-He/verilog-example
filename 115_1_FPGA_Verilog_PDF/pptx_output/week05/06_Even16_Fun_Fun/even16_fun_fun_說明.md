# 06_Even16_Fun_Fun 範例說明：函數呼叫函數（範例練習 6-004）

## 1. 這個範例在做什麼？

函數裡面可以再呼叫別的函數。本範例把 02_Even_Parity16 改成三層（講義第 25 頁程序圖）：

```
16 位元偶同位產生器（主模組 always）
        │ 呼叫 ▲ 回傳
        ▼      │
   8 位元偶同位函數 even8
        │ 呼叫 ▲ 回傳
        ▼      │
   4 位元偶同位函數 even4
```

- 主模組把 16 位元分成 `High_byte`、`Low_byte`，各呼叫一次 `even8`
- `even8` 把 8 位元再分成兩個 4 位元，各呼叫一次 `even4`
- `even4` 用縮減 XOR 算出 4 位元的偶同位元，一層一層傳回去

---

## 2. 檔案說明

### even16_fun_fun.v
```verilog
always @(*) begin
    High_byte = Din[15:8];
    Low_byte  = Din[7:0];
    High = even8(High_byte);
    Low  = even8(Low_byte);
    Pout = High ^ Low;
end

function even8 (input [7:0] I8);
    begin
        even8 = even4(I8[7:4]) ^ even4(I8[3:0]);
    end
endfunction

function even4 (input [3:0] I4);
    begin
        even4 = ^I4;
    end
endfunction
```
- `even8` 在一個運算式裡呼叫 `even4` **兩次**，結果直接 XOR。
- `even4` 寫在 `even8` 的後面也沒關係，函數的宣告順序不影響呼叫。
- 整個電路展開後就是 16 個位元全部 XOR：`Pout = ^Din`。
  所以這個範例的重點不是省硬體，而是示範**把大問題拆成小問題**的寫法。

### 規則回顧
- function 可以呼叫 function ✔
- function **不能**呼叫 task ✘（task 可能有延遲，function 不允許）
- task 可以呼叫 task 和 function ✔（見 07_Comp16_T_TF）

### even16_fun_fun_tb.v
用和 02 相同的 7 筆資料，再把 65536 種輸入全部和 `^Din` 比對。
測試平台自己也用了一個**有引數的任務** `show(16'h0a0a)`，把「給值、等待、顯示」包起來重複使用。

---

## 3. 預期輸出

```
Din=0000 (0000000000000000)  ->  High=0 Low=0  Pout=0
Din=0a0a (0000101000001010)  ->  High=0 Low=0  Pout=0
Din=24f5 (0010010011110101)  ->  High=0 Low=0  Pout=0
Din=ad12 (1010110100010010)  ->  High=1 Low=0  Pout=1
Din=8976 (1000100101110110)  ->  High=1 Low=1  Pout=0
Din=4536 (0100010100110110)  ->  High=1 Low=0  Pout=1
Din=a123 (1010000100100011)  ->  High=1 Low=1  Pout=0
check all 65536 inputs against ^Din: errors = 0
```

### 觀察重點
- 7 筆結果和 02_Even_Parity16 **完全相同**：多拆一層不會改變功能。
- 65536 種輸入和 `^Din` 比對 0 個錯誤。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 巢狀函數呼叫 | 函數裡可以呼叫其他函數 |
| 宣告順序 | 被呼叫的函數可以寫在後面 |
| 階層式拆解 | 16 → 8 → 4 位元，每層做同樣的事 |
| 測試平台的任務 | 把重複的測試步驟包成 task |
