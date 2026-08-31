# 第 11 週：設計合成

> **本週一句話**：這一週開始，「跑得對」不再是唯一標準 —— 還要問「用了多少資源」。

> **對應課本**：**第 4 章全部**（PDF p.145–182）＋ 11.1 資源共用、11.4 經濟實用的 HDL 原則、11.7 節省電力、2.8 合成流程

> [!IMPORTANT]
> **★ 這一週又要往前翻書。**
> 課綱把「設計合成」排在第 11 週，但課本的主教材是**第 4 章**（在期中考範圍前面）。
> 課本第 11 章只提供補充（資源共用、HDL 撰寫原則）。

## 🖥️ 本週指令

雙擊 `env.bat` 開好環境，然後：

```
cd week11_synthesis
```

**本週和前面不一樣**：除了 `iverilog` 模擬，還要跑 **Yosys 綜合**。

| 範例 | 模擬 | 綜合 |
|---|---|---|
| `01_synth_basic` | `iverilog -o sim.out 01_synth_basic.v 01_synth_basic_tb.v` | `yosys -s 01_synth_basic.ys` |
| `02_unsynth` | `iverilog -DSIM_ONLY -o sim.out 02_unsynth.v 02_unsynth_tb.v` | `02_unsynth.bat` |
| `03_area_compare` | `iverilog -o sim.out 03_area_compare.v 03_area_compare_tb.v` | `03_area_compare.bat` |
| `04_show_netlist` | `iverilog -o sim.out 04_show_netlist.v 04_show_netlist_tb.v` | `04_show_netlist.bat` |

> [!NOTE]
> `02_unsynth` 模擬時**一定要加 `-DSIM_ONLY`**，否則會編譯失敗。
> 原因在下面「為什麼 real 要用 `ifdef 包起來」有解釋。

---

## 學完你要會什麼

- [ ] 看得懂 Yosys 的 `stat` 面積報告
- [ ] ★ 說得出哪些語法**不能合成**，以及為什麼
- [ ] ★★ 知道「模擬通過」和「電路正確」是兩件事
- [ ] 會用資源共用把面積降下來
- [ ] 知道**什麼該手動優化、什麼該交給工具**
- [ ] 會把設計畫成電路圖來看

---

## 一、綜合到底在做什麼

```
   你寫的 Verilog
        ↓  read_verilog     解析成內部表示 (RTL)
   RTL 中間表示
        ↓  proc / opt       化簡布林式、消除沒用到的邏輯
   最佳化後的 RTL
        ↓  techmap          對應到目標元件庫
   閘級網表 (LUT / DFF / CARRY)
        ↓  第 17 週的 nextpnr
   實際擺在晶片上的位置和繞線
```

`synth_ice40` 這個指令就是把上面前三步一次做完。

### iCE40 的三種基本資源

| 資源 | 是什麼 | 對應到你寫的什麼 |
|---|---|---|
| `SB_LUT4` | 4 輸入查表 | **所有組合邏輯** |
| `SB_DFF*` | D 型正反器 | `always @(posedge clk)` |
| `SB_CARRY` | 專用進位鏈 | 加法、減法、比較 |

> [!IMPORTANT]
> **★ FPGA 裡面沒有 AND 閘、沒有 OR 閘。**
> 只有查表。你寫的 `a & b | c`，工具是算出真值表再塞進 LUT 裡，
> 不是真的去接三顆閘。`04_show_netlist` 會讓你親眼看到這件事。

---

## 二、★★ 本週最重要：三種嚴重程度

| 等級 | 綜合工具的反應 | 例子 | 危險度 |
|:---:|---|---|:---:|
| 1 | **報錯**，直接停 | 兩個 `always` 驅動同一個變數、`real` 型別 | 🟢 最好 |
| 2 | **警告**，繼續跑 | 漏 `else` 生 latch | 🟡 要養成看 warning 的習慣 |
| 3 | **默默照做** | `#3` 延遲被丟掉、時脈區塊用 `=` 塌成一顆 | 🔴 **最可怕** |

**等級 3 為什麼最可怕**：模擬對、綜合過、警告一個都沒有，
但**上板子就是不動**，而且完全查不出原因。

`02_unsynth.bat` 實測結果：

```
   good_design   綜合成功、無警告          ← 你要的樣子
   subtle_trap   綜合【失敗】、latch 警告  ← 幸運，被擋下來了
   bad_design    ★ 綜合【成功】、無警告    ← 最危險，錯得無聲無息
```

`bad_design` 裡面有 `initial`、`#3` 延遲、`===` 三個問題，
Yosys 全部默默處理掉，產出 4 個 `SB_DFF` + 1 個 `SB_LUT4`，
**一句話都沒說**。

