# 01_Func_AS 範例說明：function（函數）基本用法

## 1. 這個範例在做什麼？

同一段程式如果要在好幾個地方重複使用，可以寫成**函數**（function），需要時再呼叫，不必重打一次（講義第 2 頁）。

本範例是一個 4 位元運算器，「減法 / 加 1 / 減 1」這段邏輯寫成函數 `Sub_Inc_Dec`，被呼叫**兩次**（引數順序不同）：

| Add | Switch | Sub | Inc | 結果 c |
|-----|--------|-----|-----|--------|
| 1 | – | – | – | a + b |
| 0 | 1 | 1 | – | a − b |
| 0 | 1 | 0 | 1 | a + 1 |
| 0 | 1 | 0 | 0 | a − 1 |
| 0 | 0 | 1 | – | b − a |
| 0 | 0 | 0 | 1 | b + 1 |
| 0 | 0 | 0 | 0 | b − 1 |

---

## 2. 檔案說明

### Func_AS.v
```verilog
always @(*) begin
    if (Add)
        c = a + b;
    else if (Switch)
        c = Sub_Inc_Dec(a, b, Sub, Inc);
    else
        c = Sub_Inc_Dec(b, a, Sub, Inc);     // a、b 對調
end

function [3:0] Sub_Inc_Dec (
    input [3:0] a,
    input [3:0] b,
    input       Sub,
    input       Inc
);
    begin
        if (Sub)       Sub_Inc_Dec = a - b;
        else if (Inc)  Sub_Inc_Dec = a + 1'b1;
        else           Sub_Inc_Dec = a - 1'b1;
    end
endfunction
```

### function 的規則（講義第 2 頁）
- 用 `function` … `endfunction` 包起來，寫在**模組裡面**（`endmodule` 之前）。
- `function [3:0] 名稱`：`[3:0]` 是**回傳值的寬度**；不寫就是 1 位元。
- **回傳值存在和函數同名的變數裡**：`Sub_Inc_Dec = a - b;` 就是「回傳 a − b」。
- 至少要有 **1 個 input**，不能有 output / inout。
- 裡面**不能有延遲（`#`）或事件控制（`@`）**，所以函數一定是組合邏輯，而且不花模擬時間。
- 函數可以寫在呼叫它的 always **後面**，順序沒有關係。

### 引數順序（講義第 3 頁的提醒）
呼叫時是**依位置**對應：第 1 個引數給函數的第 1 個 input，以此類推。
函數裡的 `a`、`b` 是函數自己的區域名稱，和模組的 `a`、`b` 無關，
所以 `Sub_Inc_Dec(b, a, Sub, Inc)` 是把模組的 `b` 傳給函數的 `a`。
如果寫成 `Sub_Inc_Dec(a, Sub, b, Inc)`，編譯器可能不會報錯，但算出來的東西是錯的。

### Verilog-2001 寫法
講義（1995）把輸入分行宣告：`function [3:0] Sub_Inc_Dec; input [3:0] a, b; input Sub, Inc;`
Verilog-2001 可以像模組的埠一樣直接寫在括號裡，兩者功能相同。

---

## 3. 預期輸出

```
t=0   a=15 b=3  Add=1 Sub=0 Inc=0 Switch=0  ->  c=0010 (2)    ← 15+3=18，溢位剩 2
t=10  a=15 b=3  Add=0 Sub=1 Inc=0 Switch=1  ->  c=1100 (12)   ← a-b
t=20  a=15 b=3  Add=0 Sub=1 Inc=0 Switch=0  ->  c=0100 (4)    ← b-a = -12
t=30  a=15 b=3  Add=0 Sub=0 Inc=1 Switch=1  ->  c=0000 (0)    ← a+1 = 16，溢位
t=40  a=15 b=3  Add=0 Sub=0 Inc=1 Switch=0  ->  c=0100 (4)    ← b+1
t=50  a=15 b=3  Add=0 Sub=0 Inc=0 Switch=1  ->  c=1110 (14)   ← a-1
t=60  a=15 b=3  Add=0 Sub=0 Inc=0 Switch=0  ->  c=0010 (2)    ← b-1
```

### 觀察重點
- 前三行的 `0010`、`1100`、`0100` 就是講義第 5 頁波形上圈起來的三個值。
- t=20：3 − 15 = −12，4 位元 2 的補數是 `0100`（16 − 12 = 4）。
- 同一個函數被呼叫兩次，合成時會產生**兩份**硬體（函數不是「共用一個電路」，而是把內容展開貼上）。

---

## 4. 補充：把函數獨立成一個檔案（`include）

講義沒有這部分，額外補充。函數可以搬到獨立的檔案，再用 `` `include `` 引入。

| 檔案 | 內容 |
|------|------|
| `Sub_Inc_Dec.vh` | 只有 `function ... endfunction`，**沒有 module** |
| `Func_AS_inc.v` | 模組 `Func_AS_inc`，用 `` `include `` 引入函數 |
| `Func_AS_inc_tb.v` | 測試平台（測試內容和 `Func_AS_tb.v` 相同） |
| `run_inc.do` | 執行：`do run_inc.do` |

### Func_AS_inc.v
```verilog
module Func_AS_inc ( ... );
    always @(*) begin
        if (Add)          c = a + b;
        else if (Switch)  c = Sub_Inc_Dec(a, b, Sub, Inc);
        else              c = Sub_Inc_Dec(b, a, Sub, Inc);
    end

    `include "Sub_Inc_Dec.vh"
endmodule
```

`` `include `` 的意思是：編譯前把那個檔案的內容**原樣貼**到這一行的位置。
所以它和把函數直接寫在模組裡完全等價，模擬輸出也和第 3 節一模一樣。

### 三個注意事項
1. **`` `include `` 要寫在 `module` 和 `endmodule` 之間。**
   Verilog-2001 規定函數必須屬於某個模組，貼的位置不對就會編譯錯誤。
2. **`.vh` 檔不能單獨編譯。** `vlog` 只列 `Func_AS_inc.v Func_AS_inc_tb.v`。
   如果把 `Sub_Inc_Dec.vh` 也列進去，ModelSim 會報錯：
   `(vlog-2155) Global declarations are illegal in Verilog 2001 syntax.`
   用選單編譯時也一樣，只選兩個 `.v`。
3. **每個要用這個函數的模組都要各自 include 一次。**
   這不是「多個模組共用同一份函數」，而是每個模組各貼一份。

### 其他細節
- 開頭的符號是**反引號** `` ` ``（鍵盤左上角、數字 1 左邊），和 `` `timescale `` 一樣，不是單引號 `'`。
- 副檔名 `.vh`（Verilog header）只是習慣，用來提醒「這是給別人 include 的片段」；用 `.v` 也能運作，但容易被誤拿去編譯。
- `.vh` 要和引入它的 `.v` 放在同一個資料夾；放在別處的話，`vlog` 要加 `+incdir+路徑`。
- 模組名稱取為 `Func_AS_inc`，是為了和 `Func_AS` 同時存在同一個 `work` 工作庫而不互相覆蓋。
- 想要真正「寫一次、所有模組共用」要用 SystemVerilog 的 `package`，已超出 Verilog-2001 的範圍。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| `function` … `endfunction` | 把重複的組合邏輯包成函數 |
| 回傳值 | 指定給和函數同名的變數 |
| `[3:0]` 寫在名稱前 | 回傳值寬度，省略為 1 位元 |
| 引數 | 依位置對應，只能有 input |
| 限制 | 不能有 `#`、`@`，不能呼叫 task |
