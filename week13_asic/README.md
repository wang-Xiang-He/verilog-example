# 第 13–14 週：特殊應用積體電路（ASIC）設計與實作

> **本週一句話**：FPGA 錯了重燒 5 秒，ASIC 錯了重跑光罩幾千萬 —— 所以驗證方式完全不同。

> [!WARNING]
> **⚠️ 課本覆蓋極少。**
> 只有 **1.2 典型「半訂製」(Semi Customize) IC 設計流程**（PDF p.35–41，約 7 頁）。
> 標準元件庫、STA、形式驗證都**沒有專章**，老師必然用自編講義。

## 🖥️ 本週指令

```
cd week13_asic
```

| 範例 | 模擬 | 工具流程 |
|---|---|---|
| `01_generic_synth` | `iverilog -o sim.out 01_generic_synth.v 01_generic_synth_tb.v` | `01_generic_synth.bat` |
| `02_liberty_map` | （用 01 的設計） | `02_liberty_map.bat` |
| `03_sta_concept` | `iverilog -o sim.out 03_sta_concept.v 03_sta_concept_tb.v` | `03_sta_concept.bat` |
| `04_formal` | `iverilog -o sim.out 04_formal.v 04_formal_tb.v` | `04_formal.bat` |

**其他檔案：**
- `tiny_cells.lib` — ★ 自製的玩具級標準元件庫，**打開來看**
- `04_formal_buggy.sby` / `04_formal_fixed.sby` — 形式驗證設定檔

---

## 學完你要會什麼

- [ ] ★ 說得出 ASIC 和 FPGA 整條流程的差別
- [ ] 看得懂 liberty 元件庫檔案在寫什麼
- [ ] ★★ 說得出為什麼正反器在 ASIC 上「很貴」
- [ ] 會算 setup / hold 的 slack
- [ ] 說得出關鍵路徑是什麼、怎麼縮短
- [ ] ★ 會用 `sby` 跑形式驗證，看得懂反例

---

## 一、★ ASIC vs FPGA 全流程對照

| 步驟 | FPGA | ASIC |
|---|---|---|
| 1 綜合 | `synth_ice40` | `synth`（通用閘） |
| 2 元件映射 | （沒這步，就是 LUT） | `dfflibmap` + `abc -liberty` |
| 3 佈局繞線 | `nextpnr-ice40` | 商用 P&R 工具 |
| 4 時序分析 | `icetime` | PrimeTime / OpenSTA |
| 5 驗證 | 上板子測 | DRC + LVS + **形式驗證** |
| 6 產出 | bitstream 檔 | **GDSII 光罩檔** |
| 7 製造 | 燒進去，5 秒 | 送晶圓廠，3–6 個月 |
| 8 **改錯** | 重燒，5 秒 | ★ **重跑光罩，幾千萬台幣** |

> **第 8 行就是這兩週所有內容的起因。**
> 因為改錯的代價差了七、八個數量級，ASIC 的驗證標準完全不同：
> 「測了很多組都對」不夠，關鍵性質要用**數學證明**。

---

## 二、標準元件庫（Standard Cell Library）

`tiny_cells.lib` 是本專案自製的最小元件庫。**打開來看**，真實的元件庫
（台積電、聯電給的）結構一模一樣，只是：

- 有幾百到幾千種元件（各種驅動強度的 AND/OR/FF/加法器/…）
- 延遲是一整張二維查表（依輸入轉換時間和輸出負載電容查）
- 還有功耗、雜訊、面積、腳位電容…等幾十個參數
- 而且是**機密文件**，要簽 NDA 才拿得到

### 本庫的元件與面積

| 元件 | 面積 | 說明 |
|---|---:|---|
| `NOT` | 1 | 最便宜 |
| `BUF` / `NAND2` / `NOR2` | 2 | |
| `AND2` / `OR2` | 3 | |
| `MUX2` | 4 | |
| `XOR2` | **5** | ★ 最貴的基本閘 |
| `DFF` | **18** | ★★ 正反器 |
| `DFFR`（帶非同步 reset） | **22** | |

