# 08_SISO 範例說明：串進串出移位暫存器（Serial In Serial Out）

## 1. 先認識移位暫存器（講義第 19 頁）

- 移位暫存器的功能：資料格式的轉換、計數器、時序產生器（Clock Generator）…等等。
- **最簡單的移位暫存器是由一群 D 型正反器串接而成**，以一個**共同的時脈**訊號來驅動所有的正反器。
- 除了可以儲存資料以外，也可將儲存的資料**向左或向右移動**，所以一個 n 位元的移位暫存器通常是由 n 個 D 型正反器連接而成。

依資料「怎麼進、怎麼出」分成 4 種：

| 種類 | 進 | 出 | 範例 |
|------|----|----|------|
| SISO | 串列（一次 1 位元） | 串列 | **本範例** |
| SIPO | 串列 | 並列（一次 n 位元） | [09_SIPO](../09_SIPO/SIPO_說明.md) |
| PISO | 並列 | 串列 | [10_PISO](../10_PISO/PISO_說明.md) |
| PIPO | 並列 | 並列 | [11_PIPO](../11_PIPO/PIPO_說明.md) |

---

## 2. 這個範例在做什麼？

**串進串出（SISO）**：用一個串列輸入（SI）埠決定移位期間輸入到**最左端**那個暫存器的值；
串列輸出（SO）埠用來輸出最右邊那個暫存器的值。

```
         Reg4[0]    Reg4[1]    Reg4[2]    Reg4[3]
SI ───►[D    Q]──►[D    Q]──►[D    Q]──►[D    Q]──► SO
         ▲          ▲          ▲          ▲
Clock ───┴──────────┴──────────┴──────────┘
```
每個 Clock 正緣，每一格的資料往右移一格；SI 進入 Reg4[0]，Reg4[3] 的舊值從 SO 送出。

---

## 3. 兩種寫法

### 範例 1：一行一行寫（講義第 20 頁）
```verilog
reg [3:0] Reg4;

always @(posedge Clock) begin
    if (Clear)                  // Clear = 1，清除
        Reg4 <= 4'b0;
    else begin
        SO      <= Reg4[3];
        Reg4[3] <= Reg4[2];
        Reg4[2] <= Reg4[1];
        Reg4[1] <= Reg4[0];
        Reg4[0] <= SI;          // 移入新的資料（SI）至 Reg4[0]
    end
end
```

### 範例 2：for 迴圈（講義第 23 頁）
```verilog
always @(posedge Clock) begin : for_Local   // 定義一個區域名稱 for_Local
    integer i;                              // 定義一個區域性變數
    if (Clear)
        Reg4 <= 4'b0;
    else begin
        SO <= Reg4[3];
        for (i = 3; i >= 1; i = i - 1)      // Reg4[3]=Reg4[2]、Reg4[2]=Reg4[1]、Reg4[1]=Reg4[0]
            Reg4[i] <= Reg4[i-1];
        Reg4[0] <= SI;
    end
end
```
- for 迴圈在編譯時會展開成範例 1 的那 3 行，硬體完全一樣。位元數多的時候（例如 32 位元）就很省事。
- 講義兩個範例的模組名稱都是 `SISO_Shift_Register`，一起編譯會互相覆蓋，第二個改名為 `SISO_Shift_Register_For`。
- 更簡潔的寫法：`Reg4 <= {Reg4[2:0], SI};`（連結運算子，見 [09_SIPO](../09_SIPO/SIPO_說明.md)）。

---

## 4. 講義第 20 頁：「順序更改，結果如何？」

講義用**阻隔式 `=`**。阻隔式是一行做完才做下一行，所以**順序很重要**。
把範例 1 的順序倒過來（先寫 `Reg4[0] = SI`，再一路往右）實際模擬：

