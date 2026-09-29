# 16_Monitor_Stop 範例說明：$monitor、$strobe、$stop / $finish

## 1. 這個範例在做什麼？

這個範例**沒有電路**，只有 testbench（模組名 `monitest`），示範 testbench 常用的系統函式：

| 函式 | 作用 |
|------|------|
| `$monitor` | 持續監視，清單中的變數**一有變化就自動印** |
| `$strobe` | 在**該時間點所有變化結束後**才印一次 |
| `$stop` | 暫停模擬（ModelSim 保留波形，可以繼續） |
| `$finish` | 結束模擬 |

---

## 2. 程式說明

### 產生變化的變數
```verilog
integer s, t;

initial begin
    s = 4;
    t = 6;
    forever begin
        #5 s = s + t;      // 每 10ns 的前半：s 更新
        #5 t = s - 1;      // 每 10ns 的後半：t 更新
    end
end
```
- `integer`：32 位元有號整數，testbench 中常用。
- `forever`：無窮迴圈，要靠 `$stop` / `$finish` 結束模擬。
- 時間軸上 s 和 t **輪流**每 5 ns 改變一次。

### $monitor
```verilog
initial $monitor($time, "  s=%0d, t=%0d", s, t);
```
- **只要寫一次**，之後 `s` 或 `t`（或 `$time` 以外的參數）一變就自動印一行。
- 同一時間同時只能有一個 `$monitor` 有效（後呼叫的會取代前一個）。
- 可以用 `$monitoroff` / `$monitoron` 暫停 / 恢復。

### $strobe
```verilog
initial #12 $strobe("[strobe] t=%0d  s=%0d, t=%0d", $time, s, t);
```
- 在 12 ns 時印一次，但會等**這個時間點所有指定都完成後**才印，保證看到穩定的最終值。

### $display vs $strobe vs $monitor

| 函式 | 印幾次 | 什麼時候印 |
|------|--------|-----------|
| `$display` | 呼叫一次印一次 | **立刻**印（同時間點其他指定可能還沒做） |
| `$strobe` | 呼叫一次印一次 | 該時間點**結束時**印 |
| `$monitor` | 呼叫一次，之後自動重複 | 變數有變化的時間點**結束時**印 |

> 當同一時間點有好幾個 `always` / `initial` 同時改變數時，`$display` 印到的可能是舊值；
> `$strobe` / `$monitor` 印的一定是最終值。

### $stop vs $finish
```verilog
initial #40 $stop;
```
- 講義原本用 `$finish`。在 ModelSim 裡 `$finish` 會跳出「是否結束」的詢問視窗，
  所以本課程範例都改用 `$stop`：**暫停**模擬，Transcript 和波形都保留，可再輸入 `run` 繼續。
- EDA Playground 等線上環境要用 `$finish` 才會結束並輸出波形。

---

## 3. 預期輸出

```
                    0  s=4, t=6
                    5  s=10, t=6      ← s = 4 + 6
                   10  s=10, t=9      ← t = 10 - 1
[strobe] t=12  s=10, t=9              ← $strobe 在 12ns 印一次
                   15  s=19, t=9      ← s = 10 + 9
                   20  s=19, t=18     ← t = 19 - 1
                   25  s=37, t=18
                   30  s=37, t=36
                   35  s=73, t=36
```

### 觀察重點
- `$monitor` 每 5 ns 自動印一行，因為每 5 ns 就有一個變數改變。
- `$strobe` 只印一次（t=12），那時沒有變數在變，所以值和 t=10 相同。
- `$time` 的顯示寬度是**固定的**（64 位元時間值），所以前面有很多空白；
  若想去掉空白，可以用 `$monitor("%0d  s=%0d, t=%0d", $time, s, t)`。
- 在 t=40，`t` 會改變，同時 `$stop` 也被執行，兩者誰先發生由模擬器決定；
  通常 `$stop` 先暫停，所以看不到 t=40 那一行（輸入 `run` 繼續時才會印出）。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `$monitor` | 寫一次，變數一變就自動印 |
| `$strobe` | 時間點結束時印，看到的一定是穩定值 |
| `$display` | 立即印，可能看到尚未更新的值 |
| `$stop` | 暫停模擬（ModelSim 建議用） |
| `$finish` | 結束模擬 |
| `forever` | 無窮迴圈，testbench 用 |
| `integer` | 32 位元有號整數 |