> [!IMPORTANT]
> **★★ 一顆正反器 = 18 顆 NOT 閘的面積。**
>
> `02_liberty_map.bat` 實測 `counter4`：
> ```
> 整個計數器面積 109，其中 4 顆 DFFR 就吃掉 88（81%）
> 組合邏輯（AND/NAND/NOR/NOT/XOR 共 8 顆）只用了 21
> ```
>
> **這直接推翻第 12 週的結論：**
> - **FPGA**：正反器本來就在那裡，不用白不用 → 盡量切管線
> - **ASIC**：每顆正反器都是真實的面積和功耗 → 切管線要算清楚
>
> 第 12 週說「三級管線只多花 68 顆正反器很划算」，在 FPGA 成立；
> 在 ASIC 上，那是 68 × 18 = 1224 個面積單位，要重新評估。

### 實測面積（`02_liberty_map.bat`）

| 模組 | 元件數 | 總面積 | 組成 |
|---|---:|---:|---|
| `fa` | 7 | 19 | 2 AND2 + 1 MUX2 + 3 NOR2 + 1 OR2 |
| `adder4` | 29 | 69 | |
| `counter4` | 12 | **109** | ★ 4 DFFR 就佔 88 |
| `alu4` | 55 | 136 | |

> [!NOTE]
> **一個踩過的坑**：元件庫裡少了 `BUF` 的話，ABC 的對映器會直接崩潰
> （`&nf` 回傳 -2）。對映器需要緩衝器來修驅動力不足的路徑。
> **元件庫裡沒有的東西，綜合工具就變不出來** —— 這也是為什麼
> 真實元件庫要提供幾百種元件。

---

## 三、★ 靜態時序分析（STA）

| | 動態模擬（前 12 週） | 靜態時序分析 |
|---|---|---|
| 做法 | 餵一組輸入，看輸出對不對 | 不餵輸入，直接算每條路徑的延遲 |
| 涵蓋 | 只有你**想得到**的組合 | **所有**路徑 |
| 時間 | 幾秒到幾小時 | 幾秒 |
| 回答 | 功能對不對 | **能跑多快** |

### setup 檢查

```
   ┌─────┐  Tcq   ┌──────────┐ Tlogic  ┌─────┐
   │ FF1 │───────→│ 組合邏輯 │────────→│ FF2 │
   └─────┘        └──────────┘         └─────┘
      ↑                                    ↑
      └────────────── clk ─────────────────┘

   Tcq + Tlogic + Tsetup  ≤  Tperiod - Tskew

   slack = (Tperiod - Tskew) - (Tcq + Tlogic + Tsetup)
```

- `slack ≥ 0` → **PASS**
- `slack < 0` → **VIOLATION**，時脈要降或路徑要縮

### hold 檢查（另一半，而且更麻煩）

```
   Tcq + Tlogic  ≥  Thold + Tskew
```

> [!WARNING]
> **⚠️ hold 檢查和時脈週期無關！路徑「太短」反而會違規。**
>
> - **setup 沒過** → 把時脈調慢就好（還有救）
> - **hold 沒過** → ★★ 調時脈**沒有用**，晶片直接報廢
>
> 修法：在太短的路徑上**故意插入緩衝器**把它拉長。
> 聽起來很荒謬，但這是標準作法，叫 **hold fixing**。

### 實測（`03_sta_concept.bat`）

| 模組 | 路徑內容 | 最高時脈 |
|---|---|---:|
| `path_short` | 8 顆 XOR（一層邏輯） | **655.31 MHz** |
| `path_medium` | 8 位元加法器 | 244.20 MHz |
| `path_long` | 8×8 乘法器 | **116.05 MHz** |
| `sta_demo` | 三條全放同一個模組 | ★ 約等於 `path_long` |

