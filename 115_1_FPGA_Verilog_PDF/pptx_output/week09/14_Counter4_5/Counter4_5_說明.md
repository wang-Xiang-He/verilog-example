# 14_Counter4_5 範例說明：10 位元計數器，旗標寫在 always 內 vs always 外

## 1. 這個範例在做什麼？

10 位元正緣觸發上數計數器（0~1023），並輸出 4 個旗標（講義第 46~50 頁）：

| 旗標 | 條件 | 寫法 |
|------|------|------|
| `Zero` | 計數值為 0 | `!(\|Out)` |
| `Max_1023` | 計數值為 1023 | `&Out` |
| `Odd` | 計數值為**奇同位**（1 的個數為奇數） | `^Out` |
| `Even` | 計數值為**偶同位**（1 的個數為偶數） | `!(^Out)` 或 `~^Out` |

旗標用的是 week03 [06_BitWise](../../week03/06_BitWise/BitWise_說明.md) 的**縮減運算子**：
- `|Out`：只要有一個 1 就是 1 → 取反：全部是 0 才是 1 → **Zero**
- `&Out`：全部是 1 才是 1 → 1023 = `11_1111_1111` → **Max_1023**
- `^Out`：1 的個數為奇數 → 1（講義第 48 頁：XOR 相同為 0，不同為 1）

> **注意**：Even / Odd 是**同位**（1 的個數），不是數值的奇偶！例如 3 = `0000000011` 有兩個 1 → Even = 1，雖然 3 是奇數。

本範例比較兩種寫法：

| 模組 | 講義 | 旗標寫在 |
|------|------|---------|
| `Counter4` | 第 46~48 頁 | always 區塊**內** |
| `Counter5` | 第 49、50 頁 | always 區塊**外**（assign） |

講義第 49 頁的模組名稱還是寫 `Counter4`，和上一個同名，這裡改為 `Counter5`。

---

## 2. 程式說明

### Counter4：旗標在 always 內（講義第 47 頁）
```verilog
always @(posedge Clock or posedge Reset) begin
    if (Reset)
        Out <= 10'd0;
    else
        Out <= Out + 1'b1;

    Zero     <= !(|Out);
    Max_1023 <= &Out;
    Odd      <= ^Out;
    Even     <= !(^Out);
end
```

### Counter5：旗標在 always 外（講義第 50 頁）
```verilog
assign Zero     = !(|Out);          // 不寫在 always block 內
assign Max_1023 = &Out;
assign Odd      = ^Out;
assign Even     = !(Odd);           // 或寫成 Even = ~^Out

always @(posedge Clock or posedge Reset) begin
    if (Reset)  Out <= 10'd0;
    else        Out <= Out + 1'b1;
end
```

---

## 3. 講義第 46 頁：「將 Reg 修正為 wire 結果如何？」

Counter4 的 4 個旗標在 always 裡被賦值，所以**一定要宣告成 reg**。把 `Zero` 改成 wire（`output Zero`），vlog 編譯錯誤：
```
** Error: Counter4.v(27): (vlog-2110) Illegal reference to net "Zero".
```
規則：**在 always / initial 裡被賦值 → reg；用 assign 賦值 → wire**。
所以 Counter5 的旗標用 assign，就宣告成 wire（第 49 頁 `wire Zero, Max_1023, Even, Odd;`）。

---

## 4. 旗標寫在 always 內，會晚一個時脈

### 改成 `<=` 之後（本範例的 Counter4）
非阻隔式 `<=` 的右邊，讀的都是「這個時脈開始時的舊值」。
`Zero <= !(|Out)` 裡的 Out 是**加 1 之前**的 Out，所以旗標描述的是**上一個**計數值，**晚一個時脈**。

### 講義原本用 `=`
把 Counter4 改回講義的阻隔式 `=` 實際模擬，旗標就不會晚：
```
t=20  Out=0000000001(1)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=0 Odd=1
t=40  Out=0000000011(3)  | Counter4: Zero=0 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=1 Odd=0
```
因為 `Out = Out + 1` 先執行完，下一行的 `Zero = !(|Out)` 讀到的是新值。
但「在時脈 always 裡用 `=`」會帶來其他問題（見 [08_SISO](../08_SISO/SISO_說明.md) 第 4 節），所以本課程一律用 `<=`。

### 最好的寫法：Counter5
講義第 49 頁：**將判斷計數值的寫法，置於 always 區塊外「效能」較佳**。
- 旗標是純組合邏輯，**永遠**對應目前的 Out，不會晚。
- 不需要額外 4 個正反器來存旗標，硬體也比較小。

---

## 5. 預期輸出

(1) 重置後的前幾個時脈；(2) 中間 1000 多個時脈不印，直接跳到 1021 → 1023 → 0。

```
t=10     Out=0000000000(0)     | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=1 Max=0 Even=1 Odd=0
t=20     Out=0000000001(1)     | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1   ← Counter4 還是 0 的旗標
t=30     Out=0000000010(2)     | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=0 Odd=1
t=40     Out=0000000011(3)     | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=0 Even=1 Odd=0   ← 3 有兩個 1 → Even
t=50     Out=0000000100(4)     | Counter4: Zero=0 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
...
t=10240  Out=1111111111(1023)  | Counter4: Zero=0 Max=0 Even=0 Odd=1  | Counter5: Zero=0 Max=1 Even=1 Odd=0   ← Counter5：Max=1
t=10250  Out=0000000000(0)     | Counter4: Zero=0 Max=1 Even=1 Odd=0  | Counter5: Zero=1 Max=0 Even=1 Odd=0   ← Counter4 現在才 Max=1
t=10260  Out=0000000001(1)     | Counter4: Zero=1 Max=0 Even=1 Odd=0  | Counter5: Zero=0 Max=0 Even=0 Odd=1
```
（節錄，完整輸出在 tb 檔尾）

### 觀察重點
- **Counter5 的旗標永遠正確**：Out = 0 → Zero = 1；Out = 1023 → Max_1023 = 1；Out = 3 → Even = 1。
- **Counter4 的旗標都晚一格**：Out 已經是 0 了，Counter4 才說 Max_1023 = 1。
- 1023 = `1111111111` 有 10 個 1（偶數）→ Even = 1。

---

## 6. 重點整理

| 觀念 | 說明 |
|------|------|
| 縮減運算子 | `\|`、`&`、`^` 把多位元縮成 1 位元 |
| Even / Odd | 同位（1 的個數），不是數值奇偶 |
| always 內賦值 | 必須是 reg，宣告成 wire 會編譯錯誤 |
| 旗標放 always 內 + `<=` | 晚一個時脈 |
| 旗標放 always 外（assign） | 永遠和 Out 同步，硬體也較小 |