---

## 三、不能合成的語法（課本 4.1）

| 類別 | 東西 | 為什麼不行 |
|---|---|---|
| 4.1.1 敘述 | `initial` | 硬體沒有「開機執行一次」這回事，起始值只能靠 reset |
| | `#延遲` | 真實延遲由閘和線決定，不是你講了算 |
| | `$display` 等系統任務 | 只存在於模擬器裡 |
| | `forever` / `wait` / `fork-join` | 沒有對應的硬體結構 |
| 4.1.2 運算子 | `===` / `!==` | ★ 真實電路**沒有 x 這種電位**，只有高和低。`x` 是模擬器用來說「我不知道」的記號 |
| 4.1.3 邏輯閘 | `pullup` / `tran` / `rtran` | 這些是電晶體層次的東西 |
| 4.1.4 其他 | `real` 型別 | 硬體只有位元。要小數用第 2 週的定點數 |
| | `force` / `release` | 只有模擬器能強制改一條線的值 |
| | 階層式路徑 `uut.u_dp.acc` | 只能在測試平台裡用 |

### 為什麼 `real` 要用 `` `ifdef `` 包起來

Yosys 遇到 `real` 會在 **`read_verilog` 階段就報語法錯誤**：

```
02_unsynth.v:41: ERROR: syntax error, unexpected TOK_REAL
```

整個腳本直接停掉，後面其他示範全都跑不到。所以本範例把它包起來：

```verilog
`ifdef SIM_ONLY
    output real measured
`endif
```

