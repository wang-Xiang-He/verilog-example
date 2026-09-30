# 04_BiDir 範例說明：雙向接腳 inout 與三態緩衝器

## 1. 這個範例在做什麼？

FPGA 的一根接腳有時要**輸出**、有時要**輸入**（例如資料匯流排）。做法是用**三態緩衝器**：

- `enable_in_out = 1` → 把 `data` 送到接腳（輸出模式）
- `enable_in_out = 0` → 輸出 **z（高阻抗）**，等於把接腳「放開」，讓外部來驅動（輸入模式）
- `data_in` 隨時讀取接腳上的值

```
                 enable_in_out
                      │
   data ─────────►|>──┴──┬──── tri_inout（接腳，inout）
                         │
   data_in ◄─────────────┘
```

---

## 2. 檔案說明

### BiDir.v
```verilog
module BiDir (
    input  data,
    input  enable_in_out,
    output data_in,
    inout  tri_inout
);
    assign tri_inout = enable_in_out ? data : 1'bz;
    assign data_in   = tri_inout;
endmodule
```
- `inout` 埠只能用 `assign` 驅動（wire 類），**不能宣告成 reg**。
- `1'bz`：高阻抗，代表「我不驅動這條線」。
- 講義第 15 頁的式子 `enable_in_out ? ((data_in) ? data : tri_inout) : 1'bz` 是 SpDE 軟體**合成後**的等效電路，
  輸出又接回自己，不適合初學閱讀；本範例用標準寫法，功能相同。

### BiDir_tb.v
- testbench 扮演**外部裝置**，也用 `assign pin = ext_en ? ext_data : 1'bz;` 驅動同一條線。
- 接到 `inout` 的訊號在 testbench 裡也必須是 **wire**。

---

## 3. 預期輸出

```
t=0   en=1 data=0 | ext_en=0 ext_data=0  ->  pin=0 data_in=0   ← 本模組輸出
t=10  en=1 data=1 | ext_en=0 ext_data=0  ->  pin=1 data_in=1
t=20  en=0 data=1 | ext_en=0 ext_data=0  ->  pin=z data_in=z   ← 都不輸出
t=30  en=0 data=1 | ext_en=1 ext_data=0  ->  pin=0 data_in=0   ← 外部輸出，本模組讀入
t=40  en=0 data=1 | ext_en=1 ext_data=1  ->  pin=1 data_in=1
t=50  en=1 data=0 | ext_en=1 ext_data=1  ->  pin=x data_in=x   ← 雙方打架
```

### 觀察重點
- **z**：沒有任何一方驅動，Wave 視窗中會畫在上下中間（藍色）。
- **x**：兩方同時驅動不同值，實際電路會短路。同一時間**只能有一方輸出**，
  這就是為什麼 `enable_in_out` 要由控制電路小心管理。
- 和 01_Wand_Wor 對照：wire 多重驅動 = x；z 和任何值合在一起 = 那個值。

---

## 4. 重點整理

| 觀念 | 說明 |
|------|------|
| `inout` | 雙向埠，只能是 wire 類 |
| `1'bz` | 高阻抗，不驅動 |
| 三態寫法 | `assign pin = en ? data : 1'bz;` |
| 讀取接腳 | `assign data_in = pin;` |
| 同時輸出 | 結果為 x，必須避免 |