> [!IMPORTANT]
> **★★ 最後一行是本節最重要的一課。**
>
> `sta_demo` 裡面有一條 655 MHz 的路徑，但整個模組只能跑 116 MHz。
>
> **整個設計的速度由最慢的那一條路徑決定，其他路徑再快都沒用。**
> 那條最慢的就叫**關鍵路徑 Critical Path**。

**縮短關鍵路徑的三個方法：**
1. 切管線（第 12 週）→ 把長路徑切成幾段
2. 換演算法 → 例如乘法改成位移相加
3. 讓工具多花力氣最佳化 → `nextpnr --opt-timing`

> 有趣的驗證：測試平台裡用 `tiny_cells.lib` 的參數**手算**乘法器路徑
> 得到 122.0 MHz，`nextpnr` **實測** 116.05 MHz —— 幾乎一樣。
> 因為兩者做的是同一件事：把路徑上每顆元件的延遲查表加起來。

---

## 四、★★ 形式驗證（Formal Verification）

**模擬**只能證明「你想到的那些情況是對的」。
**形式驗證**能證明「**所有**情況都是對的」。

### 這次要抓的 bug

`fifo_buggy` 的 `full` 旗標**晚一拍**才出來（不小心上了正反器）：

```verilog
//  ❌ BUG
reg full_r;
always @(posedge clk or negedge rst_n)
    if (!rst_n) full_r <= 0;
    else        full_r <= full_comb;   // ← 晚一拍
assign full = full_r;
```

**為什麼難抓：**
- 平常讀寫交錯完全正常
- 只有「連續寫到剛好滿的那一拍又再寫一次」才會出事
- 症狀是「某一筆資料不見」，很容易被當成別的問題

### 形式驗證找到的反例

```
   cycle  rst_n  wr  rd  wp  rp  empty  full  count
   ------------------------------------------------
       1     1    1   0   0   0    1     0      0
       2     1    1   0   1   0    0     0      1
       ...        連續寫入，一次都不讀
       8     1    1   0   7   0    0     0      7
       9     1    1   0   8   0    0     0      8   ← 已經滿了
      10     1    1   1   9   0    0     1      9   ← ★★ full 才剛跳起來
```

**第 9 拍** `count` 已經是 8（滿了），但 `full` 還是 0。
**第 10 拍** 那筆寫入沒被擋住 → `count` 變成 9，第 1 筆被蓋掉。

證明器花了**不到 1 秒**找出這個序列，還附完整波形。

### `assume` 為什麼不能少

```verilog
`ifdef FORMAL
    initial assume (!rst_n);    // ★★ 少了這行整個驗證都是假的
