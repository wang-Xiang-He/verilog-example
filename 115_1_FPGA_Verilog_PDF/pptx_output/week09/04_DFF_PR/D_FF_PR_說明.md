# 04_DFF_PR 範例說明：非同步重置（Reset）與預設（Preset）的 D 型正反器

## 1. 這個範例在做什麼？

範例 5：具有**非同步（Asynchronous）**重置（Reset）與預設（Preset）的 D_FF（講義第 9、10 頁）。

```
         ┌──────────┐
    D ──►│ D      Q │──► Q
 Reset ─o│ Reset    │       ← 小圓圈：低態動作（0 時有作用）
Preset ─o│ Preset   │
 Clock ─►│>Clock    │
         └──────────┘
```

| Reset | Preset | Q |
|-------|--------|---|
| 0 | ? | **立刻** 0 |
| 1 | 0 | **立刻** 1 |
| 1 | 1 | Clock 正緣時 = D |

「非同步」= Reset、Preset 一有作用就立刻改變 Q，**不等 Clock**。

---

## 2. 程式說明

### D_FF_PR.v（講義第 9 頁）
```verilog
module D_FF_PR (
    input      Clock,
    input      Reset,
    input      Preset,
    input      D,
    output reg Q
);
    always @(negedge Reset or negedge Preset or posedge Clock) begin
        if (!Reset)                 // Reset = 0
            Q <= 1'b0;              // 清除為 0
        else if (!Preset)           // Preset = 0
            Q <= 1'b1;              // 設定為 1
        else
            Q <= D;                 // 將 D 傳入 Q
    end
endmodule
```

### 非同步的寫法
- **把 Reset、Preset 也放進敏感清單**：它們一變，always 就執行，不必等 Clock。
- 低態動作，所以寫 `negedge`（由 1 變成 0 的那一刻），判斷時寫 `if (!Reset)`。
- 敏感清單有三個事件，進到 always 之後要自己判斷是誰觸發的：
  先檢查 Reset、再檢查 Preset，**都不是就一定是 Clock 正緣**。

### 講義寫的 `else if (Clock)`
講義最後一個分支是 `if (Clock) Q = D;`。能走到這裡的只剩 Clock 正緣，那時 Clock 一定是 1，所以 `if (Clock)` 一定成立，可以省略。
而且合成工具是靠「if 重置 ... else 一般動作」這個固定樣板來辨識非同步正反器，多一個 `if (Clock)` 不是標準寫法，可能讓工具無法正確辨識。所以這裡寫成單純的 `else`（ModelSim 模擬兩種寫法結果相同）。

---

## 3. 預期輸出

Clock 正緣在 5、15、25 ...；Reset、Preset 故意在**兩個正緣中間**變成 0。

```
t=5   Clock=1 Reset=1 Preset=1 D=1  ->  Q=1     ← 正緣：Q = D
t=12  Clock=0 Reset=0 Preset=1 D=1  ->  Q=0     ← Reset 變 0：立刻清 0（不等 t=15）
t=15  Clock=1 Reset=0 Preset=1 D=1  ->  Q=0     ← Reset 還是 0：維持 0
t=22  Clock=0 Reset=1 Preset=1 D=1  ->  Q=0     ← Reset 放開，Q 不會馬上變
t=25  Clock=1 Reset=1 Preset=1 D=1  ->  Q=1     ← 下一個正緣才 Q = D
t=35  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0
t=42  Clock=0 Reset=1 Preset=0 D=0  ->  Q=1     ← Preset 變 0：立刻設 1
t=52  Clock=0 Reset=1 Preset=1 D=0  ->  Q=1
t=55  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0     ← 正緣：Q = D = 0
t=65  Clock=1 Reset=1 Preset=1 D=1  ->  Q=1
t=75  Clock=1 Reset=1 Preset=1 D=0  ->  Q=0
```
（節錄，完整輸出在 tb 檔尾）

### 觀察重點
- **t=12、t=42**：Reset / Preset 一變成 0，Q 在**同一個時間點**就改變，和時脈無關。
- **t=22**：Reset 放開（0 → 1）不會改變 Q，要等下一個正緣。放開的那一刻是 `posedge Reset`，不在敏感清單裡。
- 和 [05_DFF_SR](../05_DFF_SR/D_FF_SR_說明.md)（同步重置）用同樣的測試順序，可以對照 t=12 那一行的差別。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 非同步重置 | 重置訊號放進敏感清單，不等時脈 |
| 低態動作 | `negedge Reset` + `if (!Reset)` |
| 判斷順序 | 先重置、再預設，最後才是一般動作 |
| `else if (Clock)` | 多餘，可省略 |
