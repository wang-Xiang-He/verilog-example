# 05_DFF_SR 範例說明：同步重置的 D 型正反器

## 1. 這個範例在做什麼？

範例 6：具有**同步重置（Synchronous Reset）**的 D 型正反器（講義第 11、12 頁）。
Reset 是低態動作，但**只有在 Clock 正緣時才會檢查 Reset**。

```
         ┌─────────────┐
    D ──►│ D         Q │──► Q
         │ Synchronous │
 Reset ─o│ Reset       │
 Clock ─►│>Clock       │
         └─────────────┘
```

---

## 2. 程式說明

### D_FF_SR.v（講義第 11 頁）
```verilog
module D_FF_SR (
    input      Clock,
    input      Reset,
    input      D,
    output reg Q
);
    always @(posedge Clock) begin   // 同步用法：敏感清單只有 Clock
        if (!Reset)                 // Reset = 0
            Q <= 1'b0;              // 清除為 0
        else
            Q <= D;                 // 將 D 傳入 Q
    end
endmodule
```

### 同步 vs 非同步：只差在敏感清單
| | 非同步（[04_DFF_PR](../04_DFF_PR/D_FF_PR_說明.md)） | 同步（本範例） |
|---|---|---|
| 敏感清單 | `negedge Reset or posedge Clock` | `posedge Clock` |
| Reset 何時有作用 | Reset 變 0 的那一刻 | 下一個 Clock 正緣 |
| Reset 太短（沒有跨過正緣） | 還是會清 0 | 被忽略 |
| 優點 | 不需要時脈也能重置（例如上電時時脈還沒穩定） | 整個電路都在時脈邊緣改變，時序分析簡單 |

兩種都很常用；同一個專案通常會統一用其中一種。

---

## 3. 預期輸出

測試順序和 04_DFF_PR 的 Reset 部分相同：Reset 在兩個正緣中間變成 0。

```
t=5   Clock=1 Reset=1 D=1  ->  Q=1     ← 正緣：Q = D
t=12  Clock=0 Reset=0 D=1  ->  Q=1     ← Reset 變 0，但 Q 還沒變！
t=15  Clock=1 Reset=0 D=1  ->  Q=0     ← 正緣才清 0
t=22  Clock=0 Reset=1 D=1  ->  Q=0
t=25  Clock=1 Reset=1 D=1  ->  Q=1
t=35  Clock=1 Reset=1 D=0  ->  Q=0
t=55  Clock=1 Reset=1 D=1  ->  Q=1
t=62  Clock=0 Reset=0 D=1  ->  Q=1     ← 又一次：Reset 變 0
t=65  Clock=1 Reset=0 D=1  ->  Q=0     ← 等到正緣才清 0
t=72  Clock=0 Reset=1 D=1  ->  Q=0
t=75  Clock=1 Reset=1 D=1  ->  Q=1
```
（節錄，完整輸出在 tb 檔尾）

### 觀察重點
- **t=12**：同一個時間點，04_DFF_PR 的 Q 已經是 0，這裡的 Q 還是 1；要到 **t=15** 的正緣才清 0（講義第 12 頁紅圈）。
- Reset 要「跨過」一個正緣才有作用。如果 Reset 只是在兩個正緣之間短暫變成 0（例如 t=12~14），同步重置完全看不到。

### 寫 testbench 要避免的情況
如果 Reset 剛好在**正緣的同一個時間點**改變（例如 t=65 同時 `Reset = 1` 和 `Clock` 0→1），
正反器看到的是改變前還是改變後的 Reset，取決於模擬器先執行哪一個，結果不確定（競爭條件）。
本範例的 Reset 都在 2、12、22 ... 這種「時脈中間」改變，避開這個問題。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 同步重置 | 敏感清單只有 Clock，正緣才檢查 Reset |
| 和非同步的差別 | 清 0 的時間點不同 |
| testbench 原則 | 輸入不要和時脈邊緣同時改變 |
