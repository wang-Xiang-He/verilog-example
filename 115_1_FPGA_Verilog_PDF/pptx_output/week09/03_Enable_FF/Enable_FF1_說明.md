# 03_Enable_FF 範例說明：具有致能控制的正反器

## 1. 這個範例在做什麼？

具有「致能」輸出控制訊號的正反器（講義第 7、8 頁，例 3）。

```
          ┌──────────────┐
    D ───►│ D          Q │──► Q
 Enable ─►│ Enable       │
Condition►o Condition    │      ← 小圓圈：低態動作
  Clock ─►│>Clock        │
          └──────────────┘
```

| Clock 正緣時 | Q |
|-------------|---|
| Enable = 1，Condition = 0 | D |
| Enable = 1，Condition = 1 | Q（保持） |
| Enable = 0 | x（不確定值） |

---

## 2. 程式說明

### Enable_FF1.v（講義第 7 頁）
```verilog
always @(posedge Clock) begin
    if (Enable)                         // 「致能」輸出
        Q <= (~Condition) ? D : Q;      // 若 Condition = 0，則 Q = D
    else
        Q <= 1'bx;                      // 設定為 x（不確定值，Unknown Value）
end
```
- `(~Condition) ? D : Q`：Condition = 0 → 取 D；Condition = 1 → 取 Q 自己，也就是保持。
- 實務上 **Enable = 0 時通常是「保持」**，不會故意設成 x。這裡設成 x，是為了讓模擬時一眼看出「這段時間沒有致能」。
  合成時 x 會被當成「不在乎（don't care）」，工具可以任意選 0 或 1，所以硬體上的結果不一定。

---

## 3. 講義第 8 頁：「D_FF 具有除 2 功能，如何修正 Testbench 以顯示該項功能？」

和 [02_DFF_RS](../02_DFF_RS/DFF_RS_說明.md) 一樣要把反相輸出接回 D，但這顆**沒有 Q_Bar**，也**沒有 Reset**：
1. 在 testbench 用 `~Qd` 接回 D。
2. 問題：一開始 Qd = x，`~x` 還是 x，永遠除不起來。
3. 解法：第一個時脈先讓 D = 0，給 Qd 一個初值，之後才接 `~Qd`：
```verilog
wire Dd = init ? 1'b0 : ~Qd;       // init = 1 時載入 0，之後 init = 0 接成除 2
Enable_FF1 u_div (.Clock(Clock), .Condition(1'b0), .Enable(1'b1), .D(Dd), .Q(Qd));
```

---

## 4. 預期輸出

Clock 正緣在 5、15、25 ...（只列正緣那幾行）

```
t=5   Clock=1 Enable=0 Condition=0 D=1  ->  Q=x   |  div2: Qd=0     ← Enable=0 → x；u_div 載入 0
t=15  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1     ← Q = D
t=25  Clock=1 Enable=1 Condition=0 D=0  ->  Q=0   |  div2: Qd=0
t=35  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1
t=45  Clock=1 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=0     ← Condition=1：保持，不理 D
t=55  Clock=1 Enable=1 Condition=1 D=0  ->  Q=1   |  div2: Qd=1
t=65  Clock=1 Enable=1 Condition=1 D=1  ->  Q=1   |  div2: Qd=0
t=75  Clock=1 Enable=1 Condition=0 D=1  ->  Q=1   |  div2: Qd=1     ← 又跟著 D
t=85  Clock=1 Enable=0 Condition=0 D=1  ->  Q=x   |  div2: Qd=0     ← 不致能 → x
```

### 觀察重點
- 和講義第 8 頁一樣：一開始 Enable = 0，Q 是 x（紅線）；之後 Q = D 的區段、Q = Q 的區段。
- t=45~65：D 從 0 變到 1，Q 還是 1，因為 Condition = 1 是「保持」。
- u_div 的 Qd 每個正緣反相一次：0、1、0、1 ...，週期是 Clock 的兩倍。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 致能 | Enable = 1 才更新 |
| `cond ? D : Q` | 保持 = 把自己的值再存一次 |
| 設成 x | 只是模擬上的標記，合成時是 don't care |
| 除 2 需要初值 | 沒有 Reset 時，在 testbench 先載入一個已知值 |
