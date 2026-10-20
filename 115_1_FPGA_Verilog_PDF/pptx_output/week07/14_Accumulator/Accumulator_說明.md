# 14_Accumulator 範例說明：16 位元累加器（非同步重置）

## 1. 這個範例在做什麼？

**累加器**的功能在於讓電路中的某個暫存器值能夠**一直累加特定的值**（講義第 61 頁）。

```
             16
  Data_In ──/──►┌──────────┐   16
                │  累加器  │───/──► Out
    Reset ─────►│          │
                │          │
    Clock ─────►│>         │
                └──────────┘
```

每個 Clock 正緣：`Out = Out + Data_In`。例如 Data_In 一直是 3，Out 就會 0 → 3 → 6 → 9 ...

> 講義第 61 頁的方塊圖寫「8 位元累加器」，但第 62 頁的程式和圖上的 16 都是 16 位元，這裡以程式為準。

---

## 2. 程式說明

### Accumulator.v（講義第 62 頁）
```verilog
module Accumulator (
    input             Clock,
    input             Reset,
    input      [15:0] Data_In,
    output reg [15:0] Out
);
    always @(posedge Clock or posedge Reset) begin  // 非同步重置
        if (Reset)                  // 重置
            Out <= 16'd0;           // 清除為 0
        else                        // 從輸入埠 Data_In 讀入累加值，輸出埠 Out 加上 Data_In
            Out <= Out + Data_In;
    end
endmodule
```

### 非同步重置
敏感清單是 `posedge Clock or posedge Reset`：
- **Reset 一變成 1** 就會執行 always，不必等 Clock → 立刻清 0（**非同步**，Asynchronous）
- 如果敏感清單只有 `posedge Clock`，Reset 就要等到下一個正緣才有作用（**同步**，見 week09 的 [05_DFF_SR](../../week09/05_DFF_SR/D_FF_SR_說明.md)）

`if (Reset)` 一定要放在最前面：Reset 的優先權最高。

### 累加 = 暫存器 + 加法器
```
           ┌────────┐      ┌──────────┐
Data_In ──►│        │      │          │
           │  加法器 │─────►│ 16 位元  │──┬──► Out
      ┌───►│  (+)   │      │ 暫存器   │  │
      │    └────────┘      └──────────┘  │
      └──────────────────────────────────┘
                  Out 接回加法器
```
`Out <= Out + Data_In` 右邊的 `Out` 是暫存器**目前**的值，加完後在正緣存回去，形成回授迴路。

---

## 3. 預期輸出

正緣在 10、30、50 ...（週期 20 ns）；Data_In 依序 3、3、4、5、1（講義第 63 頁：3、6、10、15）。

```
t=0    Clock=0 Reset=1  Data_In=...0011(3)  ->  Out=...0000(0)      ← 重置
t=5    Clock=0 Reset=0  Data_In=...0011(3)  ->  Out=...0000(0)
t=10   Clock=1 Reset=0  Data_In=...0011(3)  ->  Out=...0011(3)      ← 0 + 3
t=30   Clock=1 Reset=0  Data_In=...0011(3)  ->  Out=...0110(6)      ← 3 + 3
t=45   Clock=0 Reset=0  Data_In=...0100(4)  ->  Out=...0110(6)
t=50   Clock=1 Reset=0  Data_In=...0100(4)  ->  Out=...1010(10)     ← 6 + 4
t=65   Clock=0 Reset=0  Data_In=...0101(5)  ->  Out=...1010(10)
t=70   Clock=1 Reset=0  Data_In=...0101(5)  ->  Out=...1111(15)     ← 10 + 5
t=85   Clock=0 Reset=0  Data_In=...0001(1)  ->  Out=...1111(15)
t=90   Clock=1 Reset=0  Data_In=...0001(1)  ->  Out=...10000(16)    ← 15 + 1
t=95   Clock=1 Reset=1  Data_In=...0001(1)  ->  Out=...0000(0)      ← 時脈中間重置 → 立刻清 0
t=105  Clock=0 Reset=0  ...
t=110  Clock=1 Reset=0  Data_In=...0001(1)  ->  Out=...0001(1)      ← 重新開始累加
t=130  Clock=1 Reset=0  Data_In=...0001(1)  ->  Out=...0010(2)
```
（實際輸出是完整的 16 位元二進位，這裡省略前面的 0）

### 觀察重點
- Out 依序 3 → 6 → 10 → 15，和講義第 63 頁右邊的直式加法一樣：0011 + 0011 = 0110、+ 0100 = 1010、+ 0101 = 1111。
- **t=95**：Reset 在 Clock = 1 的中間變成 1，Out **在同一個時間點**就清 0，不用等下一個正緣，這就是非同步重置。
- 16 位元最多到 65535，超過會溢位回到小的數字（和 week03 [08_AddOrSub](../../week03/08_AddOrSub/Add_or_Subtract_說明.md) 一樣）。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 累加器 | 暫存器 + 加法器，輸出接回輸入 |
| `posedge Reset` | 放進敏感清單 = 非同步重置 |
| if (Reset) 在最前 | 重置的優先權最高 |
| 時脈觸發用 `<=` | 右邊的 Out 是目前的值 |