```

**形式驗證的初始狀態是任意的** —— 證明器會假設 `wp`/`rp` 一開始
可以是任何值（例如 `wp=0, rp=1` → `count = 15`）。
那樣抓到的「錯誤」不是你的 bug，是「沒有先 reset」。

> 這是我在做這份教材時真的踩到的坑：一開始沒寫 `assume`，
> 結果**修好的版本也 FAIL**，浪費時間找不存在的問題。

### 兩種模式

| 模式 | 做什麼 | 用在哪 |
|---|---|---|
| `mode bmc` | 找出違反 assert 的輸入序列 | 抓 bug、產生反例 |
| `mode prove` | ★ k-induction 歸納證明 | 證明**永遠**成立 |

> **「successful proof by k-induction」不是「測了 20 拍都沒事」**，
> 是數學證明它在**任何長度、任何輸入序列**下都不會違反。

> [!WARNING]
> **⚠️ `.sby` 檔只能用英文。**
> `sby` 用系統語系（cp950）讀設定檔，寫中文會直接
> `UnicodeDecodeError` 掛掉。中文說明放這份 README。

### 形式驗證的極限

1. **只證明你寫出來的那些 `assert`** —— 沒寫的不會幫你檢查
2. 狀態空間太大時證明器跑不完（記憶體、CPU 都會爆）
3. `assume` 寫太寬鬆 → 證明的是一個不存在的世界

**所以實務上是「模擬 + 形式驗證並用」，不是二選一。**

---

## 五、為什麼一顆晶片要幾千萬

| 項目 | 大約成本 |
|---|---|
| 光罩組（先進製程） | 數百萬～上億台幣 |
| EDA 工具授權 | 每年數百萬～數千萬 |
| 元件庫 / IP 授權 | 依複雜度 |
| 工程師時間 | 十幾人 × 一兩年 |
| 試產（MPW / shuttle） | 數十萬～數百萬 |

**改一次錯 = 重跑一整套光罩。** 這就是為什麼要投入這麼多驗證。

> 學生想做真的晶片，可以查 **CIC（國家晶片系統設計中心）** 的
> 多專案晶圓（MPW）服務，以及開源的 **Efabless / SkyWater 130nm**
> shuttle —— 後者的 PDK 完全開源，可以用本週學的 OSS 工具直接做。

---

## 六、練習題

### 練習 1
把第 12 週的 `mult_pipe3` 和 `mult_comb` 用 `tiny_cells.lib` 映射，
比較 ASIC 面積。

```
yosys -p "read_verilog ../week12_pipeline/02_mult_pipe3.v; synth -top mult_pipe3 -flatten; dfflibmap -liberty tiny_cells.lib; abc -liberty tiny_cells.lib; opt_clean; stat -liberty tiny_cells.lib"
```

**問題**：第 12 週在 FPGA 上得到「管線版 LUT 還比較少」的結論。
在 ASIC 上還成立嗎？為什麼？

### 練習 2
在 `tiny_cells.lib` 裡把 `DFF` 的 `area` 從 18 改成 4，重跑 `02_liberty_map.bat`。
`counter4` 的總面積變成多少？正反器佔比變成多少？

> 這個練習的用意：**面積結論完全取決於元件庫**。
> 換一家晶圓廠、換一個製程，最佳的設計寫法可能就不一樣。

### 練習 3
幫第 9 週的 `04_fifo` 寫形式驗證，證明：
- `count` 永遠不超過深度
- 空的時候不能讀、滿的時候不能寫
- 讀出來的順序和寫進去的一樣（難，需要輔助變數）

### 練習 4（思考）
`04_formal.bat` 裡 buggy 版跑 `mode bmc`、fixed 版跑 `mode prove`。
為什麼不兩個都跑 `prove`？

<details>
<summary>看答案</summary>

**可以都跑 `prove`，buggy 版一樣會 FAIL。**

但 `bmc` 對「找 bug」比較合適，理由：

- `bmc` 只做**有界檢查**（跑到 depth 為止），找到反例就停 —— 很快
- `prove` 要做**歸納證明**，分成 basecase 和 induction 兩步

當設計有 bug 時，`prove` 的 basecase 就會失敗，結果和 `bmc` 一樣，
但多花了時間。**找 bug 用 `bmc`，確認正確用 `prove`。**

反過來，`bmc` **通過不代表設計是對的** —— 它只證明「前 20 拍沒事」。
第 21 拍可能就爆了。要證明「永遠沒事」一定要用 `prove`。
</details>

---

## 七、本週檢核

- [ ] 四個範例都跑過模擬**而且**跑過對應的 `.bat`
- [ ] 打開 `tiny_cells.lib` 看過，知道 liberty 檔在描述什麼
- [ ] ★★ 說得出為什麼「正反器佔 counter4 面積的 81%」很重要
- [ ] 會自己算一條路徑的 setup slack
- [ ] 說得出 setup violation 和 hold violation 哪個比較可怕、為什麼
- [ ] ★ 用 gtkwave 打開過 `04_formal_buggy\engine_0\trace.vcd` 看反例
- [ ] 說得出 `assume` 少寫會發生什麼事

> [!TIP]
> 這兩週的東西在學校大概只會講個大概。
> 但**形式驗證**（`04_formal`）是這裡面最值得花時間的 ——
> 它是現在業界驗證的主流方向之一，而且工具完全免費。
