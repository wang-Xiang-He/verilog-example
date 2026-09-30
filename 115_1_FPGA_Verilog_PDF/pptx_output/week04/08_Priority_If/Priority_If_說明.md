# 08_Priority_If 範例說明：if ... else 與優先權

## 1. 這個範例在做什麼？

`if ... else` 有**先後順序**：先檢查的條件成立，後面的就不看了。所以它天生就是**優先權解碼器**（Priority Decoder）。
講義第 25、26 頁用兩種寫法做出同一個電路：

| X Y Z 條件 | 輸出 |
|-----------|------|
| Z = 1（最優先） | Result4 |
| 否則 Y = 1 | Result3 |
| 否則 X = 1 | Result2 |
| 都不成立 | Result1 |

```
Result1 ─┐
         MUX ─┐
Result2 ─┘ X  MUX ─┐
     Result3 ─┘ Y  MUX ──► Out
          Result4 ─┘ Z      （Z 最靠近輸出 = 優先權最高）
```

---

## 2. 檔案說明

### Prio_IfElse.v（範例 1：巢狀 if ... else）
```verilog
if (Z)       Out = Result4;
else if (Y)  Out = Result3;
else if (X)  Out = Result2;
else         Out = Result1;
```
**先寫的優先權高。**

### Prio_MultiIf.v（範例 2：預設值 + 多個獨立的 if）
```verilog
Out = Result1;          // 預設值
if (X) Out = Result2;
if (Y) Out = Result3;
if (Z) Out = Result4;   // 最後執行，會蓋掉前面的
```
**後寫的優先權高**，因為 always 裡的敘述由上往下執行，最後一次賦值才算數。

### 敏感清單漏列（講義的小問題）
講義寫 `always @(X or Y or Z)`，但輸出也取決於 `Result1`~`Result4`。
如果 Result 改變而 X、Y、Z 沒變，模擬時 always 不會重新執行，**模擬結果和合成出來的電路不一樣**。
改用 `@(*)` 就不會漏。

### Priority_If_tb.v
把 Result1~4 設成 1~4，輸出是幾就知道選到哪一個；XYZ 從 000 跑到 111，並比較兩種寫法。

---

## 3. 預期輸出

```
X=0 Y=0 Z=0  ->  if-else: Result1   multi-if: Result1         same
X=0 Y=0 Z=1  ->  if-else: Result4   multi-if: Result4         same
X=0 Y=1 Z=0  ->  if-else: Result3   multi-if: Result3         same
X=0 Y=1 Z=1  ->  if-else: Result4   multi-if: Result4         same
X=1 Y=0 Z=0  ->  if-else: Result2   multi-if: Result2         same
X=1 Y=0 Z=1  ->  if-else: Result4   multi-if: Result4         same
X=1 Y=1 Z=0  ->  if-else: Result3   multi-if: Result3         same
X=1 Y=1 Z=1  ->  if-else: Result4   multi-if: Result4         same
```

### 觀察重點
- 只要 Z = 1，不管 X、Y 是什麼都選 Result4 → Z 優先權最高。
- 兩種寫法 8 種組合全部相同。
- 範例 2「先給預設值」的寫法還有一個好處：保證每條路徑都有給 `Out` 值，**不會產生 Latch**。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| if ... else | 先寫的條件優先權高 → Priority Decoder |
| 多個獨立 if | 後寫的蓋掉先寫的 → 後寫的優先權高 |
| 預設值 | 在 always 開頭先賦值，避免 Latch |
| 敏感清單 | 要包含所有讀到的訊號，用 `@(*)` 最保險 |
