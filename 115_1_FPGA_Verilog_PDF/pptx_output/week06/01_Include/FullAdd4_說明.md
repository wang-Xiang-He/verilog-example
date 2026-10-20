# 01_Include 範例說明：`include 引用另一個檔案（4 位元漣波進位加法器）

## 1. 這個範例在做什麼？

**編譯命令（compiler directive）** 是寫給「編譯器」看的指令，開頭都是反引號 `` ` ``，
在真正編譯之前就先處理掉，本身不會變成電路。本週會學到三個：`` `include ``、`` `define ``、`` `timescale ``。

`` `include `` 的功能（講義第 2 頁）：**目前的 Verilog 電路描述檔，可以包含另一個 Verilog 電路描述檔來一起編譯**。

本範例：4 位元漣波進位加法器 `FullAdd4.v`，用 `` `include `` 引用**已經設計好的** 1 位元全加器 `FullAdd.v`。

```
FullAdd4.v                         FullAdd.v
┌──────────────────────────┐       ┌──────────────────┐
│ `include "FullAdd.v"  ◄──┼───────┤ module FullAdd   │
│                          │       │   ...            │
│ module FullAdd4 (...);   │       │ endmodule        │
│   FullAdd fa0 (...);     │       └──────────────────┘
│   FullAdd fa1 (...);     │
│   ...                    │
│ endmodule                │
└──────────────────────────┘
```

> 電路本身和 week03 的 [02_FullAdd4](../../week03/02_FullAdd4/FullAdd4_說明.md) 一模一樣，
> 差別只在 `FullAdd` 是怎麼「帶進來」的。

---

## 2. `include 的運作方式

`` `include "檔名" `` = 編譯前，把那個檔案的內容**原樣貼到這一行的位置**（純文字複製貼上）。

所以 vlog 實際看到的是：
```verilog
module FullAdd ( ... );        // ← 從 FullAdd.v 貼進來的
    assign {CarryOut, Sum} = a + b + CarryIn;
endmodule

module FullAdd4 ( ... );       // ← FullAdd4.v 本來的內容
    ...
endmodule
```

### 編譯時只列 FullAdd4.v

```
vlog FullAdd4.v FullAdd4_tb.v
```

`FullAdd.v` **不要**再列進去。如果寫成 `vlog FullAdd.v FullAdd4.v FullAdd4_tb.v`，
`FullAdd` 會被編譯兩次，ModelSim 會出現警告：

```
** Warning: ** while parsing file included at FullAdd4.v(16)
** at FullAdd.v(8): (vlog-2275) Existing module 'FullAdd' will be overwritten.
```

這裡兩份內容相同所以還能跑；但如果是兩個不同版本，就會不知道到底用了哪一個。

> 對照 week05 的 [01_Func_AS](../../week05/01_Func_AS/Func_AS_說明.md)：那邊 include 的是一個**函數**（`.vh` 檔），
> 函數必須寫在模組**裡面**，所以 `` `include `` 寫在 `module ... endmodule` 之間；
> 這裡 include 的是一整個**模組**，所以 `` `include `` 寫在 `module` 的**外面**（檔案最上方）。

### 路徑的寫法（講義第 2、4 頁）

| 寫法 | 可以嗎 | 說明 |
|------|--------|------|
| `"FullAdd.v"` | ✓ | 和目前的資料夾相同（最常用） |
| `"D:/test/FullAdd.v"` | ✓ | 斜線 `/`，Windows 也看得懂 |
| `"D:\\test\\FullAdd.v"` | ✓ | 反斜線要寫**兩個** |
| `"D:\test\FullAdd.v"` | ✗ | 字串裡的 `\` 是**跳脫字元**，`\t` 會被當成 Tab |

> 「目前的資料夾」指的是 ModelSim **執行 vlog 時所在的資料夾**（Transcript 視窗 `cd` 到的地方），
> 不一定是 .v 檔所在的資料夾。用 `do run.do` 之前記得先 `cd` 到本範例的資料夾。

> 講義的檔名寫成 `FullAdd.V`（大寫 V）。Windows 不分大小寫所以沒問題，
> 但 Linux（例如 EDA Playground）會分，`` `include `` 裡的檔名要和實際檔名**完全一樣**。

