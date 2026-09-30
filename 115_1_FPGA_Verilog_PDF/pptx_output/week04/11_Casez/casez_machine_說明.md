# 11_Casez 範例說明：casez

## 1. 這個範例在做什麼？

在時脈正緣依 `Condition` 的**最低位元**決定輸出，最高位元不在乎（講義第 34~36 頁）：

| Condition | Out |
|-----------|-----|
| ?0（最低位元 0） | 000 |
| ?1（最低位元 1） | 001 |
| 其他（最低位元是 x 或 z） | 111 |

---

## 2. 檔案說明

### casez_machine.v
```verilog
always @(posedge Clock) begin
    casez (Condition)
        2'bz0   : Out <= 3'b000;
        2'bz1   : Out <= 3'b001;
        default : Out <= 3'b111;
    endcase
end
```
- `casez` 中，項目的 `z`（或 `?`）代表**不在乎**。`2'bz0` 等於 `2'b?0`。
- 建議寫 `?`：`z` 在別的地方代表「高阻抗」，容易混淆。
- 在時脈正緣更新，改用 `<=`。

### casex 與 casez 的差別

| | 不在乎的符號 |
|---|---|
| `casez` | `z`、`?` |
| `casex` | `x`、`z`、`?` |

講義第 36 頁說本例把 casez 換成 casex 也正確；因為項目裡只有 z，兩者結果一樣。
實務上較建議用 `casez`：`casex` 連**輸入**中的 x 也當不在乎，模擬時可能把錯誤（x）藏起來。

---

## 3. 預期輸出

```
t=0   Clock=0 Condition=00  ->  Out=xxx   ← 還沒遇到正緣
t=5   Clock=1 Condition=00  ->  Out=000
t=10  Clock=0 Condition=01  ->  Out=000
t=15  Clock=1 Condition=01  ->  Out=001
t=20  Clock=0 Condition=10  ->  Out=001
t=25  Clock=1 Condition=10  ->  Out=000   ← 10 和 00 結果相同
t=30  Clock=0 Condition=11  ->  Out=000
t=35  Clock=1 Condition=11  ->  Out=001
t=40  Clock=0 Condition=1x  ->  Out=001
t=45  Clock=1 Condition=1x  ->  Out=111   ← 最低位元 x，兩項都不符合 → default
t=50  Clock=0 Condition=x0  ->  Out=111
t=55  Clock=1 Condition=x0  ->  Out=000   ← 最高位元 x，但那一位不在乎 → 符合 ?0
```

### 觀察重點
- Out 只在時脈正緣（5, 15, 25 …）改變。
- `1x`：最低位元 x 在 casez 中**不是**不在乎（casez 只把 z/? 當不在乎），所以走 default。
- `x0`：最高位元剛好對到項目中的 `z`（不在乎），所以仍符合 `2'bz0`。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `casez` | 項目中的 z / ? 是不在乎位元 |
| `?` | 和 z 相同，建議用 ? 比較清楚 |
| `casex` vs `casez` | casex 連 x 也不在乎，較容易藏錯 |
| default | 輸入含 x / z 時的保護 |
