# 12_Mux2to1 範例說明：2 對 1 多工器（條件運算子）

## 1. 這個範例在做什麼？

設計 **2 對 1 多工器（Multiplexer）**：由 `Select` 決定輸出哪一個輸入。

- `Select = 1` → `Out = a`
- `Select = 0` → `Out = b`

多工器就像一個**切換開關**，是數位電路最常用的元件之一
（03_Hierar 的 Mux、05_DFF_Sel 的 mux2_1 都是它）。

```
   a ──►┌─────┐
        │ MUX │──► Out
   b ──►│     │
        └──▲──┘
           │
        Select
```

---

## 2. 檔案說明

### Mux2to1.v
```verilog
assign Out = Select ? a : b;
```

**條件運算子**語法：
```
條件 ? 成立時的值 : 不成立時的值
```
和 C 語言的三元運算子一樣。它直接對應到一個多工器。

用邏輯閘表示等同於：
```
Out = (Select & a) | (~Select & b)
```

#### 其他寫法
```verilog
// 行為層次：if-else
always @(*)
    if (Select) Out = a;
    else        Out = b;
```
（這種寫法 `Out` 要宣告成 `reg`。）

#### 巢狀條件運算子（4 選 1）
```verilog
assign Out = s[1] ? (s[0] ? d3 : d2)
                  : (s[0] ? d1 : d0);
```

### Mux2to1_tb.v
```verilog
for (i = 0; i < 8; i = i + 1) begin
    {Select, a, b} = i; #10;
end
```
用連結運算子一次跑遍 3 個輸入的 8 種組合。

---

## 3. 預期輸出

```
t=0   Select=0 a=0 b=0  ->  Out=0
t=10  Select=0 a=0 b=1  ->  Out=1   ← Select=0，Out 跟著 b
t=20  Select=0 a=1 b=0  ->  Out=0
t=30  Select=0 a=1 b=1  ->  Out=1
t=40  Select=1 a=0 b=0  ->  Out=0
t=50  Select=1 a=0 b=1  ->  Out=0   ← Select=1，Out 跟著 a
t=60  Select=1 a=1 b=0  ->  Out=1
t=70  Select=1 a=1 b=1  ->  Out=1
```

### 觀察重點
- 前 4 行（Select=0）：`Out` 永遠等於 `b`，`a` 怎麼變都沒影響。
- 後 4 行（Select=1）：`Out` 永遠等於 `a`。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| 條件運算子 `? :` | 二選一，合成為多工器 |
| 多工器 | 由選擇線決定哪個輸入通過 |
| 等效寫法 | `assign ? :`、`always` + `if-else`、邏輯閘 |
| 巢狀 `? :` | 可做更多選一 |