**這也是實務上的標準作法**：只給模擬看的東西一律用 `` `ifdef `` 包。
模擬時 `iverilog -DSIM_ONLY`，綜合時不加，工具就看不到那段。

---

## 四、本週四個範例

### 📁 `01_synth_basic` — 第一次看面積報告
```
iverilog -o sim.out 01_synth_basic.v 01_synth_basic_tb.v
vvp sim.out
yosys -s 01_synth_basic.ys
```

**實測結果**（Yosys 0.68 / iCE40）：

| 模組 | SB_LUT4 | SB_CARRY | SB_DFF |
|---|---:|---:|---:|
| `adder4` 4位元加法器 | 4 | 4 | 0 |
| `counter4` 4位元計數器 | 5 | 2 | 4 |
| `add8` 8位元加法器 | 8 | 8 | 0 |
| `mult8` 8位元乘法器 | **158** | 12 | 0 |

**★ 這張表要看的兩件事：**

1. `adder4` 一顆正反器都沒有 —— 純組合邏輯就是這樣
2. **`mult8` 用 158 個 LUT，`add8` 只用 8 個 —— 差 20 倍**

> 這就是為什麼實務上會斤斤計較「能不能不要用乘法」。
> 第 12 週要做的管線化乘法器，處理的就是這顆 158 LUT 的怪物。

### 📁 `02_unsynth` — ★★ 本週最重要
```
iverilog -DSIM_ONLY -o sim.out 02_unsynth.v 02_unsynth_tb.v
vvp sim.out
02_unsynth.bat
```
**看什麼**：模擬全部跑得動，但綜合出來三種結果完全不同。

特別注意 `bad_design` **綜合成功**這件事 —— 這是本週最該記住的一頁。

### 📁 `03_area_compare` — 什麼該優化、什麼不該
```
iverilog -o sim.out 03_area_compare.v 03_area_compare_tb.v
vvp sim.out
03_area_compare.bat
```

測試平台會先證明 A/B 版**功能完全相同**，再比面積。

**實測結果：**

| 模組 | LUT4 | CARRY | 總 cells | 結論 |
|---|---:|---:|---:|---|
| `share_bad` 兩顆加法器 | 25 | 16 | 41 | |
| `share_good` 共用一顆 | 16 | 8 | **24** | ★ **省 41%** |
| `mul9_bad` `a*9` | 17 | 7 | 24 | |
| `mul9_good` `(a<<3)+a` | 8 | 8 | **16** | ★ **省 33%** |
| `match_bad` 四個比較器 | 3 | 0 | 3 | |
| `match_good` 手動化簡 | 3 | 0 | 3 | ⚠️ **一模一樣，白忙一場** |
| `pri_ifelse` if-else 鏈 | 5 | 0 | 5 | |
| `pri_casez` casez | 6 | 0 | 6 | ⚠️ **反而變大** |

> [!IMPORTANT]
> **★★ 這張表比「省了多少」更重要的是「什麼時候該省」：**
>
> **值得手動優化的** —— 改變**電路結構**的事：
> 少一顆加法器、少一顆乘法器、把運算搬到迴圈外。
> 工具不會幫你重排資料流，這是設計者的責任。
>
> **不值得手動優化的** —— 布林式化簡、常數傳播、共同子運算式。
> 工具做得比你好而且不會出錯，手動改只會讓程式碼變難讀。
>
> **正確作法**：先照最好讀的方式寫 → 跑綜合看報告 → 真的太大再針對「結構」動手。
> 一開始就為省面積把程式碼寫得很扭曲，通常省不到什麼，卻害自己以後看不懂。

### 📁 `04_show_netlist` — 把電路畫出來
```
iverilog -o sim.out 04_show_netlist.v 04_show_netlist_tb.v
vvp sim.out
04_show_netlist.bat
```

會產生 6 個 `.dot` 檔。**這台機器沒有裝 graphviz**，用線上的最快：

> https://dreampuf.github.io/GraphvizOnline/
> 把 `.dot` 內容整個貼進去就會畫出來。

或裝 VS Code 的「Graphviz Interactive Preview」擴充套件直接預覽。

**★★ 三張圖一定要看：**

1. **`fa_rtl.dot` vs `fa_gate.dot`** ——
   綜合前看得到 XOR / AND / OR，綜合後**全部不見了，只剩 SB_LUT4**。
   因為 iCE40 裡面根本沒有 AND 閘。

2. **`adder2_rtl.dot`** ——
   看得到**兩個 `fa` 方塊**和中間的進位線。
   這就是第 10 週的階層式設計在工具眼中的樣子。

3. **`counter2_rtl.dot`** ——
   ★ 找那條**從 DFF 輸出繞回加法器輸入**的線。
   那條回授線就是「記憶」的來源。組合邏輯的圖永遠不會有迴圈，循序邏輯一定有。

---

## 五、常用 Yosys 指令速查

```
read_verilog design.v          讀進來
hierarchy -top 模組名           指定頂層，展開階層
proc                           把 always 區塊轉成邏輯
opt                            最佳化
synth_ice40 -top 模組名         ★ 上面全部一次做完 + 對應到 iCE40
stat                           印面積報告
show -format dot -prefix 名字   畫電路圖
write_verilog -noattr out.v    輸出閘級網表（第 7 週 04_netlist 用的）
flatten                        打散階層（會讓面積報告變成總量）
tee -a 檔名 指令                把某個指令的輸出同時寫進檔案
```

一行搞定的寫法：

```
yosys -p "read_verilog x.v; synth_ice40 -top top; stat"
```

---

## 六、練習題

### 練習 1
把第 3 週的 `12_alu` 拿來綜合，看它要多少 LUT。

```
yosys -p "read_verilog ../week03_comb_seq/12_alu.v; synth_ice40 -top alu; stat"
```

然後把第 10 週的 `01_alu_hier` 也綜合一次，比較兩者。
**分層版會比較大嗎？** 自己看數字。

### 練習 2
`03_area_compare` 的 `share_good` 省了 41%。
想辦法讓它**再小 20%**（提示：`y` 真的需要 9 位元嗎？）

### 練習 3
把第 9 週的 `02_ram_sp` 綜合看看。
它會變成 LUT 還是 BRAM？加上 `(* ram_style = "block" *)` 屬性有差嗎？

### 練習 4（思考）
下面兩段功能一樣，哪個面積小？先猜，再實測。

```verilog
// A
assign y = (a > b) ? a : b;

// B
always @(*) begin
    y = a;
    if (b > a) y = b;
end
```

<details>
<summary>看答案</summary>

**一樣大。** 兩段都是「一個比較器 + 一個多工器」，
綜合工具會產生完全相同的網表。

這題的用意是：**不要憑感覺猜面積**。
`always` 看起來比較「囉唆」不代表電路比較大 ——
綜合工具看的是邏輯行為，不是你寫了幾行字。

要知道哪個小，唯一的方法就是**跑一次 `stat`**。
</details>

---

## 七、本週檢核

- [ ] 四個範例都跑過模擬**而且**跑過綜合
- [ ] 看得懂 `stat` 報告裡的 LUT4 / DFF / CARRY 各是什麼
- [ ] ★ 說得出 `bad_design` 為什麼比 `subtle_trap` 更危險
- [ ] 用線上 viewer 看過至少三張電路圖
- [ ] ★ 在 `counter2_rtl.dot` 裡找到那條回授線
- [ ] 說得出「什麼該手動優化、什麼該交給工具」
- [ ] 練習 1 做完，知道自己的 ALU 要幾個 LUT

> [!TIP]
> 從這週開始，**每次改完設計都跑一次綜合**，把 warning 看完再收工。
> 這個習慣會在第 15 週上板子的時候救你很多次。
