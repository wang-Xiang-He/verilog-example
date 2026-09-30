# 05_Scalable 範例說明：parameter 參數化設計

## 1. 這個範例在做什麼？

設計一個 `c = a & b` 的電路，位元寬度用 `parameter width` 表示。
講義第 17 頁的重點：要把 16 位元改成 45 位元，**只要改一個數字**，不用改三個地方的 `[15:0]`。

---

## 2. 檔案說明

### ScalableDesign.v
```verilog
module ScalableDesign #(
    parameter width = 16
) (
    input  [width-1:0] a,
    input  [width-1:0] b,
    output [width-1:0] c
);
    assign c = a & b;
endmodule
```
- 講義寫法：`module ScalableDesign(a, b, c); parameter width = 16; input [width-1:0] a, b; ...`
- Verilog-2001 把參數寫在 `#( )` 裡，後面的埠宣告才能用到 `width`。
- 講義多寫了一行 `wire [width-1:0] c;`，輸出沒寫型態時預設就是 wire，可以省略。

### ScalableDesign_tb.v
```verilog
ScalableDesign              u16 (...);   // 用預設值 width = 16
ScalableDesign #(.width(4)) u4  (...);   // 實例化時覆寫成 4
```
同一個模組做出兩個不同寬度的電路。`u16.width` 是**階層式名稱**，可以從 testbench 讀到子模組的參數。

---

## 3. 預期輸出

```
t=0   16-bit: ffff & 1234 = 1234   |   4-bit: 1111 & 1010 = 1010
t=10  16-bit: f0f0 & abcd = a0c0   |   4-bit: 1100 & 0110 = 0100
u16.width = 16,  u4.width = 4
```

### 觀察重點
- 任何數 AND `ffff` 都等於自己（1 是 AND 的單位元素）。
- `f0f0 & abcd`：`f` 的位置保留、`0` 的位置清掉 → `a0c0`（遮罩 mask 的用法）。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `parameter` | 模組內常數，編譯時決定 |
| `#(parameter width = 16)` | Verilog-2001 參數宣告位置 |
| `#(.width(4))` | 實例化時依名稱覆寫參數 |
| 可擴充設計（Scalable） | 寬度改一處即可，模組可重複使用 |
