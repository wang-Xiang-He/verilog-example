# 02_Define 範例說明：`define 定義常數（紅綠燈控制器）

## 1. 這個範例在做什麼？

`` `define `` 的功能（講義第 5 頁）：**類似 parameter 敘述**，可以用來表示**有限狀態機器的內部狀態**以及**電路中會用到的常數值**。

講義用紅綠燈當例子，但只給了片段（中間寫「略」）。這裡依照片段**補成可以模擬的完整電路**：

```
        紅燈 9 個時脈            綠燈 6 個時脈          黃燈 1 個時脈
   ┌──────────────────┐     ┌──────────────┐     ┌─────────┐
──►│  RED_Light (00)  │────►│ GREEN_Light  │────►│ YELLOW  │───┐
   └──────────────────┘     │    (01)      │     │ (10)    │   │
            ▲               └──────────────┘     └─────────┘   │
            └──────────────────────────────────────────────────┘
```

| 用途 | 寫法 | 講義第幾頁 |
|------|------|-----------|
| 燈亮的**時間**（常數） | `` `define RED_Light_Time 9 `` | 5、16 |
| FSM 的**狀態編碼** | `parameter RED_Light = 2'b00, ...` | 5、16 |

---

## 2. `define 的用法

### 定義
```verilog
`define RED_Light_Time      9   // 紅燈亮的時間倍值
`define GREEN_Light_Time    6   // 綠燈亮的時間倍值
`define YELLOW_Light_Time   1   // 黃燈亮的時間倍值
```

### 使用：名字前面也要加反引號
```verilog
if (Count_In == `RED_Light_Time)     // 編譯前會被換成  if (Count_In == 9)
```

`` `define `` 是**純文字取代**（巨集，macro）：編譯前把 `` `RED_Light_Time `` 換成 `9`，再開始編譯。
講義第 5 頁的箭頭「即 RED_Light_Time = 9」就是這個意思。

### 行尾不要加分號
`` `define `` 不是 Verilog 敘述，**後面不加 `;`**。如果寫成：
```verilog
`define RED_Light_Time 9;
```
取代後變成 `if (Count_In == 9;)`，ModelSim 會報錯：
```
** Error: (vlog-13069) ** while parsing macro expansion: 'RED_Light_Time' starting at Traffic_Light.v(42)
** at Traffic_Light.v(42): near ";": syntax error, unexpected ';'.
```
錯誤訊息指向**使用**巨集的那一行（42 行），而不是定義它的地方，要往回找 `` `define ``。

---

## 3. `define 和 parameter 的差別

兩者都能當常數用，但性質不同：

| | `` `define `` | `parameter` |
|---|---|---|
| 本質 | 文字取代（編譯前處理） | 模組裡的常數 |
| 有效範圍 | **全域**：定義之後，**後面所有檔案**都能用 | **只在這個模組裡** |
| 使用時 | 要加反引號 `` `RED_Light_Time `` | 直接寫名字 `RED_Light` |
| 能不能從外面改 | 不能（只能改定義那一行） | 能，用 `#( )` 或 `defparam`（見 03~05） |
| 適合 | 整個專案共用的設定值 | 模組自己的寬度、狀態編碼 |

### 「全域」的實際效果
本範例的 testbench 沒有定義任何巨集，卻能直接用 `` `RED_Light_Time ``：
```verilog
$display("RED_Light_Time=%0d ...", `RED_Light_Time, ...);
```
因為 `run.do` 是用**同一個 vlog 指令**依序編譯 `Traffic_Light.v`、`Traffic_Light_tb.v`，
前一個檔案定義的巨集，後面的檔案也看得到。

所以 **vlog 的檔案順序很重要**：`Traffic_Light.v` 要排在前面。反過來寫成 `vlog Traffic_Light_tb.v Traffic_Light.v`，
tb 編譯時巨集還沒定義，就會報錯：
```
** Error: Traffic_Light_tb.v(19): (vlog-2163) Macro `RED_Light_Time is undefined.
```

> 全域也有缺點：兩個檔案都 `` `define `` 了同一個名字，後面的會蓋掉前面的。
> 模組自己用的常數，建議用 `parameter`（或 `localparam`）。

---

## 4. 檔案說明

### Traffic_Light.v（重點節錄）
```verilog
parameter RED_Light    = 2'b00,     // FSM 的內部狀態編碼
          GREEN_Light  = 2'b01,
          YELLOW_Light = 2'b10;

reg [1:0] state;
reg [3:0] Count_In;                 // 目前這個燈已經亮了幾個時脈

always @(posedge Clock) begin
    if (Reset) begin                // 電路重置：紅燈亮、重新計數
        state    <= RED_Light;
        RED      <= 1'b1;  GREEN <= 1'b0;  YELLOW <= 1'b0;
        Count_In <= 1;
    end
    else begin
        case (state)
            RED_Light:
                if (Count_In == `RED_Light_Time) begin   // 紅燈維持 9 個時脈
                    state    <= GREEN_Light;
                    RED      <= 1'b0;
                    GREEN    <= 1'b1;
                    Count_In <= 1;                       // 重新計數
                end
                else
                    Count_In <= Count_In + 1;
            ...
        endcase
    end
end
```

- `Count_In` 從 1 開始數，數到 `` `RED_Light_Time ``（9）時換到綠燈，並且重新從 1 開始數。
- 講義用阻隔式 `=`，這裡是時脈觸發的 `always`，改用非阻隔式 `<=`（原因見 week03 [03_Hierar](../../week03/03_Hierar/Hierar_說明.md) 第 5 節）。
- 補上 `default`：`state` 是 2 位元，`2'b11` 不是合法狀態，萬一跑進去就回到紅燈。

### Traffic_Light_tb.v
- 時脈週期 10 ns，`Reset` 在 12 ns 放開。
- `$monitor` 只監視燈號和 `state`（`Count_In` 每個時脈都變，放進來會印太多行）。
- 跑 32 個時脈 = 兩輪完整的紅 → 綠 → 黃。

---

## 5. 預期輸出

```
RED_Light_Time=9  GREEN_Light_Time=6  YELLOW_Light_Time=1
t=0    Reset=1  state=xx  RED=x GREEN=x YELLOW=x   ← 還沒遇到正緣
t=5    Reset=1  state=00  RED=1 GREEN=0 YELLOW=0   ← 重置：紅燈
t=12   Reset=0  state=00  RED=1 GREEN=0 YELLOW=0
t=95   Reset=0  state=01  RED=0 GREEN=1 YELLOW=0   ← 紅燈 5~95：9 個時脈
t=155  Reset=0  state=10  RED=0 GREEN=0 YELLOW=1   ← 綠燈 95~155：6 個時脈
t=165  Reset=0  state=00  RED=1 GREEN=0 YELLOW=0   ← 黃燈 155~165：1 個時脈
t=255  Reset=0  state=01  RED=0 GREEN=1 YELLOW=0   ← 第二輪
t=315  Reset=0  state=10  RED=0 GREEN=0 YELLOW=1
t=325  Reset=0  state=00  RED=1 GREEN=0 YELLOW=0
```

### 觀察重點
- 每個燈亮的長度剛好等於 `` `define `` 的值乘以時脈週期：9 × 10 = 90 ns、6 × 10 = 60 ns、1 × 10 = 10 ns。
- **試試看**：把 `` `define RED_Light_Time 9 `` 改成 `3`，重新 `do run.do`，紅燈就變成只亮 30 ns。
  只要改一個地方，所有用到 `` `RED_Light_Time `` 的地方都會跟著變，這就是用 `` `define `` 的好處。
- 為什麼第 1 輪紅燈是 5~95，第 2 輪是 165~255？兩段都是 90 ns，只是第 1 輪從重置那一刻開始算。

---

## 6. 重點整理

| 觀念 | 說明 |
|------|------|
| `` `define 名稱 內容 `` | 文字取代，使用時寫 `` `名稱 `` |
| 不加分號 | 分號會一起被取代進去，造成語法錯誤 |
| 全域有效 | 同一次 vlog 編譯中，後面的檔案都看得到，檔案順序要注意 |
| `parameter` | 模組內的常數，可以從外面覆寫 |
| 有限狀態機 | 狀態用 `parameter` 編碼，`case (state)` 決定下一個狀態 |
