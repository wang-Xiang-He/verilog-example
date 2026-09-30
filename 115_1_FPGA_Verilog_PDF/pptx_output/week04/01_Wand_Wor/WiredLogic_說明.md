# 01_Wand_Wor 範例說明：Wired-AND / Wired-OR

## 1. 這個範例在做什麼？

一條線如果被**兩個以上的訊號同時驅動**，結果是什麼？取決於線的型態：

| 型態 | 多重驅動的結果 | 對應的實際電路 |
|------|----------------|----------------|
| `wand` | 所有驅動值做 **AND** | 開集極（open collector）輸出接在一起 |
| `wor`  | 所有驅動值做 **OR**  | ECL（Emitter Coupled Logic）輸出接在一起 |
| `wire` | 值相同就是那個值；**不同就變 x** | 一般 CMOS 輸出接在一起 → 短路 |

```
  a ──┐                 a ──┐
      ├── c (wand)          ├── c (wor)
  b ──┘  c = a & b      b ──┘  c = a | b
```

---

## 2. 檔案說明

### wand_test.v
```verilog
module wand_test (
    input       a,
    input       b,
    output wand c
);
    assign c = a;
    assign c = b;      // c = a & b
endmodule
```
- 同一條 `c` 被兩個 `assign` 驅動。因為 `c` 宣告為 `wand`，模擬器自動把兩個值做 AND。
- 講義寫法是 `output c;` 再另外寫 `wand c;`；Verilog-2001 可以直接寫 `output wand c`。

### wor_test.v
和 `wand_test` 一樣，只是 `c` 宣告為 `wor`，結果變成 OR。

### wire_test.v（對照組）
講義第 4 頁右上角標註的「`wire c;`」情況：一般 `wire` 被兩個值不同的訊號驅動，模擬結果是 **x（未知）**。

### WiredLogic_tb.v
三個模組接同樣的 `a`、`b`，把 00、01、10、11 四種組合各跑一次。

---

## 3. 預期輸出

```
t=0   a=0 b=0  ->  wand=0  wor=0  wire=0
t=10  a=0 b=1  ->  wand=0  wor=1  wire=x    ← 兩個驅動值不同
t=20  a=1 b=0  ->  wand=0  wor=1  wire=x
t=30  a=1 b=1  ->  wand=1  wor=1  wire=1
```

### 觀察重點
- `wand` 欄就是 AND 真值表，`wor` 欄就是 OR 真值表（對照講義第 4、6 頁的波形）。
- `wire` 只有在 a、b **相同**時才有確定的值。一般設計中**一條 wire 只能有一個驅動源**，
  看到 x 通常代表接線錯誤（兩個 assign 寫到同一條線）。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `wand` | Wired-AND，多重驅動時做 AND |
| `wor` | Wired-OR，多重驅動時做 OR |
| `wire` 多重驅動 | 值不同時為 x，實務上應避免 |
| `x` | 未知值（0 或 1 無法決定） |
| `z` | 高阻抗（沒有人驅動），見 04_BiDir |
