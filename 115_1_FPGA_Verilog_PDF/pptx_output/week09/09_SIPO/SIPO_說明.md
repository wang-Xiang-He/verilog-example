# 09_SIPO 範例說明：串進並出移位暫存器（Serial In Parallel Out）

## 1. 這個範例在做什麼？

**串進並出（SIPO）**移位暫存器（講義第 25 頁）：用一個串列輸入（SI）埠決定移位期間輸入到最左端暫存器的值；
**並列輸出**（Parallel Output，PO）埠用來輸出在這次時脈動作之後，儲存在 n 個位元移位暫存器內的值。

```
                    Data_Out[0] Data_Out[1] Data_Out[2] Data_Out[3]
                         ▲          ▲          ▲          ▲
SI ───►[D    Q]──────────┴─►[D    Q]┴─────►[D    Q]┴─────►[D    Q]
         ▲                   ▲              ▲              ▲
Clock ───┴───────────────────┴──────────────┴──────────────┘
```

和 [08_SISO](../08_SISO/SISO_說明.md) 一樣是一位元一位元地移進來，差別是**每一格都接出來**，4 個位元可以一次讀走。
用途：把序列傳進來的資料（例如 UART、SPI 一次收 1 位元）**轉成並列**的 4 / 8 位元資料。

---

## 2. 兩種寫法

### SIPO_Shift_Register（講義第 25 頁）
```verilog
always @(posedge Clock) begin
    if (Clear)                              // 清除
        Data_Out <= 4'b0;                   // 清為 0
    else
        Data_Out <= {Data_Out[2:0], SI};    // 左移 1 位元，並移入新的資料（SI）至 Data_Out[0]
end
```

講義寫成兩行：
```verilog
Data_Out = Data_Out << 1;   // 左移 1 位元
Data_Out[0] = SI;           // 移入新的資料（SI）至 Data_Out[0]
```
阻隔式 `=` 時第 2 行接在第 1 行後面執行，結果正確。改成 `<=` 時用連結運算子寫成一行最清楚：
`{Data_Out[2:0], SI}` = 把低 3 位元往左挪一格，SI 補在最右邊，就是「左移再補 SI」。

### SIPO_Shift_Register_1：加入 temp（講義第 27、28 頁，附錄）
講義第 26 頁：「**先左移再串入後並出 → 請改寫為『先並出再串進』**」。
```verilog
reg [3:0] temp;

always @(posedge Clock) begin
    if (Clear) begin
        temp     <= 4'b0;
        Data_Out <= 4'b0;
    end
    else begin
        Data_Out <= temp;                   // 先並出（temp 的舊值）
        temp     <= {temp[2:0], SI};        // 再左移、串入 SI
    end
end
```
- 移位的工作改由內部的 `temp` 做，`Data_Out` 只負責「並出」temp 的舊值。
- 結果：`Data_Out` 會**晚一個時脈**，因為它拿的是 temp 移位之前的值。
- 講義第 27 頁把 `temp = 4'b0; //initial;` 寫在 always 的開頭；如果真的每個時脈都先清 0，就無法移位了，所以這裡把它放在 Clear 的分支裡。

---

## 3. 預期輸出

SI 依序送 1、0、1、0、1、1、1（講義第 26 頁的波形）。在 Clock 負緣印出：

```
t=0   Clear=1 SI=0  ->  Data_Out=xxxx   |  _1 (temp): Data_Out=xxxx  temp=xxxx
t=10  Clear=0 SI=1  ->  Data_Out=0000   |  _1 (temp): Data_Out=0000  temp=0000
t=20  Clear=0 SI=0  ->  Data_Out=0001   |  _1 (temp): Data_Out=0000  temp=0001
t=30  Clear=0 SI=1  ->  Data_Out=0010   |  _1 (temp): Data_Out=0001  temp=0010
t=40  Clear=0 SI=0  ->  Data_Out=0101   |  _1 (temp): Data_Out=0010  temp=0101
t=50  Clear=0 SI=1  ->  Data_Out=1010   |  _1 (temp): Data_Out=0101  temp=1010
t=60  Clear=0 SI=1  ->  Data_Out=0101   |  _1 (temp): Data_Out=1010  temp=0101
t=70  Clear=0 SI=1  ->  Data_Out=1011   |  _1 (temp): Data_Out=0101  temp=1011
t=80  Clear=0 SI=1  ->  Data_Out=0111   |  _1 (temp): Data_Out=1011  temp=0111
```

### 觀察重點
- `Data_Out` 依序 0001、0010、0101、1010、0101、1011、0111，和講義第 26 頁波形完全相同。
- 每一次都是「整個左移一格、最右邊補上新的 SI」：0101 → 1010（補 0）→ 0101（補 1，最左邊的 1 被擠掉）。
- `_1` 版本的 Data_Out 和 `temp` 完全一樣，只是**晚一格**（講義第 28 頁下面那張波形）。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| SIPO | 串列進、並列出：序列轉並列 |
| 左移補 SI | `{Data_Out[2:0], SI}` |
| `<=` 的兩行寫法 | 用連結運算子合成一行最清楚 |
| 先並出再串進 | 輸出晚一個時脈 |
