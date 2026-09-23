# Verilog 初學者入門

> 給完全沒寫過 Verilog 的人。看完這份，再回去讀講義的範例就不會卡住。
> 文件裡的程式碼都經過實際編譯模擬驗證，標示的輸出就是真的跑出來的結果。

---

## 目錄

1. [最重要的觀念：這不是程式語言](#1-最重要的觀念這不是程式語言)
2. [模組與埠](#2-模組與埠)
3. [資料型態：wire 和 reg](#3-資料型態wire-和-reg)
4. [數值與向量](#4-數值與向量)
5. [assign：組合邏輯](#5-assign組合邏輯)
6. [always：組合邏輯與時序邏輯](#6-always組合邏輯與時序邏輯)
7. [`=` 與 `<=` 的差別（重點）](#7--與--的差別重點)
8. [運算子總表](#8-運算子總表)
9. [條件判斷：if / case](#9-條件判斷if--case)
10. [迴圈：for / while / repeat / forever](#10-迴圈for--while--repeat--forever)
11. [沒有 break、continue、return 怎麼辦](#11-沒有-breakcontinuereturn-怎麼辦)
12. [function 與 task](#12-function-與-task)
13. [模組的實例化與 parameter](#13-模組的實例化與-parameter)
14. [testbench 的基本結構](#14-testbench-的基本結構)
15. [可合成 vs 不可合成速查](#15-可合成-vs-不可合成速查)
16. [怎麼從需求寫出電路](#16-怎麼從需求寫出電路)
17. [初學者常犯的錯](#17-初學者常犯的錯)
18. [編譯錯誤訊息對照](#18-編譯錯誤訊息對照)
19. [練習順序建議](#19-練習順序建議)

---

## 1. 最重要的觀念：這不是程式語言

C、Python 是**一行一行依序執行**的指令。Verilog 不是，它是在**描述一塊電路長什麼樣子**。

```verilog
assign x = a & b;
assign y = c | d;
```

這兩行**沒有先後順序**，它們是同時存在的兩個邏輯閘。上下對調，結果完全一樣。電路做好之後，所有部分都是**同時、持續**在運作的。

這個觀念會解釋後面所有奇怪的規定：

| 現象 | 原因 |
|---|---|
| 除法 `/` 和取餘數 `%` 不能合成 | 沒有便宜的硬體可以做除法 |
| `initial`、`#10` 延遲不能合成 | 真實電路裡沒有「等 10 奈秒」這種零件 |
| 為什麼要分 wire 和 reg | 電線和儲存元件在硬體上是兩種不同的東西 |
| 為什麼有 `=` 和 `<=` 兩種賦值 | 對應到組合邏輯和正反器兩種電路 |

**寫之前先想「這會變成什麼電路」**，而不是「這段程式會怎麼跑」。

---

## 2. 模組與埠

模組（module）就是一顆 IC，埠（port）就是它的接腳。

```verilog
module FullAdd (        // 模組名稱
    input  a,           // 輸入腳
    input  b,
    input  Carry_In,
    output Sum,         // 輸出腳
    output Carry_Out
);
    // 電路內容寫在這裡
endmodule               // 結束，不加分號
```

### 三種埠

| 關鍵字 | 方向 | 說明 |
|---|---|---|
| `input` | 輸入 | 訊號從外面進來，模組內**只能讀不能改** |
| `output` | 輸出 | 訊號送出去 |
| `inout` | 雙向 | 少用，通常用在外部接腳 |

### 兩種寫法

講義用的是舊寫法（Verilog-1995），先列埠名，再另外宣告方向：

```verilog
module FullAdd (a, b, Carry_In, Sum, Carry_Out);
    input  a, b, Carry_In;
    output Sum, Carry_Out;
    // ...
endmodule
```

新寫法（Verilog-2001）把方向直接寫在括號裡，比較清楚，兩種都合法：

```verilog
module FullAdd (
    input  a, b, Carry_In,
    output Sum, Carry_Out
);
```

### 註解怎麼寫

```verilog
// 這是單行註解，從 // 到該行結束

/* 這是多行註解
   可以跨好幾行 */
```

⚠️ 多行註解**不能巢狀**，`/* 外面 /* 裡面 */ 外面 */` 會出錯。

### 識別字與關鍵字

識別字（identifier）就是你自己取的名字：模組名、訊號名、實例名。

| 規則 | 說明 |
|---|---|
| 第一個字元 | 必須是**英文字母**或底線 `_`，不能是數字 |
| 後面的字元 | 英文字母、數字、底線 `_`、錢字號 `$` |
| **大小寫有分別** | `Even` 和 `even` 是兩個不同的訊號 |
| 關鍵字一律小寫 | `module`、`wire`、`always` 都不能寫成大寫 |
| 不能用關鍵字當名字 | 見下面的例子 |

Verilog 的關鍵字比想像中多，有些名字看起來很普通卻是保留字，例如 **`small`**、`large`、`medium`、`time`、`event`、`force`、`disable`、`table`、`cell`、`config`、`signed`。

```verilog
reg [3:0] small;     // ❌ small 是關鍵字（電荷強度用的），編譯器會報 syntax error
reg [3:0] narrow;    // ✅ 換個名字就好
```

遇到「某一行明明看起來沒問題卻說 syntax error」，先懷疑是不是用到了關鍵字。

### 分號的規則

| 要加分號 | 不加分號 |
|---|---|
| 每個宣告：`wire y;` | `module` 的埠列表結尾 `);` **要**加 |
| 每個 `assign`、每個賦值敘述 | `endmodule`、`end`、`endcase`、`endfunction` |
| 實例化的結尾 `);` | `begin` |
| | `always @(*)` 和 `if (...)` 這些條件後面 |

```verilog
always @(*) begin        // 這裡沒有分號
    if (sel)             // 這裡也沒有
        y = a;           // 這裡有
end                      // 這裡沒有
```

### 檔案與模組的關係

- 一個 `.v` 檔可以放很多個模組，但**慣例是一個檔案放一個模組**。
- **檔名和模組名取一樣**，例如 `FullAdd` 模組放在 `FullAdd.v`。這不是語法規定，但找檔案會方便很多，有些工具也預設這樣找。
- 檔名和資料夾路徑**不要用中文或空白**，很多工具會出問題。

### 模組裡面可以放哪些東西

這是全貌。後面每一節都是在細講其中一項，先在這裡對一下位置：

| 可以放什麼 | 用途 | 能不能合成 | 詳見 |
|---|---|---|---|
| **宣告**：`wire`、`reg`、`parameter` | 宣告訊號和常數 | — | 第 3 節 |
| **`assign`** | 組合邏輯的連續賦值 | ✅ | 第 5 節 |
| **`always` 區塊** | 組合邏輯或時序邏輯 | ✅ | 第 6 節 |
| **`initial` 區塊** | 從時間 0 開始執行一次，**只能用在 testbench** | ❌ | 第 14 節 |
| **子模組實例化** | 把別的模組當零件用 | ✅ | 第 13 節 |
| **`function` / `task` 定義** | 把重複的邏輯包起來 | function ✅ / task ❌ | 第 12 節 |
| **內建邏輯閘**：`and`、`not`… | 邏輯閘層次的描述 | ✅ | 講義的 `07_Deco2_4g` |

一個模組的骨架大概長這樣（以下這段是為了展示位置，實際不會全部一起用）：

```verilog
module Skeleton (input clk, sel, a, b, output y, output reg z);

    parameter WIDTH = 4;          // 常數
    wire       temp;              // 訊號宣告
    reg  [3:0] count;

    assign temp = a & b;          // assign：組合邏輯
    assign y    = sel ? temp : b;

    always @(posedge clk) begin   // always：時序邏輯
        count <= count + 1;
    end

    always @(*) begin             // always：組合邏輯
        z = temp | sel;
    end

    initial begin                 // initial：只有模擬會執行
        count = 4'b0;
    end

    Sub u_sub (.in(a), .out(w));  // 實例化子模組

    function [3:0] twice;         // function 定義
        input [3:0] x;
        twice = x << 1;
    endfunction

endmodule
```

這些東西**彼此之間沒有先後順序**，上下對調結果一樣（除了宣告要在使用之前）。

### ⚠️ 敘述只能寫在「程序區塊」裡面

`if`、`case`、`for`、`while`，以及 `=`、`<=` 這些賦值，都叫**敘述（statement）**。它們**不能直接寫在模組裡**，一定要包在下面四種東西之一的裡面：

| 程序區塊（procedural block） | 什麼時候執行 | 用在哪 |
|---|---|---|
| `always @(...)` | 敏感清單的條件成立時，**重複執行** | 電路本體 |
| `initial` | 從時間 0 開始，**執行一次** | testbench |
| `function` | 被呼叫時 | 兩者皆可 |
| `task` | 被呼叫時 | 主要在 testbench |

```verilog
module M (input a, b, sel, output reg y);

    if (sel) y = a;          // ❌ 錯！if 直接寫在模組裡

    always @(*) begin        // ✅ 對！包在 always 裡面
        if (sel) y = a;
        else     y = b;
    end

endmodule
```

反過來，`assign` 和實例化**只能寫在模組裡、程序區塊外面**，不能塞進 `always` 或 `initial`。

一句話總結：**`assign` 在外面，`if` / `case` / `for` 在裡面。**

### 檔案開頭的 `timescale

```verilog
`timescale 1ns/1ps
```

意思是「`#1` 代表 1 奈秒，模擬精度到 0.001 奈秒」。開頭那個符號是**反引號**（鍵盤左上角、Esc 下面那一顆，和波浪號同一鍵），不是單引號。

---

## 3. 資料型態：wire 和 reg

初學者最容易卡住的地方。

### wire（線）

就是一條電線。它**不會記憶**任何東西，值完全由「正在驅動它的東西」決定。驅動源一消失，值就沒了。

```verilog
wire y;
assign y = a & b;    // y 永遠等於 a AND b
```

### reg（暫存器）

像一個**會保存數值的盒子**。寫進去之後會一直維持那個值，直到下次被改寫。

```verilog
reg q;
always @(posedge clk)
    q <= d;          // 只有時脈正緣才更新，其他時間保持不變
```

### 怎麼選？只看一件事：在哪裡被賦值

| 這個訊號在哪裡被賦值 | 宣告成 |
|---|---|
| 用 `assign` | `wire` |
| 在 `always` 或 `initial` 裡面 | `reg` |
| 模組的 `input` | **一定是 wire**，不能寫成 reg |
| 模組的 `output` | 用 `assign` 驅動 → wire；在 `always` 裡驅動 → reg |
| 接到子模組輸出的內部連線 | `wire` |

### ⚠️ 最容易誤會的一點

`reg` 這個字看起來像暫存器（register），但**它不一定會變成真的暫存器**。

```verilog
reg y;
always @(*)          // 組合邏輯，沒有時脈
    y = a & b;       // 這裡的 reg 只會合成出一個 AND 閘，沒有任何記憶元件
```

`reg` 純粹是「在 always/initial 裡被賦值」的語法要求。會不會產生記憶元件，是由 `always` 的敏感清單決定的，不是由 `reg` 決定。

### 埠為什麼沒寫型別也可以：因為有預設值

```verilog
input a
```

這是簡寫，完整寫法是：

```verilog
input wire a
```

**埠沒有指定型別時，預設就是 1 位元的 `wire`。** `wire` 這個字可以省略，寫了也不會錯，多數人習慣省略。

| 你寫的 | 編譯器實際看到的 |
|---|---|
| `input a` | `input wire a` |
| `output Sum` | `output wire Sum` |
| `input [3:0] a` | `input wire [3:0] a` |

### input 一定是 wire，沒有例外

```verilog
input reg a;     // ❌ 編譯錯誤
```

**原因是硬體上的**：input 的值是外面的電路在驅動的，這個模組只能把線接進來讀取，沒有權力改變它。`reg` 代表「這個東西的值由我寫入並保存」，和 input 的本質互相矛盾。

`inout`（雙向埠）同理，也一定是 wire。

### output 可以是 wire 或 reg

判斷方式只有一個：**這個 output 在模組內是被誰賦值的？**

| 驅動方式 | output 的型別 |
|---|---|
| 用 `assign` 驅動 | `wire`（預設，不用寫） |
| 接到子模組的輸出 | `wire`（預設，不用寫） |
| 在 `always` 或 `initial` 裡賦值 | **必須寫 `reg`** |

**情況 A：用 assign → 什麼都不用加**

```verilog
module FullAdd (
    input  a, b, Carry_In,
    output Sum, Carry_Out          // 預設就是 wire
);
    assign {Carry_Out, Sum} = a + b + Carry_In;
endmodule
```

**情況 B：在 always 裡賦值 → 要寫 reg**

```verilog
module Sign_Extend (
    input             SignExtend,
    input  [7:0]      Word,
    output reg [15:0] Double       // 在 always 裡被賦值，必須宣告成 reg
);
    always @(*) begin
        if (SignExtend)
            Double = {{8{Word[7]}}, Word};
        else
            Double = {8'b0, Word};
    end
endmodule
```

漏掉 `reg` 時，編譯器會出現類似這樣的訊息：

```
Illegal output or inout port specification for "Double"
Variable 'Double' is not a valid left-hand side of a procedural assignment
```

看到這類訊息，通常就是忘了加 `reg`。

### 舊寫法（講義用的那種）

Verilog-1995 的舊格式要把型別另外宣告一行：

```verilog
module Sign_Extend (SignExtend, Word, Double);
    input         SignExtend;
    input  [7:0]  Word;
    output [15:0] Double;
    reg    [15:0] Double;          // 另外補這一行
    // ...
endmodule
```

所以講義裡看到 `output [7:0] q;` 下面又接一行 `reg [7:0] q;`，**不是重複宣告**，而是舊寫法必須分兩行：第一行說方向，第二行說型別。新寫法把兩件事合併成 `output reg [7:0] q`。

### 另一個預設：沒宣告過的名字會自動變成 wire

```verilog
wire Carry_Out1;
assign Carry_Out1 = ...;
assign Carry_Otu1 = ...;    // 打錯字，但編譯照樣通過！
```

Verilog 遇到沒宣告過的識別字，會**自動建立一條 1 位元的 wire**，這叫**隱含網路（implicit net）**。好處是方便，壞處是**打錯字不會被抓到**，變成很難找的 bug。

多數編譯器會給一個警告：

```
warning: implicit definition of wire 'Carry_Otu1'.
```

**所以編譯訊息要看到 `Errors: 0, Warnings: 0` 才算真的乾淨。**

在檔案最上面加這一行可以關掉這個行為，強迫所有訊號都要先宣告：

```verilog
`default_nettype none
```

不過它會影響後面所有檔案，初學階段先知道有這回事就好。

### wire / reg 總表

| 位置 | 能不能是 wire | 能不能是 reg | 預設 |
|---|---|---|---|
| `input` | ✅ | ❌ | wire |
| `inout` | ✅ | ❌ | wire |
| `output`（用 assign 驅動） | ✅ | ❌ | wire |
| `output`（在 always 裡驅動） | ❌ | ✅ | 要自己寫 `reg` |
| 模組內部訊號（assign 驅動） | ✅ | ❌ | 要自己宣告 `wire` |
| 模組內部訊號（always 驅動） | ❌ | ✅ | 要自己宣告 `reg` |
| testbench 裡要餵給電路的訊號 | ❌ | ✅ | 在 `initial` 裡賦值，所以是 `reg` |
| testbench 裡從電路接出來的訊號 | ✅ | ❌ | 由電路驅動，所以是 `wire` |

### 其他型態

| 型態 | 用途 |
|---|---|
| `integer` | 32 位元有號整數，通常只用在 testbench 的迴圈計數（例如 `for` 的 i） |
| `parameter` | 模組內的常數，可以在實例化時改寫 |
| `localparam` | 模組內的常數，不能被外面改 |

```verilog
parameter SIZE = 8;
input [SIZE-1:0] a;      // 改 SIZE 一個地方，整個模組的寬度就跟著變
```

---

## 4. 數值與向量

### 數值的寫法

```verilog
4'b1010      // 4 位元、二進位
8'd255       // 8 位元、十進位
16'h89Ab     // 16 位元、十六進位
9'o377       // 9 位元、八進位
1'b0         // 1 位元的 0
```

格式是 `位元數'進位制數值`。硬體的線有固定寬度，所以位元數很重要。

其他寫法：

| 寫法 | 意思 |
|---|---|
| `25` | 不寫位元數，預設 32 位元十進位 |
| `12'b1010_1111_0101` | 底線只是方便閱讀，不影響數值 |
| `4'bx` | x = 未知值（unknown），常見於還沒初始化的 reg |
| `4'bz` | z = 高阻抗（high impedance），沒有任何東西在驅動 |
| `8'b11??11??` | `?` 等同 z，多用在 `casez` 裡表示「不在乎」 |
| `-8'd79` | 負號寫在最前面，存成 2 的補數 |

### 向量（多位元訊號）

```verilog
input  [3:0] a;      // 4 條線：a[3] a[2] a[1] a[0]
output [7:0] q;      // 8 位元
wire   [15:0] bus;
```

- `a[3]` 是最高位（MSB，Most Significant Bit）
- `a[0]` 是最低位（LSB，Least Significant Bit）
- `a[1:0]` 取最低 2 位元（這叫 part select，位元切片）

寫 `[3:0]` 還是 `[0:3]` 都合法，但**一律用 `[3:0]`**，這是通用慣例。

---

### 大括號 `{ }` 的兩種用法

大括號在 Verilog 裡有**兩種完全不同的用途**，而且常常巢狀在一起，是初學者最難讀懂的寫法之一。

**用途 1：連結（Concatenation）`{ , }`** — 有逗號，把多個訊號從左到右接成一個更寬的值：

```verilog
a = 4'b1010;  b = 4'b0011;

{a, b}           // 10100011      （8 位元）
{a, 2'b00, b}    // 1010000011    （10 位元，中間插入常數）
```

**用途 2：重複（Replication）`{n{ }}`** — 沒有逗號，而是「數字 + 大括號」，把裡面的東西重複 n 次：

```verilog
{4{1'b1}}        // 1111          （把 1 重複 4 次）
{2{a}}           // 10101010      （a 整組重複 2 次）
```

⚠️ 重複次數 n **必須是常數**，不能是訊號。硬體的線寬在做出來時就固定了，不能執行中改變。

### 讀懂 `{{8{Word[7]}}, Word}`

講義的 Sign_Extend 用了這一行，兩種用法剛好都出現而且貼在一起：

```verilog
Double = {{8{Word[7]}}, Word};
```

像剝洋蔥一樣由內往外看（以 `Word = 11000011` 為例）：

| 層 | 寫法 | 作用 | 結果 |
|---|---|---|---|
| 最內 | `Word[7]` | 取最高位元 | `1` |
| 中間 | `{8{Word[7]}}` | **重複** 8 次 | `11111111` |
| 最外 | `{ ..., Word}` | **連結**前面 8 位元和原本的 Word | `1111111111000011` |

**外層是連結、內層是重複**，所以會出現 `{{` 這種看起來像多打一個括號的寫法，其實少一個就錯了。

### 為什麼要這樣寫：符號擴展

目的是把 8 位元的有號數擴展成 16 位元，而且**數值不能變**。2 的補數的規則是「高位補原本的最高位元」，而 `Word[7]` 就是符號位元：

| Word | Word[7] | 補什麼 | Double | 十進位 |
|---|---|---|---|---|
| `11000011`（-61） | 1 | 8 個 1 | `1111111111000011` | 還是 -61 |
| `00001111`（15） | 0 | 8 個 0 | `0000000000001111` | 還是 15 |

如果無腦補 0，負數會變成很大的正數，所以才需要 `{8{Word[7]}}` 這種寫法。

### 講義其他用到大括號的地方

| 寫法 | 出現在 | 作用 |
|---|---|---|
| `{Carry_Out, Sum} = a + b + Carry_In` | FullAdd | 接成 2 位元，一次接住「進位 + 和」 |
| `{q[6:0], q[7]}` | Rotate_Data | 向左旋轉 1 位元：`10000001` → `00000011` |
| `{byte2, byte1}` | Concate | 交換高低 4 位元 |
| `{8'b0, Word}` | Sign_Extend | 無號擴展，高位補 0 |
| `{b, a}` | 解碼器 | 把兩個 1 位元輸入接成 2 位元，餵給 `case` |

⚠️ 連結的左邊也可以放在等號左側來接收結果，這在加法器很常用：

```verilog
assign {Carry_Out, Sum} = a + b + Carry_In;   // 把 2 位元結果拆給兩個訊號
```

### 位元寬度不合會怎樣

Verilog **不會報錯**，會自動處理，所以要自己注意：

| 情況 | 處理方式 |
|---|---|
| 寬的塞進窄的 | **截掉高位元** |
| 窄的塞進寬的 | **高位元補 0** |

實際結果：

```verilog
reg [3:0] narrow;
reg [7:0] big;

narrow = 8'b1111_0011;    // 結果 narrow = 0011（高 4 位被截掉）
big    = 4'b1011;         // 結果 big = 00001011（高 4 位補 0）
```

### 溢位（overflow）

寬度不夠時，加法的進位會直接消失：

```verilog
reg [3:0] narrow;
narrow = 4'b1111;
narrow = narrow + 1;      // 結果 0000，不是 10000
```

這就是為什麼 FullAdd 要特地寫成 `{Carry_Out, Sum}`：把進位另外接一條線出來，才不會丟掉。設計加法器時，**輸出通常要比輸入多 1 位元**。

### 有號數與無號數

`reg`、`wire` 預設都是**無號數（unsigned）**。同樣的位元，用不同方式解讀會得到不同的值：

```verilog
reg signed [7:0] s8;
reg        [7:0] u8;

s8 = -8'd5;    // s8 = 11111011，印出來是 -5
u8 = -8'd5;    // u8 = 11111011，位元完全一樣，但印出來是 251
```

位元是同一組，差別只在「怎麼解讀最高位元」。需要負數運算時，宣告成 `signed`，或用 `$signed(u8)` 臨時當成有號數來看。

### 表達式的寬度是由整個式子決定的

這是初學者常覺得神奇的地方。講義的 Decoder 寫成：

```verilog
output [7:0] Out;
assign Out = 1'b1 << in;      // in 是 3 位元
```

`1'b1` 明明只有 1 位元，左移 3 次不是應該變成 0 嗎？不會。Verilog 會看**整個等號兩邊**，取最寬的那個（這裡是左邊的 8 位元）當作運算寬度，所以 `1'b1` 會先被當成 8 位元來算，左移之後是 `00001000`。

這叫**上下文決定寬度（context-determined width）**。方便，但也容易搞混，所以**寬度重要的時候就明確寫出來**，例如 `8'b1 << in`。

### x 和 z 會傳染

只要運算裡有一個位元是 x，結果往往整個都變成 x：

```verilog
narrow = 4'bxx01;
narrow + 4'b0          // 結果是 xxxx，不是 xx01
```

波形上看到一整條紅色的 x，通常是往回追某個訊號忘了給初始值，或是某個 output 根本沒被驅動。

`if` 條件的值是 x 或 z 時，一律視為**假**，會走 `else` 那一邊。

### 記憶體陣列

多個同寬度的暫存器排成一排，就是記憶體：

```verilog
reg [7:0] mem [0:255];     // 256 個位置，每個 8 位元

mem[0] = 8'hA1;            // 用索引存取
data   = mem[addr];
```

`[7:0]` 是每個位置的寬度，`[0:255]` 是有幾個位置，兩個中括號的意義不同。

⚠️ 陣列**不能整包拿來運算**，只能一次存取一個位置。`mem = 0;` 是錯的，要用迴圈一個一個清。

---

## 5. assign：組合邏輯

```verilog
assign Sum = a ^ b;
```

`assign` 叫**連續賦值（continuous assignment）**。它的意思不是「把值存進 Sum」，而是「**Sum 這條線永遠等於右邊的算式**」。

右邊任何一個輸入一變，左邊**立刻**跟著變，不需要誰來執行這一行。這就是**組合邏輯（combinational logic）**：沒有記憶，輸出只由當下的輸入決定。

```verilog
assign out = Sel ? a : b;                      // 多工器
assign {Carry_Out, Sum} = a + b + Carry_In;    // 左邊用 {} 接成 2 位元來接收結果
assign y = ~(a & b);                           // NAND 閘
```

規則：
- 左邊**一定是 wire**
- 一條 wire 只能被一個 `assign` 驅動（兩個 assign 驅動同一條線會打架，變成 x）
- `assign` 只能寫在模組裡、`always` 外面，**不能寫在 `always` 或 `initial` 裡面**

常見錯誤：

```verilog
reg y;
assign y = a & b;         // ❌ assign 的左邊不能是 reg

wire y;
always @(*) y = a & b;    // ❌ always 裡面的左邊不能是 wire

wire y;
assign y = a;
assign y = b;             // ❌ 同一條線被兩個 assign 驅動，結果是 x
```

---

## 6. always：組合邏輯與時序邏輯

```verilog
always @(敏感清單)
begin
    // 內容
end
```

`@()` 裡面叫**敏感清單（sensitivity list）**，列出「發生什麼事的時候要重新執行底下的內容」。`begin`/`end` 相當於其他語言的大括號，只有一行時可以省略。

**敏感清單決定了會合成出什麼電路**，這是 always 最關鍵的地方：

### 寫法 A：組合邏輯

```verilog
always @(*)              // * 表示「裡面用到的所有訊號」，自動列出
begin
    if (sel)
        y = a;
    else
        y = b;
end
```

- 等同於 `assign y = sel ? a : b;`，但可以寫 `if`、`case` 這種複雜判斷
- 舊寫法是 `always @(a or b or sel)`，手動列出每一個輸入。漏列會造成模擬和實際電路不一致，所以**新程式一律用 `@(*)`**
- 賦值用 `=`

**為什麼組合邏輯用 `=`**：組合邏輯是在描述訊號穿過一連串邏輯閘，中間常常要依序算完好幾步。`=` 的「算完馬上生效、再往下一行」正好符合這種串接：

```verilog
always @(*) begin
    temp = a & b;        // 先算這個
    y    = temp | c;     // 用剛算好的 temp
end
```

這裡若改用 `<=`，第二行讀到的 temp 會是舊值，結果就錯了。詳細對照見第 7 節。

### 寫法 B：時序邏輯（會產生正反器）

```verilog
always @(posedge clk)    // 時脈由 0 變 1 的瞬間
begin
    q <= d;
end
```

- `posedge` = 正緣（positive edge），`negedge` = 負緣
- 這會合成出**正反器（flip-flop）**，也就是有記憶的元件
- 賦值用 `<=`

### 寫法 C：時序邏輯 + 非同步重置

```verilog
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)          // rst_n 為 0 時重置（低態動作，名字加 _n 表示 negative）
        q <= 8'b0;
    else
        q <= d;
end
```

重置（reset）分兩種：

| 種類 | 寫法 | 行為 |
|---|---|---|
| 同步重置 | `always @(posedge clk)` 裡面判斷 reset | 要等時脈邊緣才生效 |
| 非同步重置 | reset 也寫進敏感清單 | 立刻生效，不等時脈 |

講義的 Register8 用的是同步重置。

### ⚠️ 組合邏輯的 always 要把每種情況都寫到

```verilog
always @(*)
begin
    if (sel)
        y = a;           // 沒寫 else！
end
```

這段的問題是：`sel` 為 0 時沒說 y 要等於什麼，於是合成工具認為「y 要保持原值」，結果多做出一個你不想要的記憶元件，叫做**閂鎖（latch）**。這是初學者最常見的 bug。

解法是加 `else`，或在開頭先給預設值：

```verilog
always @(*)
begin
    y = 1'b0;            // 先給預設值
    if (sel)
        y = a;
end
```

### ⚠️ 一個訊號只能由一個 always 區塊驅動

```verilog
always @(*)           y = a & b;
always @(posedge clk) y <= c;     // ❌ y 被兩個區塊驅動
```

硬體上這等於兩個東西搶著驅動同一條線。模擬結果不可預測，合成會直接報錯。

**規則：一個訊號，只能有一個地方負責給它值。** 不管是兩個 always、兩個 assign，還是一個 always 加一個 assign，都不行。

### always 和 initial 的差別

| | `always` | `initial` |
|---|---|---|
| 執行次數 | 條件符合就**重複執行** | 從時間 0 開始**只執行一次** |
| 能不能合成 | ✅ 可以 | ❌ 不行，只能用在 testbench |

---

## 7. `=` 與 `<=` 的差別（重點）

### 先記結論

| 寫法 | 名稱 | 用在哪裡 |
|---|---|---|
| `=` | **阻隔式賦值**（blocking assignment） | 組合邏輯的 `always @(*)`、`initial`、testbench |
| `<=` | **非阻隔式賦值**（non-blocking assignment） | 時序邏輯的 `always @(posedge clk)` |

### 差別在哪

**`=`（阻隔式）：馬上算、馬上生效，再往下一行。** 就像 C 語言的賦值，後面的敘述會用到新值。「阻隔」的意思是它會擋住後面的敘述，做完才輪到下一行。

**`<=`（非阻隔式）：右邊的值先全部算好記起來，等整個區塊結束才一起更新。** 所以同一個區塊裡，後面的敘述讀到的還是**舊值**。

### 實際例子

同樣的兩行，換賦值符號就是完全不同的電路：

```verilog
// 版本 1：阻隔式
always @(posedge clk) begin
    b1 = a;       // b1 立刻變成 a
    c1 = b1;      // 這裡讀到的 b1 是「剛剛才變的新值」，所以 c1 也等於 a
end

// 版本 2：非阻隔式
always @(posedge clk) begin
    b2 <= a;      // 記下來：b2 要變成 a
    c2 <= b2;     // 這裡讀到的 b2 是「上一個時脈的舊值」
end               // 區塊結束，b2 和 c2 同時更新
```

實際模擬結果（a 在第一個時脈前設為 1，之後設為 0）：

```
t=6   a=1 | 阻隔式 b1=1 c1=1 | 非阻隔式 b2=1 c2=x
t=16  a=0 | 阻隔式 b1=0 c1=0 | 非阻隔式 b2=0 c2=1
t=26  a=0 | 阻隔式 b1=0 c1=0 | 非阻隔式 b2=0 c2=0
```

看 `c` 這一欄：
- **阻隔式的 c1 和 b1 永遠一樣**，合成出來是兩個並排的正反器，都接到 a。
- **非阻隔式的 c2 慢 b2 一個時脈**，合成出來是兩個串接的正反器，也就是**移位暫存器（shift register）**。

### 為什麼時序邏輯一定要用 `<=`

真實的正反器是**同時**在時脈邊緣更新的。非阻隔式「先全部算好，再一起更新」的行為，正好符合硬體的真實情況。

更嚴重的是，當好幾個 `always` 區塊都在同一個時脈邊緣動作時，用 `=` 會讓結果取決於**模擬器先執行哪一個區塊**，這叫**競爭條件（race condition）**。講義的 Register8 和 Rotate_Data 就是這種情況，所以我把提供給你的範例都改成了 `<=`。

### 一個經典用途：交換兩個值

```verilog
always @(posedge clk) begin
    a <= b;
    b <= a;      // 兩行同時生效，真的完成交換
end
```

如果改用 `=`，第一行把 a 變成 b 之後，第二行的 a 已經是新值，結果兩個都變成 b。

### 規則整理

| 規則 | 說明 |
|---|---|
| 時序邏輯（`posedge`）用 `<=` | 一律如此，沒有例外 |
| 組合邏輯（`@(*)`）用 `=` | 一律如此 |
| **不要在同一個 always 區塊混用** | 會造成難以預測的行為 |
| **同一個訊號不要在兩個 always 區塊裡賦值** | 硬體上等於兩個東西搶同一條線 |
| testbench 用 `=` 或 `<=` 都可以 | 產生時脈時常寫 `clk <= !clk` |

### 一句話判斷

**看 `@()` 括號裡寫什麼，不是看到 `always` 就一律用同一種：**

```
always @(*)          →  用 =     →  合成出邏輯閘（AND、OR、多工器…）
always @(posedge …)  →  用 <=    →  合成出正反器（有記憶）
```

---

## 8. 運算子總表

| 類別 | 運算子 | 說明 |
|---|---|---|
| 算術 | `+` `-` `*` | 加、減、乘。**`/` 和 `%` 通常不能合成** |
| 逐位元 | `~` `&` `\|` `^` `~^` | NOT、AND、OR、XOR、XNOR，對每個位元分別運算 |
| 縮減 | `&` `~&` `\|` `~\|` `^` `~^` | 放在單一運算元前面，把多位元縮成 1 位元 |
| 邏輯 | `!` `&&` `\|\|` | 結果只有真（1）或假（0），用在條件判斷 |
| 關係 | `>` `<` `>=` `<=` | 比大小，結果是 1 或 0 |
| 等式 | `==` `!=` | 相等、不相等 |
| 全等 | `===` `!==` | 連 x、z 也要完全相同才算相等。**不能合成**，只能用在 testbench |
| 移位 | `>>` `<<` | 右移 n 次 = 除以 2ⁿ；左移 n 次 = 乘以 2ⁿ |
| 條件 | `? :` | `條件 ? 成立時的值 : 不成立時的值` |
| 連結 | `{ }` | 把多個訊號接成一個，例如 `{a, b}` |
| 重複 | `{n{ }}` | 重複 n 次，例如 `{8{1'b1}}` = `8'b11111111` |

### 運算子優先順序

由高到低（同一列的優先順序相同，由左往右計算）：

| 優先順序 | 運算子 |
|---|---|
| 最高 | `~` `!` 以及單運算元的 `+` `-`（正負號） |
| ↓ | `*` `/` `%` |
| ↓ | `+` `-` |
| ↓ | `<<` `>>` |
| ↓ | `<` `<=` `>` `>=` |
| ↓ | `==` `!=` `===` `!==` |
| ↓ | `&` → `^` `~^` → `\|`（逐位元，這三層由上到下） |
| ↓ | `&&` |
| ↓ | `\|\|` |
| 最低 | `? :` |

⚠️ **不確定就加括號**。最經典的陷阱是等式運算子的優先順序**低於**逐位元運算子：

```verilog
if (a & b == c)      // 實際上是 a & (b == c)，通常不是你想要的
if ((a & b) == c)    // ✅ 這才是「a AND b 之後和 c 比較」
```

加括號不會讓電路變大，只會讓人看得懂。

### 逐位元 vs 邏輯，最容易搞混

```verilog
a = 4'b1100;
b = 4'b1010;

a & b    // 逐位元 AND → 4'b1000（每個位元分別做 AND）
a && b   // 邏輯 AND  → 1'b1（a 不是 0、b 也不是 0，所以是真）
```

判斷條件（`if`、`? :`）裡用 `&&`、`||`、`!`；處理資料位元時用 `&`、`|`、`~`。

### 縮減運算子

同一個符號放在**單一**運算元前面就是縮減：

```verilog
b = 4'b1011;

&b      // 1'b0   所有位元 AND：有 0 就是 0
|b      // 1'b1   所有位元 OR：有 1 就是 1
^b      // 1'b1   所有位元 XOR：1 的個數是奇數 → 1（奇同位）
```

---

## 9. 條件判斷：if / case

### if / else

寫法和 C 語言一樣，但**只能寫在 always、initial、function、task 這四種程序區塊裡面**，不能直接寫在模組裡（見第 2 節「敘述只能寫在程序區塊裡面」）。

```verilog
always @(*) begin
    if (a > b)
        max = a;
    else if (a == b)
        max = a;
    else
        max = b;
end
```

多行時要用 `begin` / `end` 包起來：

```verilog
if (enable) begin
    y = a;
    z = b;
end
else begin
    y = 0;
    z = 0;
end
```

### case：等同於其他語言的 switch

```verilog
always @(*) begin
    case (sel)
        2'b00:   y = a;
        2'b01:   y = b;
        2'b10:   y = c;
        2'b11:   y = d;
        default: y = 1'b0;      // 沒有符合任何一項時
    endcase
end
```

和 C 的 switch 比較：

| C 語言 | Verilog | 說明 |
|---|---|---|
| `switch (x) {` | `case (x)` | |
| `case 0:` | `2'b00:` | Verilog 的冒號後面直接寫敘述 |
| `break;` | **不需要** | Verilog 執行完一項就自動跳出，不會像 C 一樣往下貫穿 |
| `default:` | `default:` | 相同 |
| `}` | `endcase` | |

**不需要 `break`** 是最大的差別。Verilog 的 case 不會貫穿（fall through）。

多個值共用同一段處理，用逗號隔開：

```verilog
case (op)
    3'b000, 3'b001: y = a + b;    // 000 或 001 都做加法
    3'b010:         y = a - b;
    default:        y = 8'b0;
endcase
```

⚠️ 組合邏輯的 case **一定要寫 `default`**，否則會產生前面提過的閂鎖（latch）。

### casez：可以用 `?` 表示不在乎

```verilog
casez (data)
    8'b1???_????: $display("最高位是 1");     // ? 表示這些位元不管是什麼都可以
    8'b01??_????: $display("第二位是 1");
    default:      $display("其他");
endcase
```

`data = 8'b1000_0000` 時，輸出是「最高位是 1」。這個寫法常用在優先權編碼器（priority encoder）。

還有一個 `casex`，連 x 也視為不在乎，但它容易蓋掉真正的錯誤，**建議不要用**。

### 條件運算子 `? :`

單純的二選一用這個最簡潔，而且可以直接寫在 `assign` 裡：

```verilog
assign out = Sel ? a : b;             // Sel=1 選 a，Sel=0 選 b
assign max = (a > b) ? a : b;
assign y = sel2 ? (sel1 ? d : c) : (sel1 ? b : a);    // 可以巢狀，但容易看不懂
```

---

## 10. 迴圈：for / while / repeat / forever

⚠️ **先講最重要的觀念：** 硬體裡沒有「迴圈」這種東西。可合成的迴圈會被工具**完全展開（unroll）**，變成重複的電路。

```verilog
for (i = 0; i < 4; i = i + 1)
    y[i] = a[i] & b[i];
```

這不會產生一個「跑 4 次的電路」，而是直接做出**4 個並排的 AND 閘**。所以：

- 迴圈次數必須是**編譯時就能確定的常數**，不能是輸入訊號
- 迴圈次數寫 1000 次，就真的會做出 1000 份電路

在 testbench 裡就沒有這個限制，因為 testbench 不需要合成。

### for

語法和 C 一樣，只是**沒有 `i++`**，要寫成 `i = i + 1`。

```verilog
integer i;
reg [3:0] sum;

sum = 0;
for (i = 0; i < 4; i = i + 1)
    sum = sum + i;
// 結果：sum = 6（0+1+2+3）
```

用在電路裡的典型例子：

```verilog
always @(*) begin
    for (i = 0; i < 8; i = i + 1)
        y[i] = a[i] ^ b[i];      // 展開成 8 個 XOR 閘
end
```

### while

```verilog
integer i, n;
i = 0;
n = 0;
while (i < 8) begin
    if (data[i]) n = n + 1;      // 數有幾個 1
    i = i + 1;
end
// data = 8'b1011_0010 時，結果 n = 4
```

`while` **通常不能合成**，因為工具無法確定它會跑幾次。主要用在 testbench。

### repeat：重複固定次數

```verilog
i = 1;
repeat (3) i = i * 2;
// 結果：i = 8
```

常用在 testbench 等待固定個時脈：

```verilog
repeat (10) @(posedge clk);      // 等 10 個時脈正緣
```

### forever：無限迴圈

```verilog
initial begin
    clk = 0;
    forever #5 clk = ~clk;       // 永遠每 5ns 反相一次，產生時脈
end
```

**只能用在 testbench**，而且一定要有 `$stop` 或 `$finish` 讓模擬結束，否則會無限跑下去。

產生時脈也可以用 `always`，效果相同，比較常見：

```verilog
always #5 clk = ~clk;
```

### 四種迴圈比較

| 迴圈 | 次數 | 能不能合成 | 主要用途 |
|---|---|---|---|
| `for` | 固定 | **可以**（會展開） | 重複的電路結構 |
| `while` | 由條件決定 | 通常不行 | testbench |
| `repeat` | 固定 | 部分情況可以 | testbench 等待 N 個時脈 |
| `forever` | 無限 | **不行** | testbench 產生時脈 |

---

## 11. 沒有 break、continue、return 怎麼辦

標準 Verilog（IEEE 1364）**沒有** `break`、`continue`、`return` 這三個關鍵字。

### 代替 break：`disable`

給區塊取一個名字，再用 `disable 名字` 跳出去：

```verilog
begin : search                       // 區塊取名 search
    for (i = 0; i < 8; i = i + 1) begin
        if (data[i]) begin
            n = i;
            disable search;          // 找到就跳出整個 search 區塊
        end
    end
end
// data = 8'b1000_0000 時，結果 n = 7
```

### 代替 continue：用 if 包起來

```verilog
for (i = 0; i < 8; i = i + 1) begin
    if (data[i]) begin           // 不符合條件的就什麼都不做，等於跳過
        n = n + 1;
    end
end
```

或者把迴圈本體取名，`disable` 那個名字就只會跳過這一輪：

```verilog
for (i = 0; i < 8; i = i + 1) begin : one_round
    if (!data[i]) disable one_round;    // 跳過這一輪，繼續下一輪
    n = n + 1;
end
```

### 代替 return：把值指定給 function 名稱

Verilog 的 function 用「**把值指定給和 function 同名的變數**」來回傳：

```verilog
function [7:0] add3;
    input [7:0] x;
    begin
        add3 = x + 3;        // 這一行就是 return
    end
endfunction

// 呼叫：add3(4) 會得到 7
```

### 補充：SystemVerilog 有這些關鍵字

SystemVerilog（IEEE 1800，Verilog 的擴充版）補上了 `break`、`continue`、`return`，還有 `always_comb`、`always_ff`、`logic` 型態等等，寫起來更接近一般程式語言。

不過**課堂通常要求用標準 Verilog**，副檔名 `.v`。SystemVerilog 的副檔名是 `.sv`。先學好標準 Verilog，之後要轉很容易。

---

## 12. function 與 task

兩者都是把重複用到的邏輯包起來，避免一直複製貼上。

### function（函式）

```verilog
function [7:0] add3;         // [7:0] 是回傳值的寬度
    input [7:0] x;
    begin
        add3 = x + 3;
    end
endfunction

assign y = add3(data);       // 可以用在 assign 裡
```

規則：
- **至少要有一個 input**，而且**不能有 output**
- **不能有延遲**（`#10`）或 `@(posedge clk)`，必須在同一個時間點內算完
- **可以合成**，會變成組合邏輯
- 回傳值就是指定給 function 名稱

### task（任務）

```verilog
task show_result;
    input [7:0] value;
    begin
        $display("value = %b", value);
    end
endtask

// 呼叫
show_result(data);
```

規則：
- input、output 都可以有，也可以完全沒有
- **可以有延遲和時脈事件**
- 主要用在 testbench，把重複的測試步驟包起來

### testbench 裡的實用寫法

```verilog
task apply;                        // 把「餵一組輸入、等 10ns」包成一個動作
    input ia, ib, icin;
    begin
        a = ia;  b = ib;  Carry_In = icin;
        #10;
    end
endtask

initial begin
    apply(0, 0, 0);
    apply(0, 1, 1);
    apply(1, 1, 1);
    $stop;
end
```

---

## 13. 模組的實例化與 parameter

在一個模組裡使用另一個模組，叫做**實例化（instantiation）**，講義稱為「取別名」。

```verilog
模組名稱  實例名稱 (埠連接);
```

一個模組可以被實例化很多次，每一份都是**獨立存在的硬體**。實例化 4 個全加器，晶片裡就真的有 4 份全加器電路。

### 連接方式 A：依順序（by order）

```verilog
FullAdd fa0 (a[0], b[0], Carry_In, Sum[0], Carry_Out1);
```

括號裡的訊號，順序必須和 FullAdd 宣告埠的順序完全一致。寫起來短，但埠一多就很容易接錯。

### 連接方式 B：依名稱（by name）

```verilog
FullAdd fa0 (
    .a(a[0]),                  // .子模組的埠名(外面要接的訊號)
    .b(b[0]),
    .Carry_In(Carry_In),
    .Sum(Sum[0]),
    .Carry_Out(Carry_Out1)
);
```

順序無所謂，不容易接錯，**實務上一律用這種**。

⚠️ 同一個實例裡兩種寫法不能混用，但不同實例可以各用各的。

### 用 parameter 做出「可調整的模組」

`parameter` 是模組內的常數，實例化時可以從外面改寫，同一份程式碼就能做出不同寬度的電路：

```verilog
module Adder #(parameter SIZE = 8) (      // 預設 8 位元
    input  [SIZE-1:0] a, b,
    output [SIZE-1:0] s
);
    assign s = a + b;
endmodule
```

實例化時用 `#( )` 指定：

```verilog
Adder #(.SIZE(4))  u4  (a4,  b4,  s4);    // 做出 4 位元版本
Adder #(.SIZE(16)) u16 (a16, b16, s16);   // 做出 16 位元版本
```

實際模擬結果：4 位元版本算 7 + 9 得到 0（16 超出 4 位元範圍，溢位），16 位元版本算 300 + 12 得到 312。同一份程式碼、兩種硬體。

舊寫法把 parameter 寫在模組內（講義的 Add_or_Subtract 就是這樣），實例化時用 `defparam` 改寫，現在已經不建議使用：

```verilog
module Add_or_Subtract (a, b, op, s);
    parameter SIZE = 8;               // 寫在模組內
    // ...
```

### 常見錯誤

```
Module 'FullAdd' is not defined
```

代表你用到的子模組沒有一起編譯。ModelSim 要把所有相關的 `.v` 檔都 `vlog` 進去。

---

## 14. testbench 的基本結構

testbench（測試平台）是一個**沒有輸入輸出埠**的模組，用來產生訊號餵給待測電路，再觀察輸出。它只在模擬時使用，不會做成硬體。

```verilog
`timescale 1ns/1ps

module FullAdd_tb;                 // 沒有埠

    // 1. 宣告訊號
    reg  a, b, Carry_In;           // 要餵進去的 → reg
    wire Sum, Carry_Out;           // 要接出來的 → wire

    // 2. 實例化待測電路（UUT = Unit Under Test）
    FullAdd uut (
        .a(a), .b(b), .Carry_In(Carry_In),
        .Sum(Sum), .Carry_Out(Carry_Out)
    );

    // 3. 產生輸入訊號
    initial begin
        $monitor("t=%0d  a=%b b=%b Cin=%b -> Cout=%b Sum=%b",
                 $time, a, b, Carry_In, Carry_Out, Sum);

        a = 0; b = 0; Carry_In = 0;  #10;
        a = 0; b = 1; Carry_In = 0;  #10;
        a = 1; b = 1; Carry_In = 1;  #10;

        $stop;
    end
endmodule
```

### 為什麼輸入是 reg、輸出是 wire

- 輸入訊號在 `initial` 裡被賦值 → 必須是 `reg`
- 輸出是從電路接出來的，由電路驅動 → 必須是 `wire`

### `initial` 區塊

`initial` 裡的內容從時間 0 開始，**依序執行一次**就結束。這是唯一可以依序思考的地方，因為它不是電路，只是模擬用的腳本。

**`initial` 不能合成**，只能用在 testbench。

### `#10` 延遲

「等 10 個時間單位再繼續」。配合開頭的 `` `timescale 1ns/1ps ``，`#10` 就是 10 奈秒。同樣**不能合成**。

### 產生時脈

```verilog
reg clk;
initial clk = 0;              // 給初始值，不然會是 x
always #5 clk = ~clk;         // 每 5ns 反相 → 週期 10ns
```

⚠️ 用了 `always` 產生時脈，模擬就不會自己停，**一定要有 `$stop` 或 `$finish`**。

### 常用系統任務

| 系統任務 | 作用 |
|---|---|
| `$display("格式", 變數)` | 印一行，立刻執行一次 |
| `$monitor("格式", 變數)` | 只要清單裡的變數有變化就自動印。**整個模擬只需要呼叫一次** |
| `$time` | 目前的模擬時間 |
| `$stop` | 暫停模擬。**ModelSim 用這個**，波形會保留 |
| `$finish` | 結束模擬。ModelSim 會跳出是否關閉的詢問視窗 |
| `$dumpfile` / `$dumpvars` | 產生 VCD 波形檔，EDA Playground 需要，ModelSim 不需要 |

格式字元：

| 字元 | 顯示方式 |
|---|---|
| `%b` | 二進位 |
| `%d` | 十進位（固定寬度，前面會補空白） |
| `%0d` | 十進位（不補空白，常用） |
| `%h` | 十六進位 |
| `%s` | 字串 |
| `%0t` | 時間。⚠️ 會用模擬精度（1ps）顯示，`#10` 會印成 10000。想看 ns 就用 `%0d` 搭配 `$time` |

---

## 15. 可合成 vs 不可合成速查

**可合成**：能變成真實電路，寫在 design 檔案裡。
**不可合成**：只能在模擬時使用，寫在 testbench 裡。

| 寫法 | 可合成 | 備註 |
|---|---|---|
| `assign` | ✅ | 組合邏輯 |
| `always @(*)` | ✅ | 組合邏輯 |
| `always @(posedge clk)` | ✅ | 時序邏輯，產生正反器 |
| `if` / `else` / `case` / `casez` | ✅ | 要寫在 always 裡，組合邏輯記得加 `default` |
| `for` | ✅ | 次數必須固定，會展開成重複的電路 |
| `function` | ✅ | 組合邏輯 |
| `+` `-` `*` | ✅ | |
| `>>` `<<` | ✅ | 移位量固定時最省資源 |
| `{ }` `{n{ }}` `? :` | ✅ | |
| `parameter` | ✅ | |
| **`/` `%`** | ❌ | 除法、取餘數，硬體成本太高 |
| **`initial`** | ❌ | 只能用在 testbench |
| **`#10` 延遲** | ❌ | 真實電路沒有「等一下」這種零件 |
| **`while` `forever` `repeat`** | ❌ | 次數不固定 |
| **`===` `!==`** | ❌ | 牽涉 x、z 的比較 |
| **`task`** | ❌ | 實務上視為不可合成 |
| **`$display` `$monitor` `$stop`** | ❌ | 系統任務只用於模擬 |

---

## 16. 怎麼從需求寫出電路

初學最卡的往往不是語法，而是「我知道要做什麼，但不知道第一行該寫什麼」。用這個流程想：

### 步驟 1：先問「要不要記住東西」

| 問題 | 答案 | 寫法 |
|---|---|---|
| 輸出只由**當下的輸入**決定？ | 是 | 組合邏輯：`assign` 或 `always @(*)` |
| 需要**記住上一次的值**，或要**等時脈**？ | 是 | 時序邏輯：`always @(posedge clk)` |

例如：加法器、多工器、解碼器、比較器都是組合邏輯；計數器、暫存器、移位暫存器、狀態機都是時序邏輯。

### 步驟 2：組合邏輯 → 先寫真值表，再翻成 case

需求：2 對 4 解碼器。先列真值表：

```
b a | y3 y2 y1 y0
0 0 |  0  0  0  1
0 1 |  0  0  1  0
1 0 |  0  1  0  0
1 1 |  1  0  0  0
```

真值表的每一列，就是 case 的一項：

```verilog
always @(*) begin
    case ({b, a})                 // 用 {} 把兩個輸入接成 2 位元
        2'b00:   y = 4'b0001;
        2'b01:   y = 4'b0010;
        2'b10:   y = 4'b0100;
        2'b11:   y = 4'b1000;
        default: y = 4'b0000;     // 保險起見一定要寫
    endcase
end
```

**真值表有幾列，case 就有幾項**，翻譯過程幾乎是機械式的。

### 步驟 3：時序邏輯 → 想「每個時脈要做什麼」

需求：0~15 的計數器，有重置。每個時脈只需要回答一個問題：「下一個值是什麼？」

```verilog
always @(posedge clk) begin
    if (reset)
        count <= 4'b0;            // 重置：歸零
    else if (count == 4'd15)
        count <= 4'b0;            // 數到 15：繞回 0
    else
        count <= count + 1;       // 其他情況：加 1
end
```

判斷條件的**順序就是優先權**，寫在前面的優先。所以 reset 要放第一個。

### 步驟 4：大電路就拆成小模組

不要想一次寫完。像講義的 FullAdd4，是先做好 1 位元的 FullAdd，再實例化 4 次。判斷方式是找出「重複出現的部分」和「功能獨立的部分」，各自做成一個模組。

### 步驟 5：寫 testbench 驗證

輸入不多時（例如 3 個 1 位元輸入），用 `for` 迴圈把所有組合都跑一遍。輸入太多時，挑幾組有代表性的：最小值、最大值、會進位的、會溢位的、邊界值。

---

## 17. 初學者常犯的錯

| 錯誤 | 症狀 | 正確做法 |
|---|---|---|
| 在 `always` 裡賦值的訊號宣告成 wire | 編譯錯誤 | 改宣告成 `reg` |
| 把 `input` 宣告成 reg | 編譯錯誤 | input 一定是 wire |
| `always @(posedge clk)` 裡用 `=` | 模擬和實際電路不一致 | 改用 `<=` |
| 組合邏輯的 if 沒寫 else | 多出不想要的閂鎖（latch） | 補 `else`，或開頭先給預設值 |
| 組合邏輯的 case 沒寫 default | 同上 | 補 `default` |
| 同一個訊號在兩個 always 裡賦值 | 結果不可預測 | 一個訊號只能由一個區塊驅動 |
| 敏感清單漏列訊號 | 模擬正常但實際電路錯誤 | 一律用 `@(*)` |
| testbench 忘了寫 `$stop` | 模擬跑不完 | 加上 `$stop` |
| clk 忘了給初始值 | 波形一直是 x | `initial clk = 0;` |
| 用了 `/` 或 `%` | 模擬正常，合成失敗 | 改用移位，或用專門的除法器 |
| 子模組沒一起編譯 | `Module 'xxx' is not defined` | `vlog *.v` 全部編譯 |
| `timescale 的反引號打成單引號 | 編譯錯誤 | 用 Esc 下面那一顆按鍵 |

---

## 18. 編譯錯誤訊息對照

ModelSim 的錯誤訊息是英文的，這裡列出最常遇到的幾種。**在 Transcript 的紅字上點兩下**，會直接跳到出錯的那一行。

| 訊息 | 意思 | 通常的原因 |
|---|---|---|
| `syntax error` / `near "xxx"` | 語法錯誤 | 少了分號、`begin`/`end` 不成對、用到關鍵字當名字（例如 `small`） |
| `Module 'xxx' is not defined` | 找不到模組 | 子模組沒有一起編譯，用 `vlog *.v` 全部編譯 |
| `Illegal output or inout port specification` | 埠的型別不合法 | output 在 `always` 裡被賦值卻沒宣告成 `reg` |
| `Variable 'xxx' is not a valid left-hand side of a procedural assignment` | 這個東西不能在 always 裡被賦值 | 它是 `wire`，要改成 `reg` |
| `Illegal reference to net "xxx"` | 不能這樣參考這條線 | 同上，或是在 `assign` 左邊放了 `reg` |
| `Too few port connections` | 埠接得不夠多 | 實例化時漏了埠。用「依名稱」的寫法可以避免 |
| `Undefined variable: 'xxx'` | 找不到這個名字 | 打錯字，或忘了宣告 |
| `implicit definition of wire 'xxx'`（警告） | 自動建立了一條線 | **通常是打錯字**，要當成錯誤來看待 |
| `Instantiation of 'xxx' failed` | 實例化失敗 | 子模組本身編譯失敗，先往上找它的錯誤 |
| `expression width N does not match`（警告） | 寬度不符 | 左右兩邊位元數不一樣，確認是不是會被截掉 |

⚠️ **看到 `Errors: 0, Warnings: 0` 才算乾淨。** 只看 Errors 是 0 的話，會漏掉打錯字這種用警告呈現的問題。

**錯誤很多時，從第一個開始修。** 一個錯誤常常會引發後面一連串的假錯誤，修好第一個之後重新編譯，數量通常會大幅減少。

---

## 19. 練習順序建議

照這個順序跑打包給你的範例，每個都跑過一次並看懂波形：

| 順序 | 範例 | 學到什麼 |
|---|---|---|
| 1 | `01_FullAdd` | 模組、埠、`assign`、連結運算子 |
| 2 | `12_Mux2to1` | 條件運算子 `? :` |
| 3 | `07_Deco2_4g` | 邏輯閘層次的寫法 |
| 4 | `11_Decoder` | 移位運算 |
| 5 | `09_Compare` | 關係與等式運算子 |
| 6 | `02_FullAdd4` | 實例化、依順序連接、向量 |
| 7 | `04_DFF` | `always @(posedge clk)`、`<=`、時脈的產生 |
| 8 | `05_DFF_Sel` | 組合邏輯和時序邏輯混在一起 |
| 9 | `03_Hierar` | 階層式設計、依名稱連接、重置 |
| 10 | 其他範例 | 各類運算子 |

**每個範例的練習方式：**
1. 先看 design 檔案，想想看這是什麼電路
2. 看 testbench，想想看會餵進什麼輸入
3. **先自己預測輸出**，寫在紙上
4. 跑模擬，和 testbench 檔尾的預期輸出對照
5. **改一行程式再跑一次**，例如把 `& ` 改成 `|`、把 `<=` 改成 `=`，看波形怎麼變

第 5 步是學最快的方式。壞不了任何東西，大膽改。
