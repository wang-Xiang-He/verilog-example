# 07_If_Reset 範例說明：if 敘述與正 / 負準位 Reset

## 1. 這個範例在做什麼？

用 `if` 做一個有 Reset 的 4 位元暫存器，講義第 22、23 頁共 4 種寫法，分成兩類：

| 類型 | 何時清 0 | 寫法（兩種等價） |
|------|---------|-----------------|
| 正準位（High Active） | Reset = **1** | `if (Reset == 1'b1)` ＝ `if (Reset)` |
| 負準位（Low Active）  | Reset = **0** | `if (Reset == 1'b0)` ＝ `if (!Reset)` |

實際電路常用負準位 Reset，訊號名稱會加上 `_n` 或 `_b`（例如 `rst_n`）提醒是 Low Active。

---

## 2. 檔案說明

### Reg_RstHigh.v
```verilog
always @(posedge Clock) begin
    if (Reset)
        Out <= 4'b0;
    else
        Out <= In_Data;
end
```
### Reg_RstLow.v
只差在 `if (!Reset)`。

- 講義 `Out` 的寬度沒寫，本範例用 4 位元。
- `if` 放在 `@(posedge Clock)` 裡面 → **同步 Reset**：就算 Reset 已經有效，也要等到時脈正緣才會清 0。
  （非同步 Reset 會寫成 `@(posedge Clock or posedge Reset)`，之後的章節會介紹。）

### If_Reset_tb.v
兩個暫存器接**同一條** `Reset`，所以任何時刻兩者的行為剛好相反。

---

## 3. 預期輸出

```
t=0   Clock=0 Reset=1 In_Data=a  ->  Out_H=x  Out_L=x   ← 還沒遇到正緣
t=5   Clock=1 Reset=1 In_Data=a  ->  Out_H=0  Out_L=a   ← H 清 0；L 存資料
t=10  Clock=0 Reset=1 In_Data=5  ->  Out_H=0  Out_L=a
t=15  Clock=1 Reset=1 In_Data=5  ->  Out_H=0  Out_L=5
t=20  Clock=0 Reset=0 In_Data=5  ->  Out_H=0  Out_L=5   ← Reset 變了，但還沒到正緣
t=25  Clock=1 Reset=0 In_Data=5  ->  Out_H=5  Out_L=0   ← 正緣：兩者行為對調
t=30  Clock=0 Reset=0 In_Data=3  ->  Out_H=5  Out_L=0
t=35  Clock=1 Reset=0 In_Data=3  ->  Out_H=3  Out_L=0
t=40  Clock=0 Reset=1 In_Data=3  ->  Out_H=3  Out_L=0
t=45  Clock=1 Reset=1 In_Data=3  ->  Out_H=0  Out_L=3
```

### 觀察重點
- **t=20**：Reset 已經從 1 變 0，但 `Out_L` 沒有馬上清 0，等到 t=25 正緣才動作 → 這就是「同步」。
- t=0 兩個輸出都是 x：Reset 也要等正緣才生效，所以第一個正緣之前暫存器沒有確定的值。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `if (Reset)` | 等同 `if (Reset == 1'b1)`，High Active |
| `if (!Reset)` | 等同 `if (Reset == 1'b0)`，Low Active |
| 同步 Reset | if 在 `@(posedge Clock)` 內，要等時脈邊緣 |
| `!` 與 `~` | `!` 是邏輯反（結果 1 位元），`~` 是逐位元反；1 位元訊號兩者結果相同 |