```
t=10  Clear=0 SI=1  ->  Reg4=0000 SO=x
t=20  Clear=0 SI=1  ->  Reg4=1111 SO=1     ← 一個時脈內，SI 就一路被複製到全部 4 格，還直接從 SO 出來！
t=30  Clear=0 SI=0  ->  Reg4=1111 SO=1
t=40  Clear=0 SI=1  ->  Reg4=0000 SO=0
```
`Reg4[0] = SI` 做完後，下一行 `Reg4[1] = Reg4[0]` 拿到的是**剛寫進去的新值**，於是一路傳下去，變成 4 格全部一樣，根本不是移位。

講義的寫法剛好由右往左（先寫 `SO = Reg4[3]`），每一行都在被覆蓋之前讀到舊值，所以結果正確。但順序一錯就壞了。

**本範例改用非阻隔式 `<=`**：右邊全部讀「這個時脈開始時的舊值」，最後才一起更新。
所以 5 行**不管怎麼排，結果都一樣**，這就是正反器一律用 `<=` 的原因（week03 [03_Hierar](../../week03/03_Hierar/Hierar_說明.md) 第 5 節）。

---

## 5. 講義第 21、22 頁：「請改寫程式把 Reg4 的值顯示出來」

`Reg4` 是模組內部的 reg，testbench 看不到。有兩種方法：
1. **講義的方法**：把 Reg4 改成輸出埠，`output reg [3:0] Reg4`，testbench 加 `wire [3:0] Reg4;` 並用 `.Reg4(Reg4)` 接出來。
2. **本範例的方法**：模組不改，testbench 用**階層式名稱** `u1.Reg4` 直接讀（只能用在模擬，見 week03 [03_Hierar](../../week03/03_Hierar/Hierar_說明.md)）。

---

## 6. 預期輸出

SI 依序送入 1、1、0、1，之後都送 0；在 Clock 負緣印出。

```
t=0   Clear=1 SI=0  ->  Reg4=xxxx SO=x   |  for: Reg4=xxxx SO=x
t=10  Clear=0 SI=1  ->  Reg4=0000 SO=x   |  for: Reg4=0000 SO=x     ← t=5 清除
t=20  Clear=0 SI=1  ->  Reg4=0001 SO=0   |  for: Reg4=0001 SO=0     ← t=15：第一個 1 進入 Reg4[0]
t=30  Clear=0 SI=0  ->  Reg4=0011 SO=0   |  for: Reg4=0011 SO=0
t=40  Clear=0 SI=1  ->  Reg4=0110 SO=0   |  for: Reg4=0110 SO=0
t=50  Clear=0 SI=0  ->  Reg4=1101 SO=0   |  for: Reg4=1101 SO=0     ← 1101 全部進來了
t=60  Clear=0 SI=0  ->  Reg4=1010 SO=1   |  for: Reg4=1010 SO=1     ← t=55：第一個 1 從 SO 出來
t=70  Clear=0 SI=0  ->  Reg4=0100 SO=1   |  for: Reg4=0100 SO=1
t=80  Clear=0 SI=0  ->  Reg4=1000 SO=0   |  for: Reg4=1000 SO=0
t=90  Clear=0 SI=0  ->  Reg4=0000 SO=1   |  for: Reg4=0000 SO=1
t=100 Clear=0 SI=0  ->  Reg4=0000 SO=0   |  for: Reg4=0000 SO=0
```

### 觀察重點
- 第一個 1 在 t=15 進入，t=55 從 SO 出來，**經過 4 個時脈**（講義第 21 頁的「4 clocks」）。
- SO 依序送出 1、1、0、1，和送進去的順序一樣：先進先出。
- 兩種寫法每一行都一樣。
- t=10 的 SO 還是 x：Clear 只清 Reg4，沒有清 SO。

---

## 7. 重點整理

| 觀念 | 說明 |
|------|------|
| 移位暫存器 | n 個 D 型正反器串接，共用時脈 |
| SISO | 一次進 1 位元、出 1 位元，延遲 n 個時脈 |
| `=` 的順序 | 順序錯了資料會一次傳到底 |
| `<=` | 順序無關，正反器一律使用 |
| for 迴圈 | 編譯時展開，硬體一樣 |
| 看內部訊號 | 改成輸出埠，或用階層式名稱 |
