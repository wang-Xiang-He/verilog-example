# 01_Latch_RS 範例說明：具重置、設定、致能的 D 型閂鎖（Latch）

## 1. 這個範例在做什麼？

本週（Sequential State）開始介紹**循序邏輯**：輸出不只看現在的輸入，還要看**之前的狀態**，也就是電路要能「記住」值。
最基本的記憶元件有兩種：

| 元件 | 觸發方式 | 什麼時候會變 |
|------|---------|-------------|
| **閂鎖（Latch）** | **準位**觸發（Level Trigger） | 致能訊號維持在作用準位的**整段期間**，輸出都跟著輸入走 |
| **正反器（Flip-Flop）** | **邊緣**觸發（Edge Trigger） | 只有在時脈**邊緣那一瞬間**取樣（見 [02_DFF_RS](../02_DFF_RS/DFF_RS_說明.md)） |

本範例：具有「重置」、「設定」以及「輸出致能」訊號控制的準位感測閂鎖（講義第 1 頁，範例 2）。

```
       ┌─────────┐
  D ──►│ D     Q │──► Q
       │         │
 Set ─►│ Set     │
Reset ►│ Reset   │
Enable►│ Enable  │
       └─────────┘
```

| Reset | Set | Enable | Q |
|-------|-----|--------|---|
| 1 | ? | ? | 0 |
| 0 | 1 | ? | 1 |
| 0 | 0 | 1 | D（透明） |
| 0 | 0 | 0 | Q（保持） |

**Priority：Reset > Set > Enable**

---

## 2. 程式說明

### Latch_RS.v（講義第 1 頁）
```verilog
module Latch_RS (
    input  Enable,
    input  Set,
    input  Reset,
    input  D,
    output Q
);
    assign Q = Reset ? 1'b0 : (Set ? 1'b1 : (Enable ? D : Q));
endmodule
```

- 巢狀條件運算子：**先判斷的優先**，所以 Reset > Set > Enable。
- 最內層的 `: Q` 把**輸出接回自己**。Enable = 0 時 Q = Q，這個回授迴路讓電路能記住值，就是閂鎖。
- 只用一行 `assign` 就寫出記憶元件，但這是**組合邏輯的迴授**。合成工具通常會警告「combinational loop」或「latch inferred」，實務上要避免不小心寫出這種結構。

---

## 3. 講義第 2 頁：「Enable 輸入埠不見了，自行模擬」

講義第 2 頁的波形用 **Clock 當作 Enable**，所以畫面上沒有 Enable 訊號。本範例的 testbench 自己控制 Enable，把每一種情況都跑一次。

---

## 4. 預期輸出

```
t=0   Reset=0 Set=0 Enable=0 D=0  ->  Q=x     ← 從來沒設定過 → 不確定
t=10  Reset=1 Set=0 Enable=0 D=0  ->  Q=0     ← 重置
t=20  Reset=0 Set=1 Enable=0 D=0  ->  Q=1     ← 設定
t=30  Reset=0 Set=1 Enable=1 D=0  ->  Q=1     ← Set 優先於 Enable
t=40  Reset=0 Set=0 Enable=1 D=0  ->  Q=0     ← 換 Enable 控制 → Q = D
t=45  Reset=0 Set=0 Enable=1 D=1  ->  Q=1     ← D 一變 Q 立刻變（透明）
t=50  Reset=0 Set=0 Enable=1 D=0  ->  Q=0
t=55  Reset=0 Set=0 Enable=1 D=1  ->  Q=1
t=60  Reset=0 Set=0 Enable=0 D=1  ->  Q=1     ← 關掉 Enable → 鎖住 1
t=65  Reset=0 Set=0 Enable=0 D=0  ->  Q=1     ← D 怎麼變 Q 都不動
t=70  Reset=0 Set=0 Enable=0 D=1  ->  Q=1
t=75  Reset=0 Set=0 Enable=0 D=0  ->  Q=1
t=80  Reset=1 Set=1 Enable=1 D=0  ->  Q=0     ← 三個都是 1：Reset 優先
```

### 觀察重點
- **t=40~60（Enable = 1）**：Q 跟著 D 一起變，**不必等時脈邊緣**，這就是準位觸發。閂鎖在 Enable = 1 時像一扇打開的門，又叫「透明（transparent）」。
- **t=60 之後（Enable = 0）**：門關上，Q 停在關門那一刻的值（1）。
- 講義第 2 頁波形中標「Unknown」的那段：Q 在某段時間是不確定值，例如 Enable 和 D 同時變化，或 D 本身是 x。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| 閂鎖（Latch） | 準位觸發，Enable 期間輸出 = 輸入 |
| 記憶 | Enable = 0 時保持，靠輸出回授 |
| 優先權 | 巢狀 `? :` 先判斷的優先 |
| 和正反器的差別 | 正反器只在邊緣那一瞬間取樣 |
