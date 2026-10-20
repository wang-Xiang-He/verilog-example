# 06_Timescale 範例說明：`timescale 時間單位與時間精度

## 1. 這個範例在做什麼？

`` `timescale `` 用來定義模組中的**模擬時間單位**和**時間精度**（講義第 18 頁）。

```
`timescale <時間單位>/<時間精度>
```

| | 意思 | 本範例 |
|---|---|---|
| 時間單位 | `#1` 代表多久 | 10 ns |
| 時間精度 | 時間最小能分到多細；更細的部分**四捨五入** | 1 ns |

本範例只有一個檔案、沒有電路，用一個延遲 `#1.65` 示範四捨五入，以及三種顯示時間的方法有什麼不同。

> 之前每個範例開頭的 `` `timescale 1ns/1ps `` 就是：`#1` = 1 ns，精度到 1 ps。

---

## 2. 程式說明

```verilog
`timescale 10ns/1ns

module time_scale;
    reg time_set;
    parameter p = 1.65;

    initial
        $monitor("%t  time_set=%b      ($time=%0d  $realtime=%0.2f)",
                 $realtime, time_set, $time, $realtime);

    initial begin
        #p time_set = 0;
        #p time_set = 1;
        #1 $stop;
    end
endmodule
```

### 延遲怎麼算
| 步驟 | 計算 | 結果 |
|------|------|------|
| 第 1 個 `#p` | 1.65 × 10 ns = 16.5 ns → 精度 1 ns，四捨五入 | **17 ns** |
| 第 2 個 `#p` | 再 16.5 ns → 17 ns（**每個延遲各自四捨五入**） | 17 + 17 = **34 ns** |
| `#1` | 1 × 10 ns | 44 ns 停止 |

講義第 18 頁的結果：`0 time_set=X`、`17 time_set=0`、`34 time_set=1`（P + P ≈ 17 + 17 = 34 ns）。

### 講義的兩個小錯
| 講義寫 | 應該寫 | 原因 |
|--------|--------|------|
| `'timescale`（單引號） | `` `timescale ``（反引號） | 編譯命令的開頭是反引號（鍵盤左上角） |
| `Initial` | `initial` | Verilog 關鍵字有分大小寫，`Initial` 會被當成模組名稱 |

---

## 3. 三種顯示時間的方法

| 寫法 | 單位 | 小數 | 本範例印出 |
|------|------|------|-----------|
| `%t` | **模擬精度**（這裡 1 ns） | 依精度 | 17、34（單位 ns） |
| `$time` | **這個模組的時間單位**（10 ns） | **四捨五入成整數** | 2、3 |
| `$realtime` | 這個模組的時間單位（10 ns） | 保留小數 | 1.70、3.40 |

- `$time`：17 ns 是 1.7 個時間單位，變成整數後是 **2**；34 ns 是 3.4 個，變成 **3**。只看 `$time` 會以為時間是 2、3，很容易誤會。
- 講義的 17、34 是以 **ns** 表示，和 `%t` 的結果一樣。

> 之前的範例都是 `` `timescale 1ns/... ``，時間單位剛好是 1 ns，所以 `$time` 印出來就是 ns，看不出差別。
> 時間單位不是 1 ns 時，要用 `%t` 或 `$realtime` 才看得到精確的時間。

---

## 4. 預期輸出

```
                   0  time_set=x      ($time=0  $realtime=0.00)
                  17  time_set=0      ($time=2  $realtime=1.70)
                  34  time_set=1      ($time=3  $realtime=3.40)
** Note: $stop    : time_scale_tb.v(23)
   Time: 44 ns  Iteration: 0  Instance: /time_scale
```

### 觀察重點
- `%t` 的欄位寬度是固定的，所以數字前面有很多空白。
- 停止時間是 44 ns：34 ns 再加 `#1`（= 10 ns）。

### 試試看：把精度改細
把第 1 行改成 `` `timescale 10ns/100ps ``，重新 `do run.do`：
```
                   0  time_set=x      ($time=0  $realtime=0.00)
                 165  time_set=0      ($time=2  $realtime=1.65)
                 330  time_set=1      ($time=3  $realtime=3.30)
   Time: 43 ns  Iteration: 0  Instance: /time_scale
```
- 精度 100 ps 夠細，16.5 ns **不用再四捨五入**，兩次 `#p` 剛好是 16.5 ns、33 ns。
- `%t` 現在印 **165、330**：`%t` 的單位是模擬精度，精度變成 100 ps，所以 165 代表 165 × 100 ps = 16.5 ns。
  `%t` 印出的數字要配合精度來讀，不一定是 ns。
- `$time` 還是 2、3（1.65、3.3 四捨五入）；`$realtime` 變成 1.65、3.30。

---

## 5. 使用 `timescale 要注意

1. **每個檔案開頭都要寫**。`` `timescale `` 會一直有效到下一個 `` `timescale `` 出現；
   如果有的檔案寫、有的沒寫，ModelSim 載入模擬時會報錯。例如把 07 範例 `gate_delay1.v` 的第一行刪掉：
   ```
   ** Error (suppressible): (vsim-3009) [TSCALE] - Module 'gate_delay1' does not have a timeunit/timeprecision specification in effect, but other modules do.
   ```
2. 時間精度必須**小於或等於**時間單位：`` `timescale 1ns/10ns `` 是錯的。
3. 單位只能用 1、10、100 搭配 s、ms、us、ns、ps、fs，例如 `10ns` 可以，`5ns` 不行。
4. 一起模擬時，ModelSim 用所有模組中**最小的精度**當作整個模擬的精度。

---

## 6. 重點整理

| 觀念 | 說明 |
|------|------|
| `` `timescale 單位/精度 `` | `#1` 的長度 / 最小的時間刻度 |
| 四捨五入 | 比精度更細的延遲會被四捨五入，每個延遲各自處理 |
| `$time` | 以模組時間單位計，取整數 |
| `$realtime` | 以模組時間單位計，有小數 |
| `%t` | 以模擬精度為單位顯示（精度 1ns 時數字就是 ns） |
