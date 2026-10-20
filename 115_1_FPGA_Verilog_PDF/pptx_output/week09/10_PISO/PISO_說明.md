# 10_PISO 範例說明：並進串出移位暫存器（Parallel In Serial Out）

## 1. 這個範例在做什麼？

**並進串出（PISO）**移位暫存器（講義第 29 頁）：當時脈（Clock）訊號及載入（Load）訊號皆動作時，
會將**並列輸入**（Parallel Input，PI）埠上的資料傳送到移位暫存器的 n 個暫存器之中；
串列輸出（SO）埠用來輸出：當時脈訊號動作且載入訊號不動作（0）的情況下，送出最右邊那個暫存器的值。

```
 Data_In[3]  Data_In[2]  Data_In[1]  Data_In[0]
     │           │           │           │
     ▼           ▼           ▼           ▼
  [Reg4[0]]──►[Reg4[1]]──►[Reg4[2]]──►[Reg4[3]]──► SO
                         （講義圖上 Reg4[0] 在最左邊）
```

| Clock 正緣時 | 動作 |
|-------------|------|
| Load = 1 | 4 個位元一次載入：Reg4 = Data_In |
| Load = 0 | SO = Reg4[3]，Reg4 左移一格，Reg4[0] 填 0 |

和 [09_SIPO](../09_SIPO/SIPO_說明.md) 相反：PISO 把**並列轉成串列**，例如 CPU 要把一個位元組一個位元一個位元送出去。

---

## 2. 程式說明

### PISO_Shift_Register.v（講義第 30、31 頁）
```verilog
always @(posedge Clock) begin : for_Local   // 定義一個區域名稱 for_Local
    integer i;                              // 定義一個區域性變數
    if (Clear)                              // 清除
        Reg4 <= 4'b0;
    else begin
        if (Load)
            Reg4 <= Data_In;                // 從 Data_In[3:0] 載入資料
        else begin
            SO <= Reg4[3];
            for (i = 3; i >= 1; i = i - 1)  // Reg4[3]=Reg4[2]、Reg4[2]=Reg4[1]、Reg4[1]=Reg4[0]
                Reg4[i] <= Reg4[i-1];
            Reg4[0] <= 1'b0;                // Reg4[0] 填入 0
        end
    end
end
```
- 優先權：Clear > Load > 移位。
- 移位部分和 [08_SISO](../08_SISO/SISO_說明.md) 的 for 迴圈寫法一樣，只是 Reg4[0] 補 **0**，不是補 SI。
- SO 送的是 **Reg4[3]**，所以 Data_In 的**最高位元先出去**（MSB first）。

---

## 3. 預期輸出

Data_In = 1101（講義第 32 頁）：t=15 的正緣載入，之後每個正緣送出一個位元。

```
t=0   Clear=1 Load=0 Data_In=1101  ->  Reg4=xxxx  SO=x
t=10  Clear=0 Load=1 Data_In=1101  ->  Reg4=0000  SO=x     ← t=5 清除
t=20  Clear=0 Load=0 Data_In=1101  ->  Reg4=1101  SO=x     ← t=15 載入 1101
t=30  Clear=0 Load=0 Data_In=1101  ->  Reg4=1010  SO=1     ← 送出 Reg4[3] = 1，左移、補 0
t=40  Clear=0 Load=0 Data_In=1101  ->  Reg4=0100  SO=1
t=50  Clear=0 Load=0 Data_In=1101  ->  Reg4=1000  SO=0
t=60  Clear=0 Load=0 Data_In=1101  ->  Reg4=0000  SO=1
t=70  Clear=0 Load=0 Data_In=1101  ->  Reg4=0000  SO=0     ← 送完了，之後都是 0
```

### 觀察重點
- SO 依序是 **1、1、0、1**，就是 1101 從最高位開始，和講義第 32 頁的箭頭一樣。
- 送 4 個位元需要 4 個時脈；送完後 Reg4 補進來的都是 0，所以 SO 之後一直是 0。
- Load 和移位共用同一個時脈：載入那一個時脈不會移位。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| PISO | 並列進、串列出：並列轉序列 |
| Load | 1：一次載入 4 位元；0：移位送出 |
| MSB first | SO 先送 Reg4[3] |
| 補 0 | 移位時空出來的位置填 0 |
