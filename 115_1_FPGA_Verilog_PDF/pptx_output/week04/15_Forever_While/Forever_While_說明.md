# 15_Forever_While 範例說明：while 與 forever 迴圈

## 1. 這個範例在做什麼？

講義第 46 頁：產生**週期 40 個時間單位**的時脈，並在**第 500 個時間單位停止**。
另外補一個 `while` 的簡單例子。這兩種迴圈主要用在**測試平台**，不用在要合成的電路裡。

### 語法
```verilog
while (條件) begin        forever begin
    敘述;                     敘述;
end                       end
```
- `while`：條件成立就重複。
- `forever`：永遠重複，一定要在裡面放延遲（`#`）或事件（`@`），否則模擬會卡死。

---

## 2. 檔案說明

### Forever_While_tb.v
```verilog
parameter duty_cycle = 20;
parameter end_time   = 500;

initial begin : clock_seqence
    clock = 0;
    forever
        #duty_cycle clock = ~clock;     // 每 20 反相一次 → 週期 40
end

initial
    #end_time disable clock_seqence;    // t=500 停止
```
- `disable 區塊名稱`：強制結束一個具名區塊，`forever` 也就停了。所以區塊一定要取名字。
- `clock_seqence` 是講義原本的拼字（sequence 少一個 u），名稱只要前後一致即可。
- 另外用 `always @(posedge clock)` 數正緣個數，並在 t=550 確認 clock 已經不再變化。

### while 範例
```verilog
count = 3;
while (count > 0) begin
    $display(...);
    count = count - 1;
end
```

---

## 3. 預期輸出

```
t=0  while loop: count = 3
t=0  while loop: count = 2
t=0  while loop: count = 1
t=0  while loop done, count = 0
t=20  posedge #1
t=60  posedge #2
...
t=460  posedge #12
t=550  clock = 0 (stopped at t=500)
```

### 觀察重點
- while 的三圈都在 **t=0** 完成：迴圈本身不花模擬時間，只有 `#` 延遲才會讓時間前進。
- clock 在 20 變 1、40 變 0 … 正緣在 20, 60, 100 …, 460，共 12 個；
  下一個反相本來在 t=500，但同一時間被 `disable` 停掉了，之後 clock 一直維持 0。
- 在 Wave 視窗可以看到 clock 在 t=480 之後就是一條平線。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `while (條件)` | 條件成立就重複 |
| `forever` | 無限重複，內部必須有延遲 |
| `disable 名稱` | 結束具名區塊 |
| `parameter` | 把週期、結束時間寫成常數，方便修改 |
| 迴圈不花時間 | 模擬時間只由 `#` 與事件推進 |
