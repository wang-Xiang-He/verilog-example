# 06_Always_Edge 範例說明：always 的位準觸發與邊緣觸發

## 1. 這個範例在做什麼？

同樣是 `f = a & b & c`，敏感清單不同，合成出來的電路就不同（講義第 19、20 頁）：

| 模組 | 敏感清單 | 何時計算 | 合成結果 |
|------|---------|---------|---------|
| And3_Level | `@(*)`（講義 `@(a or b or c)`） | 任一輸入改變 | 純 AND 閘（組合邏輯） |
| And3_Posedge | `@(posedge Clock)` | Clock 0 → 1 | AND 閘 + 正緣正反器 |
| And3_Negedge | `@(negedge Clock)` | Clock 1 → 0 | AND 閘 + 負緣正反器 |

```
                       ┌─────┐
  a,b,c ──► AND ──┬───►│ D  Q├──► f_pos
                  │    │ >   │◄── Clock（正緣）
                  │    └─────┘
                  └──────────────► f_level
```

---

## 2. 檔案說明

### And3_Level.v
```verilog
always @(*)
    f = a & b & c;
```
### And3_Posedge.v / And3_Negedge.v
```verilog
always @(posedge Clock)      // 或 @(negedge Clock)
    f <= a & b & c;
```
- 邊緣觸發的區塊改用**非阻隔式** `<=`（講義用 `=`），原因見 week03 的 03_Hierar 說明。

### Always_tb.v
- 時脈週期 20 ns：正緣在 10, 30, 50；負緣在 20, 40, 60。
- 輸入 `c` 故意在 15、25、35 這些**不是時脈邊緣**的時間改變。

---

## 3. 預期輸出

```
t=0   Clock=0  abc=110  ->  level=0  posedge=x  negedge=0
t=10  Clock=1  abc=110  ->  level=0  posedge=0  negedge=0   ← 正緣：取樣 110 → 0
t=15  Clock=1  abc=111  ->  level=1  posedge=0  negedge=0   ← level 立刻變
t=20  Clock=0  abc=111  ->  level=1  posedge=0  negedge=1   ← 負緣：取樣 111 → 1
t=25  Clock=0  abc=110  ->  level=0  posedge=0  negedge=1
t=30  Clock=1  abc=110  ->  level=0  posedge=0  negedge=1   ← 正緣：取樣 110 → 0
t=35  Clock=1  abc=111  ->  level=1  posedge=0  negedge=1
t=40  Clock=0  abc=111  ->  level=1  posedge=0  negedge=1
t=50  Clock=1  abc=111  ->  level=1  posedge=1  negedge=1   ← 正緣：取樣 111 → 1
t=60  Clock=0  abc=111  ->  level=1  posedge=1  negedge=1
```

### 觀察重點
- **level** 完全跟著 abc 走，就是一個 AND 閘。
- **posedge** 只在 10、30、50 更新；15~25 之間 abc 曾經是 111，但剛好錯過正緣，所以 posedge 沒看到。
- **negedge** 在 t=0 就變成 0：Clock 從**未初始化的 x 變成 0**，模擬器也把它當成負緣。
  而 posedge 在 t=0 還是 x，要等到 t=10 第一個正緣。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 位準觸發 | 敏感清單列出輸入（或 `@(*)`）→ 組合邏輯 |
| `posedge` | 0→1（也包含 x→1、0→x）|
| `negedge` | 1→0（也包含 x→0、1→x）|
| 邊緣觸發 | 合成為正反器，輸出只在時脈邊緣改變 |
| 非阻隔式 `<=` | 邊緣觸發的 always 一律使用 |
