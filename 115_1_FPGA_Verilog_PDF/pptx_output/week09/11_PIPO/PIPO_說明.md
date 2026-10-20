# 11_PIPO 範例說明：並進並出暫存器（Parallel In Parallel Out）與講義的修改版

## 1. 這個範例在做什麼？

**並進並出（PIPO）**暫存器（講義第 33 頁）：當時脈訊號及載入（Load = 1）訊號皆動作時，
會將並列輸入埠上的資料傳送到 n 個暫存器之中，同時將儲存在暫存器內的值輸出。
講義自己註明：「（意義不大，可修正）」。

```
 Data_In[3:0] ──► [4 個 D 型正反器] ──► Data_Out[3:0]
                     ▲        ▲
                   Clock     Load
```
其實就是一個**有載入致能的 4 位元暫存器**，和 week09 的 [07_Reg4_Async_Sync](../07_Reg4_Async_Sync/Reg4_說明.md) 差不多。

講義接著給了兩個修改版（第 36~39 頁），本範例三個都放進同一個 testbench 比較：

| 模組 | 講義 | 寫法 |
|------|------|------|
| `PIPO_Shift_Register` | 第 34 頁（原版） | `Data_Out <= Data_In;` |
| `PIPO_Shift_Register_new01` | 第 36 頁 | 加 `reg temp`：`Data_Out <= temp; temp <= Data_In;` |
| `PIPO_Shift_Register_new02` | 第 38 頁 | `wire temp = Data_In;`，`Data_Out <= temp;` |

---

## 2. 程式說明

### 原版（講義第 34 頁）
```verilog
always @(posedge Clock) begin
    if (Clear)                      // 清除
        Data_Out <= 4'b0;
    else if (Load)
        Data_Out <= Data_In;        // 從 Data_In 載入資料
end
```

### new01：reg temp（講義第 36 頁）
```verilog
reg [3:0] temp;
...
else if (Load) begin
    Data_Out <= temp;               // 輸出上一次存的資料
    temp     <= Data_In;
end
```
多了一級暫存器，Data_Out 會**晚一個時脈**。

### new02：wire temp（講義第 38 頁）
```verilog
wire [3:0] temp;
assign temp = Data_In;              // (1)
...
else if (Load)
    Data_Out <= temp;               // (2)
```
講義第 38 頁標示 **Wire [3:0] → Reg [3:0]**：`wire` 只是一條線，沒有記憶。`Data_Out <= temp` 等於 `Data_Out <= Data_In`，**和原版完全一樣**。

---

## 3. 講義第 34 頁：「有誤？請修正（加入 temp）」

原版其實是**標準的 PIPO 暫存器**，模擬結果也正確（見下面的輸出）。講義第 35 頁的「建議修正」真正想改的是**什麼時候輸出**：
1. 並列輸出：當時脈訊號為**負緣觸發**時，將儲存在 n 個位元移位暫存器內的值輸出。
2. 並列輸出：當時脈訊號不動作且**載入訊號不動作（Load = 0）**的情況下，才將暫存器內的值輸出。

也就是把「存」和「輸出」分成兩個動作。new01 用 temp 存、Data_Out 輸出，是往這個方向的嘗試，但兩個動作還是在同一個正緣、同一個 `if (Load)` 裡，所以只是單純地晚了一個時脈。

講義第 36 頁說 new01「**第一筆資料不見了，請修正程式**」。從下面的模擬可以看出原因：
- 第一次載入時，`Data_Out <= temp` 拿到的是 temp 的**初值**。temp 沒有被 Clear 清除，一開始是 **x**（講義第 37 頁紅色那段）。
- `Load = 0` 之後就不再執行 `Data_Out <= temp`，**最後一筆 0010 留在 temp 裡出不來**。

一種修正方法：Clear 時也清除 temp，並讓輸出不受 Load 限制：
```verilog
if (Clear) begin
    temp <= 4'b0;  Data_Out <= 4'b0;
end
else begin
    if (Load) temp <= Data_In;      // Load = 1：存
    Data_Out <= temp;               // 每個時脈都輸出 temp → 只晚一個時脈，最後一筆也會出來
end
```

---

## 4. 預期輸出

Data_In 依序 1101、1111、1001、0111、0010（講義第 35、37、39 頁），之後 Load = 0。在 Clock 負緣印出：

```
t=0   Clear=1 Load=0 Data_In=0000  ->  original=xxxx   new01=xxxx (temp=xxxx)   new02=xxxx
t=10  Clear=0 Load=1 Data_In=1101  ->  original=0000   new01=0000 (temp=xxxx)   new02=0000
t=20  Clear=0 Load=1 Data_In=1111  ->  original=1101   new01=xxxx (temp=1101)   new02=1101   ← new01 拿到 x
t=30  Clear=0 Load=1 Data_In=1001  ->  original=1111   new01=1101 (temp=1111)   new02=1111
t=40  Clear=0 Load=1 Data_In=0111  ->  original=1001   new01=1111 (temp=1001)   new02=1001
t=50  Clear=0 Load=1 Data_In=0010  ->  original=0111   new01=1001 (temp=0111)   new02=0111
t=60  Clear=0 Load=0 Data_In=0010  ->  original=0010   new01=0111 (temp=0010)   new02=0010
t=70  Clear=0 Load=0 Data_In=0010  ->  original=0010   new01=0111 (temp=0010)   new02=0010   ← 0010 出不來
```

### 觀察重點
- **original 和 new02 每一行都一樣**，證明 wire temp 沒有任何作用（講義第 39 頁的波形也和原版一樣）。
- **new01 晚一個時脈**，第一筆變成 x，最後一筆 0010 卡在 temp 裡。
- 講義第 35 頁的波形少了第一筆 1101，是因為講義的 testbench 在 Load 變成 1 之前就換了資料；本範例的 Load 和 1101 同時開始，所以原版有拿到 1101。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| PIPO | 並列進、並列出，就是有載入致能的暫存器 |
| reg temp | 多一級暫存器 → 晚一個時脈 |
| wire temp | 只是一條線 → 沒有任何延遲 |
| 沒清除的暫存器 | 初值是 x |
| 輸出放在 if (Load) 裡 | Load = 0 後就不更新 |
