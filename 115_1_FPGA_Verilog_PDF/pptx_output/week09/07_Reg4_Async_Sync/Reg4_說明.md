# 07_Reg4_Async_Sync 範例說明：非同步重置 vs 同步重置的 4 位元暫存器

## 1. 這個範例在做什麼？

兩個真正有時脈的 4 位元暫存器（講義第 15~18 頁），差別只在重置的方式：

| 模組 | 講義 | 重置方式 |
|------|------|---------|
| `RAS_NRPC` | 範例 1（第 15、16 頁） | **非同步**負準位重置 + 時脈正緣觸發 |
| `RS_NRPC` | 範例 2（第 17、18 頁） | **同步**重置 + 時脈正緣觸發 |

模組名稱的意思：R = Register、A = Asynchronous、S = Synchronous、NR = Negative Reset、PC = Positive Clock。

```
          4
 Reg_In ─/─►┌──────────────┐  4
            │ 4 Bits       │─/─► Reg_Out
  Reset ───o│ Register     │
  Clock ───►│>             │
            └──────────────┘
```

這和 [04_DFF_PR](../04_DFF_PR/D_FF_PR_說明.md) / [05_DFF_SR](../05_DFF_SR/D_FF_SR_說明.md) 是同樣的觀念，只是從 1 位元變成 4 位元：**4 位元暫存器 = 4 個 D 型正反器共用 Clock 和 Reset**。

---

## 2. 程式說明

### RAS_NRPC.v（非同步）
```verilog
always @(negedge Reset or posedge Clock) begin  // 非同步負緣重置
    if (!Reset)                 // Reset = 0
        Reg_Out1 <= 4'd0;       // 清除為 0
    else                        // Reset = 1 且 Clock = posedge
        Reg_Out1 <= Reg_In;     // 將 Reg_In 傳入 Reg_Out1
end
```

### RS_NRPC.v（同步）
```verilog
always @(posedge Clock) begin   // 在 posedge Clock 時才執行 begin ... end 內的敘述
    if (!Reset)                 // Reset = 0
        Reg_Out3 <= 4'd0;
    else
        Reg_Out3 <= Reg_In;
end
```

### 講義的標題寫錯了
第 17 頁的標題是「**同步正準位重置**」，但程式寫的是 `if (!Reset)`，也就是 **Reset = 0 時清除**，實際上是**負準位**。以程式為準。

---

## 3. 預期輸出

同一組輸入同時餵給兩顆。Clock 正緣在 5、15、25 ...；Reset 在 t=22（兩個正緣中間）變成 0。

```
t=0   Clock=0 Reset=1 Reg_In=0001  ->  async Reg_Out1=xxxx   sync Reg_Out3=xxxx
t=5   Clock=1 Reset=1 Reg_In=0001  ->  async Reg_Out1=0001   sync Reg_Out3=0001   ← 正緣載入
t=15  Clock=1 Reset=1 Reg_In=0011  ->  async Reg_Out1=0011   sync Reg_Out3=0011
t=22  Clock=0 Reset=0 Reg_In=0010  ->  async Reg_Out1=0000   sync Reg_Out3=0011   ← 差別在這裡
t=25  Clock=1 Reset=0 Reg_In=0010  ->  async Reg_Out1=0000   sync Reg_Out3=0000   ← 同步的到正緣才清
t=32  Clock=0 Reset=1 Reg_In=0100  ->  async Reg_Out1=0000   sync Reg_Out3=0000
t=35  Clock=1 Reset=1 Reg_In=0100  ->  async Reg_Out1=0100   sync Reg_Out3=0100
t=45  Clock=1 Reset=1 Reg_In=1101  ->  async Reg_Out1=1101   sync Reg_Out3=1101
t=55  Clock=1 Reset=1 Reg_In=1010  ->  async Reg_Out1=1010   sync Reg_Out3=1010
t=65  Clock=1 Reset=1 Reg_In=0111  ->  async Reg_Out1=0111   sync Reg_Out3=0111
```
（節錄，完整輸出在 tb 檔尾）

### 觀察重點
- Reset = 1 時，兩顆完全一樣：Reg_In 在時脈中間改變，Reg_Out 要等到正緣才更新（講義第 16、18 頁的箭頭）。
- **t=22**：Reset 變 0，非同步的 Reg_Out1 **立刻**變 0000；同步的 Reg_Out3 還是 0011，到 **t=25** 才清 0。
- 講義波形上 Reg_In 有 `000x`、`000z` 這種值，是講義的 testbench 故意放的不確定值；本範例只用 0 / 1，方便對照。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| n 位元暫存器 | n 個正反器共用 Clock / Reset |
| 非同步重置 | `negedge Reset` 在敏感清單 → 立刻清除 |
| 同步重置 | 只有 `posedge Clock` → 正緣才清除 |
| 模組命名 | RAS / RS、NR、PC 是功能的縮寫 |