---

## 3. 檔案說明

| 檔案 | 用途 |
|------|------|
| `FullAdd.v` | 1 位元全加器，被 `` `include `` 引入（不直接編譯） |
| `FullAdd4.v` | 4 位元加法器，開頭 `` `include "FullAdd.v" `` |
| `FullAdd4_tb.v` | 測試平台 |
| `run.do` | `vlog FullAdd4.v FullAdd4_tb.v` |

### FullAdd4.v
```verilog
`include "FullAdd.v"        // 引用 FullAdd.v 檔中的所有可用模組

module FullAdd4 (
    input  [3:0] a,
    input  [3:0] b,
    input        Carry_In,
    output [3:0] Sum,
    output       Carry_Out
);
    wire Carry_Out1, Carry_Out2, Carry_Out3;

    FullAdd fa0 (a[0], b[0], Carry_In,   Sum[0], Carry_Out1);
    FullAdd fa1 (a[1], b[1], Carry_Out1, Sum[1], Carry_Out2);
    FullAdd fa2 (a[2], b[2], Carry_Out2, Sum[2], Carry_Out3);
    FullAdd fa3 (a[3], b[3], Carry_Out3, Sum[3], Carry_Out);
endmodule
```

### 講義說 Carry_Out1~3「可不宣告」（第 3 頁）
接在埠上、但沒有宣告的名字，Verilog 會自動當成 **1 位元的 wire**（隱含宣告，implicit net）。
`Carry_Out1~3` 剛好都是 1 位元，所以不宣告也能跑。

但這是個陷阱：如果是多位元的訊號（例如 `[3:0] temp`）沒宣告，它只會變成 1 位元，
高位元全部不見，編譯器也不一定會提醒。所以這裡還是把它們宣告出來。

---

## 4. 預期輸出

測試數值和講義第 4 頁波形相同：

```
t=0   a=0000 b=1111 Cin=1  ->  Cout=1 Sum=0000  (0 + 15 + 1 = 16)
t=10  a=0000 b=0111 Cin=0  ->  Cout=0 Sum=0111  (0 + 7 + 0 = 7)
t=20  a=0000 b=0111 Cin=1  ->  Cout=0 Sum=1000  (0 + 7 + 1 = 8)
t=30  a=1000 b=0111 Cin=0  ->  Cout=0 Sum=1111  (8 + 7 + 0 = 15)
t=40  a=1000 b=0111 Cin=1  ->  Cout=1 Sum=0000  (8 + 7 + 1 = 16)
t=50  a=0111 b=0011 Cin=0  ->  Cout=0 Sum=1010  (7 + 3 + 0 = 10)
```

### 觀察重點
- `Sum` 依序是 `0000、0111、1000、1111、0000、1010`，和講義第 4 頁的波形一樣。
- t=0 和 t=40：結果是 16，4 位元放不下，所以 `Sum = 0000`、`Cout = 1`。
- 在 sim 視窗點開 `uut`，可以看到 `fa0 ~ fa3` 四個 `FullAdd`。它們是從 `FullAdd.v` 引進來的，但看起來和直接寫在同一個檔案裡沒有任何差別。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 編譯命令 | 開頭是反引號 `` ` ``，編譯前先處理，不是電路 |
| `` `include "檔名" `` | 把檔案內容原樣貼到這個位置 |
| 被 include 的檔案 | 不要再列進 vlog，否則會重複定義 |
| 路徑 | 用 `/` 或 `\\`，不能只用一個 `\` |
| 隱含宣告 | 沒宣告的連線會變成 1 位元 wire，多位元訊號一定要宣告 |
