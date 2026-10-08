# 04_Sort4 範例說明：task（任務）基本用法 — 4 筆資料排序

## 1. 這個範例在做什麼？

把 4 筆 4 位元資料 a、b、c、d **由小到大**排序，輸出 ra ≤ rb ≤ rc ≤ rd（講義第 15~17 頁）。

「比較兩筆，前面比較大就交換」這個動作寫成**任務** `Sort_2_Data`，呼叫 5 次就能排好：

```
(va,vb,vc,vd) = (3,1,4,2)
Sort_2_Data(va,vc) → (3,1,4,2)    3、4 不用換
Sort_2_Data(vb,vd) → (3,1,4,2)    1、2 不用換
Sort_2_Data(va,vb) → (1,3,4,2)    3、1 交換    → va 是最小值
Sort_2_Data(vc,vd) → (1,3,2,4)    4、2 交換    → vd 是最大值
Sort_2_Data(vb,vc) → (1,2,3,4)    3、2 交換    → 中間兩個排好
```

---

## 2. function 與 task 的差別（講義第 14 頁）

| | function（函數） | task（任務） |
|---|---|---|
| 引數 | 至少 1 個 input，**只能有 input** | 0 個以上，可以有 input / **output / inout** |
| 結果怎麼傳回 | 回傳值（1 個） | 透過 output / inout 引數（可以多個） |
| 呼叫方式 | 用在運算式裡：`y = f(a);` | 自己是一行敘述：`t(a, y);` |
| 可以呼叫 | 其他 function | 其他 task 和 function |
| 延遲 `#`、`@` | 不行 | 可以（但那樣就不能合成） |

共同點：都只能在 `always` / `initial` 這類行為描述中使用，都可以有自己的區域變數（`reg`、`integer`），但**不能有 wire**。

為什麼排序要用 task？因為「交換」要同時改兩個變數，function 只能回傳一個值。

---

## 3. 檔案說明

### Sort_4_Data.v
```verilog
always @(*) begin : Label_Name
    reg [size:0] va, vb, vc, vd;          // 區域變數
    {va, vb, vc, vd} = {a, b, c, d};
    Sort_2_Data(va, vc);
    Sort_2_Data(vb, vd);
    Sort_2_Data(va, vb);
    Sort_2_Data(vc, vd);
    Sort_2_Data(vb, vc);
    {ra, rb, rc, rd} = {va, vb, vc, vd};
end

task Sort_2_Data (
    inout [size:0] x,
    inout [size:0] y
);
    reg [size:0] temp;
    begin
        if (x > y) begin
            temp = x;  x = y;  y = temp;
        end
    end
endtask
```
- **`begin : Label_Name`**：區塊要有名字才能在裡面宣告區域變數 `va`~`vd`。
  沒有名字就宣告，編譯器會報 `Expecting statement` 之類的錯誤（講義第 15 頁的註解）。
- **`inout`**：呼叫時把 `va`、`vc` 的值**複製進** `x`、`y`；任務結束時再把 `x`、`y` **複製回** `va`、`vc`。
- `parameter size = 4 - 1`：代表最高位元的編號，所以寬度寫 `[size:0]`（不是 `[size-1:0]`）。
- 左邊的連結運算子 `{ra, rb, rc, rd} = ...`：一次指定給 4 個變數。

### 講義第 17 頁的練習：改成由大到小
把任務裡的 `if (x > y)` 改成 `if (x < y)` 即可。

### Sort_4_Data_tb.v
先顯示 4 筆例子，再把 65536 種輸入全部檢查（輸出有沒有由小到大、總和有沒有變）。

---

## 4. 預期輸出

```
(a,b,c,d) = (4,3,2,1)   ->  (ra,rb,rc,rd) = (1,2,3,4)
(a,b,c,d) = (3,1,4,2)   ->  (ra,rb,rc,rd) = (1,2,3,4)
(a,b,c,d) = (15,0,9,9)  ->  (ra,rb,rc,rd) = (0,9,9,15)
(a,b,c,d) = (1,2,3,4)   ->  (ra,rb,rc,rd) = (1,2,3,4)
check all 65536 inputs: errors = 0
```

### 觀察重點
- 前兩筆是講義第 17 頁波形的輸入（0100,0011,0010,0001 與 3,1,4,2）。
- 有重複的值（9, 9）也能正確排序。
- 5 次「比較交換」就足以排好任意 4 筆資料，65536 種組合全部正確。

---

## 5. 重點整理

| 觀念 | 說明 |
|------|------|
| `task` … `endtask` | 可以有多個輸出的副程式 |
| `inout` 引數 | 進去時複製進來，結束時複製回去 |
| 具名區塊 | `begin : 名稱` 才能宣告區域變數 |
| 交換（Swap） | 需要一個暫存變數 temp |
| 排序網路 | 固定次數的比較交換，適合做成硬體 |
