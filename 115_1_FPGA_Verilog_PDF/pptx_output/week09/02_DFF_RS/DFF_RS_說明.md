# 02_DFF_RS 範例說明：具重置、設定的 D 型正反器（以及除 2 功能）

## 1. 這個範例在做什麼？

### 正反器（講義第 3 頁）
- **正反器**：資料只在某些控制訊號啟動時才進入閂鎖電路的雙穩態電路。
- **正反器與閂鎖的區別**：正反器（Flip-Flop）是使用**邊緣觸發（Edge Trigger）**的方式動作；閂鎖（Latch）是使用**準位觸發（Level Trigger）**。
- D 型正反器：時脈將輸入端 D 的資料取樣後，儲存於正反器中，並呈現在輸出端。
- **特性方程式**：Q(t+1) = D（t+1 代表下一個時脈來臨的時間）

### 本範例（講義第 4~6 頁，範例 2）
具有「重置」及「設定」控制訊號的正反器，還多了一個反相輸出 `Q_Bar`（Q'）。

```
       ┌────────────┐
  D ──►│ D        Q │──► Q
 Set ─►│ Set        │
Reset ►│ Reset      │
Clock ►│>Clock   Q' │──► Q_Bar
       └────────────┘
```

| Clock 正緣時 | Q | Q_Bar |
|-------------|---|-------|
| Reset = 1 | 0 | 1 |
| Reset = 0，Set = 1 | 1 | 0 |
| Reset = 0，Set = 0 | D | ~D |

---

## 2. 程式說明

### DFF_RS.v
```verilog
module DFF_RS (
    input      Clock,
    input      Set,
    input      Reset,
    input      D,
    output reg Q,
    output reg Q_Bar
);
    always @(posedge Clock) begin
        if (Reset) begin            // 重置（重要功能）
            Q     <= 1'b0;
            Q_Bar <= 1'b1;
        end
        else if (Set) begin         // 設定（重要功能）
            Q     <= 1'b1;
            Q_Bar <= 1'b0;
        end
        else begin                  // 正常輸入：D 至 Q，Q_Bar = D 取 Not
            Q     <= D;
            Q_Bar <= ~D;
        end
    end
endmodule
```
- 敏感清單只有 `posedge Clock`：Reset、Set 也要等正緣才有作用（**同步**）。
- `if ... else if ... else`：Reset 先判斷，優先權最高。
- 講義用阻隔式 `=`；時脈觸發的 always 改用非阻隔式 `<=`。

---

## 3. 講義第 6 頁：「D_FF 具有除 2 功能，如何修正 Testbench 以顯示該項功能？」

把 **Q_Bar 接回 D**：
```
       ┌────────────┐
  ┌───►│ D        Q │──► Qd     每個正緣：Q = 上一次的 Q_Bar = 上一次 Q 的反相
  │    │            │                → Q 每個正緣反相一次
  │    │>Clock   Q' │──┐             → Q 的週期 = 2 個 Clock 週期 = 頻率除以 2
  │    └────────────┘  │
  └────────────────────┘
```

testbench 多放一顆 `u_div`：
```verilog
DFF_RS u_div (.Clock(Clock), .Set(1'b0), .Reset(Reset), .D(Qd_Bar), .Q(Qd), .Q_Bar(Qd_Bar));
//                                                       ^^^^^^^^ D 接到自己的 Q_Bar
```
**一定要先重置**：一開始 Qd 是 x，Qd_Bar 也是 x，接回 D 還是 x，永遠除不起來。重置後 Qd = 0，才能開始 0 → 1 → 0 → 1。

---

## 4. 預期輸出

Clock 週期 10 ns，正緣在 5、15、25 ...

```
t=0   Clock=0 Set=1 Reset=0 D=1  ->  Q=x Q_Bar=x   |  div2: Qd=x
t=5   Clock=1 Set=1 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=x     ← 設定
t=10  Clock=0 Set=0 Reset=1 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=x
t=15  Clock=1 Set=0 Reset=1 D=1  ->  Q=0 Q_Bar=1   |  div2: Qd=0     ← 重置（兩顆都重置）
t=25  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=1     ← Q = D；Qd 開始反相
t=35  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=0
t=45  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=1
t=55  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=0
t=65  Clock=1 Set=0 Reset=0 D=1  ->  Q=1 Q_Bar=0   |  div2: Qd=1
t=75  Clock=1 Set=0 Reset=0 D=0  ->  Q=0 Q_Bar=1   |  div2: Qd=0
```
（只列出正緣那幾行，完整輸出在 tb 檔尾）

### 觀察重點
- 講義第 6 頁波形的 1、0、1：Set=1 → Q=1、Reset=1 → Q=0、之後 D=1 → Q=1。
- Q_Bar 永遠是 Q 的反相。
- **除 2**：Qd 在 15、35、55、75 是 0，在 25、45、65 是 1，每 20 ns 一個週期，是 Clock（10 ns）的兩倍。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 正反器 vs 閂鎖 | 邊緣觸發 vs 準位觸發 |
| 特性方程式 | Q(t+1) = D |
| 同步重置 / 設定 | 敏感清單只有 Clock，正緣才檢查 |
| 除 2 | Q_Bar 接回 D，Q 每個正緣反相 |
| 先重置 | 不然 x 接回去還是 x |
