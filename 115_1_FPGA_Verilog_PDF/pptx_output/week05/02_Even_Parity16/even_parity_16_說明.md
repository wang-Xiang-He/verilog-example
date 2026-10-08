# 02_Even_Parity16 範例說明：用 8 位元函數做 16 位元偶同位元產生器（範例練習 6-001）

## 1. 這個範例在做什麼？

**同位元**（parity bit）是最簡單的錯誤偵測：在資料後面多加 1 個位元，讓「1 的總個數」固定是偶數或奇數。

- **偶同位**（even parity）：資料 + 同位元，1 的總數是**偶數** → 同位元 = 所有資料位元 XOR
- 奇同位（odd parity）：總數是奇數 → 見 05_Odd_Parity16

本範例把 16 位元拆成兩個 8 位元，各呼叫一次函數 `even8`，再把兩個結果 XOR：

```
Din[15:8] ──► even8 ──► High ─┐
                              XOR ──► Pout
Din[7:0]  ──► even8 ──► Low  ─┘
```

> 講義第 6 頁的標題寫「奇同位元產生器」，但第 7 頁的程式是 `even_parity_16`、`even8 = ^I`（偶同位）。
> 本範例依程式碼，做的是**偶同位**。

---

## 2. 檔案說明

### even_parity_16.v
```verilog
always @(*) begin
    High_byte = Din[15:8];
    Low_byte  = Din[7:0];
    High = even8(High_byte);
    Low  = even8(Low_byte);
    Pout = High ^ Low;
end

function even8 (input [7:0] I);
    begin
        even8 = ^I;
    end
endfunction
```
- `function even8`：名稱前面沒寫寬度 → 回傳 **1 位元**。
- `^I`：**縮減運算子**，把 `I` 的 8 個位元全部 XOR 成 1 位元（week03 的 06_BitWise）。
- always 裡用**阻隔式 `=`**，一行做完才做下一行，所以 `High_byte` 先有值，下一行的 `even8(High_byte)` 才拿得到。

### even_parity_16_tb.v
講義第 7 頁的 7 筆測試資料。用階層式名稱 `uut.High`、`uut.Low` 把內部訊號也印出來。

---

## 3. 預期輸出

```
t=0   Din=0000 (0000000000000000)  ->  High=0 Low=0  Pout=0
t=10  Din=0a0a (0000101000001010)  ->  High=0 Low=0  Pout=0   ← 共 4 個 1
t=20  Din=24f5 (0010010011110101)  ->  High=0 Low=0  Pout=0   ← 2 + 6 = 8 個
t=30  Din=ad12 (1010110100010010)  ->  High=1 Low=0  Pout=1   ← 5 + 2 = 7 個
t=40  Din=8976 (1000100101110110)  ->  High=1 Low=1  Pout=0   ← 3 + 5 = 8 個
t=50  Din=4536 (0100010100110110)  ->  High=1 Low=0  Pout=1   ← 3 + 4 = 7 個
t=60  Din=a123 (1010000100100011)  ->  High=1 Low=1  Pout=0   ← 3 + 3 = 6 個
```

### 觀察重點
- `High`、`Low` 分別表示高、低位元組中 1 的個數是不是奇數。
- **奇 + 奇 = 偶**（t=40、t=60）：High、Low 都是 1，XOR 後 Pout = 0。
- Din 有奇數個 1 時 Pout = 1，補上去之後總數就變成偶數。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 偶同位元 | `^資料`（全部位元 XOR） |
| 分段計算 | 16 位元同位 = 兩個 8 位元同位再 XOR |
| 1 位元函數 | `function 名稱 (...)`，不寫寬度 |
| 函數重複呼叫 | 同一個函數用在高、低位元組 |
