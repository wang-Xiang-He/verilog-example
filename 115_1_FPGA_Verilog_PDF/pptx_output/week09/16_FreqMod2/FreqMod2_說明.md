# 16_FreqMod2 範例說明：除 2 器（Frequency Divider）

## 1. 先認識除頻電路（講義第 53 頁）

**除頻器**把輸入時脈的頻率變低：輸入每 N 個週期，輸出才 1 個週期。
例如 FPGA 板子上的振盪器是 50 MHz，要讓 LED 每秒閃一次，就要把時脈除以 5000 萬。

除頻電路依「除數」大小，可分為下列二種：
- **固定**除以某個大小的「除 N 器」（N 為一個正整數值）
- 可以由使用者**自訂 N 的大小**的「可程式的除頻器」（見 [17_FreqModN](../17_FreqModN/FreqModN_說明.md)）

---

## 2. 這個範例在做什麼？

範例：「**除 2 器**」，將輸入時脈訊號頻率除以 2 之後再輸出（講義第 53、54 頁）。

```
         ┌──────────┐
 Reset ─►│ Reset    │
         │  除 2 器 │──► Clock_Mod2_Out
Clock_In►│>Clock_In │
         └──────────┘

Clock_In       : _|‾|_|‾|_|‾|_|‾|_|‾|_
Clock_Mod2_Out : _|‾‾‾|___|‾‾‾|___|‾‾
                   每個 Clock_In 正緣反相一次
```

原理和 [02_DFF_RS](../02_DFF_RS/DFF_RS_說明.md) 的「除 2 功能」相同：**每個正緣把輸出反相一次**，輸出就是輸入一半的頻率，而且高、低電位各一個輸入週期（50% duty cycle）。

---

## 3. 程式說明

### FreqMod2.v（講義第 53 頁）
```verilog
module FreqMod2 (
    input      Reset,
    input      Clock_In,
    output reg Clock_Mod2_Out
);
    wire Not_Clock_Mod2_Out;

    assign Not_Clock_Mod2_Out = !Clock_Mod2_Out;

    always @(posedge Reset or posedge Clock_In) begin
        if (Reset)
            Clock_Mod2_Out <= 1'b0;
        else
            Clock_Mod2_Out <= Not_Clock_Mod2_Out;
    end
endmodule
```
- `Not_Clock_Mod2_Out` 是一條 wire，永遠是輸出的反相。每個正緣把它存回輸出 → 輸出反相。
- `posedge Reset`：非同步重置。**一定要有 Reset**，否則一開始輸出是 x，`!x` 還是 x，永遠除不起來。

### 講義第 53 頁：「去除 assign 而令 Clock_Mod2_Out = !Clock_Mod2_Out」
直接寫
```verilog
Clock_Mod2_Out <= !Clock_Mod2_Out;
```
效果完全一樣，不需要額外的 `Not_Clock_Mod2_Out` 這條線。`<=` 右邊讀的是舊值，所以反相後存回去，不會有問題。

講義第 54 頁的箭頭說明了這個循環：
```
Clock_Mod2_Out = 0 (Start) → Not = 1 → 正緣存入 → Clock_Mod2_Out = 1 → Not = 0 → 正緣存入 → 0 → ...
```

---

## 4. 預期輸出

Clock_In 週期 10 ns（正緣在 5、15、25 ...），Reset 在 t=12 放開：

```
t=0   Reset=1 Clock_In=0  ->  Clock_Mod2_Out=0     ← 重置
t=5   Reset=1 Clock_In=1  ->  Clock_Mod2_Out=0     ← Reset 還是 1：維持 0
t=12  Reset=0 Clock_In=0  ->  Clock_Mod2_Out=0
t=15  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1     ← 0 → 1
t=25  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0     ← 1 → 0
t=35  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1
t=45  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0
t=55  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=1
t=65  Reset=0 Clock_In=1  ->  Clock_Mod2_Out=0
```
（只列出輸出改變的幾行，完整輸出在 tb 檔尾）

### 觀察重點
- Reset 放開後，輸出在每個 Clock_In 正緣反相一次：t=15 → 1、t=25 → 0 ...
- 輸出 15~35 是一個完整週期（20 ns），是輸入週期（10 ns）的 2 倍 → 頻率除以 2。
- 高電位 10 ns、低電位 10 ns：duty cycle 剛好 50%。
- 和講義第 54 頁的 0 → 1 → 0 → 1 一樣。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 除頻器 | 降低時脈頻率 |
| 除 2 | 每個正緣反相一次 |
| 一定要重置 | 否則 x 反相還是 x |
| `<= !自己` | 不需要另外的 wire |
| 50% duty | 除 2 的輸出高低各半 |
