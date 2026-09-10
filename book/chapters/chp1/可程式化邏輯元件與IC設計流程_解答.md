# 可程式化邏輯元件與 IC 設計流程 — 問題解答

> 說明：可程式化元件的規格是「產品系列」而非單一數字，因此以下以**典型範圍 + 具體型號舉例**呈現。等效閘數（Gate count）在現代 FPGA 已非主要指標（廠商多改用 LUT / Logic Element 數），此處兩種都列。

---

## 演進脈絡（先看這張圖比較好記）

```
PROM → PLA → PAL → GAL → CPLD → FPGA
(固定OR)  (皆可程式) (OTP熔絲) (EEPROM可抹寫) (多顆GAL+繞線) (LUT+繞線矩陣)
  ↑                                                            ↓
  └──────────── 統稱 PLD（可程式化邏輯元件）─────────────────┘

                       ASIC / Standard Cell
              （不可程式化，光罩固定，量產成本最低）
```

| 特性 | PAL | GAL | CPLD | FPGA | Standard Cell ASIC |
|---|---|---|---|---|---|
| 可重複程式化 | ✗（一次性） | ✓（EEPROM） | ✓（Flash） | ✓（SRAM，需開機載入） | ✗ |
| 邏輯結構 | AND-OR 積項 | AND-OR 積項 | AND-OR 積項 | LUT 查表 | 實體邏輯閘 |
| 規模 | 數百 gate | 數百 gate | 數千～數萬 gate | 數萬～數億 gate | 無上限 |
| 延遲可預測性 | 極佳 | 極佳 | 佳（pin-to-pin 固定） | 差（需 STA 收斂） | 需 STA |
| 開機即用 | ✓ | ✓ | ✓ | ✗（SRAM型需數十 ms） | ✓ |
| NRE 成本 | 幾乎為零 | 幾乎為零 | 低 | 低 | 極高（光罩數百萬美元起） |

---

## Question 1：FPGA

### 1-1 FPGA 是什麼？它的外觀？

**FPGA（Field Programmable Gate Array，現場可程式化邏輯閘陣列）** 是一種「出廠後由使用者自行定義內部電路」的半導體元件。它不像 CPU 是「執行指令」，而是把使用者寫的 RTL（Verilog / VHDL）**直接組態成硬體電路**，因此具備真正的平行處理能力與確定性（deterministic）時序。

主流 FPGA 的組態記憶體是 **SRAM-based**（揮發性），所以每次上電都要從外部 SPI Flash 載入 bitstream；也有 Flash-based（Microchip PolarFire、Lattice）與 Antifuse（Microchip RTAX，太空/軍用，一次性）。

**外觀：**

| 等級 | 封裝 | 尺寸 | 例子 |
|---|---|---|---|
| 低階 / 小型 | QFN、CSP、TQFP-144 | 5×5 ~ 20×20 mm | Lattice iCE40、Efinix Trion |
| 中階 | BGA-256 ~ BGA-676 | 17×17 ~ 27×27 mm | Xilinx Artix-7、Intel Cyclone V |
| 高階 | FCBGA / FLGA 1500~2900 ball | 40×40 ~ 60×60 mm，2.5 mm 厚，需大型散熱器 | AMD Versal、Intel Agilex 7 |

高階款外觀特徵：**黑色或金屬蓋（lid / heat spreader）+ 綠色或黑色有機基板 + 底部密密麻麻的錫球陣列（0.8 / 1.0 mm pitch）**。含 HBM 的型號可從側面看到矽中介層（interposer）上並排的 HBM 堆疊。

### 1-2 內部是由哪些元件組成？

| 區塊 | 說明 |
|---|---|
| **CLB / LAB / Logic Element** | 基本邏輯單元。內含 4~6 輸入 **LUT**（查表器，實作任意組合邏輯）、**Flip-Flop**、進位鏈（carry chain）、多工器 |
| **可程式化互連（Routing Fabric）** | 佔晶片面積 **60~80%**。由 switch box、connection box 與各種長度的金屬線段組成，決定了 FPGA 的時序瓶頸 |
| **IOB（I/O Block）** | 支援 LVCMOS / LVDS / SSTL / POD 等電氣標準，含 IDELAY/ODELAY、SERDES、可程式化驅動強度與 ODT |
| **Block RAM / EBR** | 硬式 SRAM 巨集，18 Kb / 20 Kb 為單位，可組態成單埠、雙埠、FIFO、ROM |
| **UltraRAM / eSRAM** | 大容量 SRAM（288 Kb / block，AMD UltraScale+ 起） |
| **DSP Slice / DSP Block** | 硬式乘加器（MAC），如 DSP48E2 = 27×18 乘法 + 48-bit 累加；新世代支援 FP32/BF16/INT8 |
| **時脈管理** | PLL、DLL、MMCM、global clock tree、clock buffer（BUFG） |
| **高速收發器（GTY/GTM/SerDes）** | 支援 PCIe、Ethernet、Aurora，最高 112 Gbps PAM4 |
| **硬核 IP（Hard IP）** | PCIe Gen5、DDR5/LPDDR5 控制器、100G Ethernet MAC、加密引擎 |
| **處理器子系統（SoC FPGA）** | ARM Cortex-A53/A72/R5、RISC-V，如 Zynq UltraScale+、Agilex、PolarFire SoC |
| **組態記憶體（Configuration SRAM）** | 儲存 bitstream，控制每一顆 LUT 與每一個 switch |
| **系統監控** | XADC / SYSMON（溫度、電壓感測）、eFUSE、安全開機 |

### 1-3 工作頻率範圍

| 項目 | 範圍 |
|---|---|
| **內部 Fabric（使用者邏輯）** | 低階 **50~200 MHz**；中階 **200~400 MHz**；高階可達 **500~900 MHz**（需精心 pipeline） |
| **硬核 DSP / BRAM** | 600 MHz ~ 1 GHz |
| **記憶體介面** | DDR4-3200 → 1.6 GHz clock；LPDDR5 → 3.2 GHz |
| **高速收發器** | 10 / 16 / 28 / 58 / 112 Gbps（等效 **數十 GHz**） |
| **AI Engine（Versal）** | 1.0 ~ 1.4 GHz |

> 結論：**Fabric 是 MHz 級（百 MHz 為主），I/O 與 SerDes 是 GHz 級。** 這是 FPGA 與 CPU（GHz 級）最大的差異——FPGA 用「寬度與平行度」換取吞吐量，而非用頻率。

### 1-4 I/O count (接腳數) / Gate count (等效邏輯閘數)

| 等級 | User I/O | Logic Cell / LE | 等效 Gate（約略換算） |
|---|---|---|---|
| 入門（iCE40, Spartan-7） | 20 ~ 250 | 1 K ~ 100 K | 數萬 ~ 200 萬 |
| 中階（Artix UltraScale+, Cyclone 10） | 200 ~ 500 | 100 K ~ 500 K | 200 萬 ~ 1000 萬 |
| 高階（Virtex UltraScale+, Agilex 7） | 500 ~ 1,300 | 500 K ~ 4 M | 1000 萬 ~ 1 億以上 |
| 極限型號（VU19P） | ~2,000 | **8.9 M** system logic cell | > 1 億 |

**換算慣例：1 個 LUT4 ≈ 10~15 個等效 2-input NAND gate**，但廠商換算方式不同，跨品牌比較意義不大。

### 1-5 RAM 與 DSP (數位訊號處理單元，專門用來執行複雜數學運算的「硬體加速器」)

| 等級 | 內建 RAM | DSP Slice |
|---|---|---|
| 入門 | 64 Kb ~ 5 Mb | 0 ~ 120 |
| 中階 | 5 Mb ~ 50 Mb | 200 ~ 2,000 |
| 高階 | 50 Mb ~ 500 Mb（BRAM + URAM） | 2,000 ~ 12,288 |
| 含 HBM 型號 | 外加 **8 ~ 32 GB HBM2e**，頻寬 460 GB/s ~ 819 GB/s | — |

具體例：
- **Xilinx Artix-7 XC7A100T**：101,440 LC、4,860 Kb BRAM、240 DSP48E1、300 I/O
- **AMD Virtex UltraScale+ VU13P**：3.78 M LC、94.5 Mb BRAM + 360 Mb URAM、12,288 DSP、832 I/O
- **AMD Versal VP1802**：3.7 M LC、外加 AI Engine 陣列

---

## Question 2：CPLD

### 2-1 CPLD 是什麼？它的外觀？

**CPLD（Complex Programmable Logic Device，複雜可程式化邏輯元件）** 可視為「把數十顆 GAL 放進同一顆晶片，再用全域繞線矩陣連起來」的產物。與 FPGA 最關鍵的三個差異：

1. **非揮發性**：組態存在內建 Flash / EEPROM，**上電立即工作（instant-on，通常 < 1 ms）**，不需外掛 configuration flash。
2. **延遲可預測**：訊號一律走「macrocell → 全域繞線矩陣 → macrocell」，pin-to-pin 延遲固定（如 4.5 ns），不像 FPGA 隨繞線結果變動。
3. **邏輯結構是積項（product term）而非 LUT**，適合寬輸入的組合邏輯（如位址解碼），不適合大量暫存器或運算。

典型用途：**上電時序控制（power sequencing）、板級膠合邏輯（glue logic）、位址解碼、介面轉換、看門狗、FPGA 的開機管理者**。這在 Delta 這類電源／工業控制的板子上非常常見。

**外觀：** 小型表面黏著封裝——TQFP-44/100/144、QFN-32/48、csBGA-132/324。尺寸約 **5×5 mm ~ 22×22 mm**，遠小於 FPGA，通常不需散熱片。

### 2-2 內部組成

| 區塊 | 說明 |
|---|---|
| **Logic Block（LAB / FB / GLB）** | 每個區塊含 16 個 macrocell，是 CPLD 的基本組成單位 |
| **Macrocell** | 核心單元：**可程式化 AND 陣列（產生 product term）→ product term 分配器 → OR/XOR → Flip-Flop → 輸出控制** |
| **PIA / GRP（全域繞線陣列）** | Programmable Interconnect Array，把所有 logic block 的輸出繞回所有 block 的輸入，是延遲固定的關鍵 |
| **I/O Block** | 含三態緩衝、上下拉、slew rate 控制、多組 I/O bank（可支援不同 VCCIO） |
| **內建 Flash / EEPROM** | 儲存組態；同時提供 **UFM（User Flash Memory）** 供使用者存參數 |
| **JTAG / ISP 介面** | IEEE 1149.1，支援在板燒錄（In-System Programming） |
| **內部振盪器 / 時脈分頻** | 新一代（MAX 10、MachXO3）內建 RC 振盪器，可獨立運作不需外部晶振 |

### 2-3 工作頻率範圍

- **典型 fMAX：100 ~ 400 MHz**（純 MHz 級，**不到 GHz**）
- **pin-to-pin 傳播延遲 tPD：2.5 ~ 7.5 ns**
- 具體例：Xilinx CoolRunner-II fMAX 323 MHz / tPD 3.8 ns；Altera MAX V fMAX 304 MHz；Lattice MachXO3 fMAX ~ 400 MHz

### 2-4 I/O count / Gate count

| 系列 | Macrocell | User I/O | 等效 Gate |
|---|---|---|---|
| 小型（MAX V 40Z、XC2C32A） | 32 ~ 40 | 21 ~ 33 | 約 600 ~ 800 |
| 中型（XC2C256、EPM240） | 240 ~ 256 | 80 ~ 180 | 3 K ~ 6 K |
| 大型（XC2C512、MAX V 2210Z） | 512 ~ 2,210 | 180 ~ 271 | 10 K ~ 50 K |
| 混血型（MAX 10 10M50） | 50 K LE（已是 FPGA 架構） | 500 | > 100 萬 |

### 2-5 RAM 與 DSP

- **傳統 CPLD：兩者皆無。** 只有 macrocell 內的 FF 可當暫存器，沒有 block RAM，也沒有硬體乘法器。
- **例外——現代「非揮發性 FPGA」（常被歸類為 CPLD）：**
  - **Intel MAX 10**：內建 **1,638 Kb M9K RAM + 144 個 18×18 乘法器 + 12-bit ADC**
  - **Lattice MachXO3D**：**208 Kb EBR + 上百 Kb UFM**，無 DSP
  - **Lattice MachXO2**：18~240 Kb EBR、無 DSP

> 一句話總結：**要 RAM 和 DSP 就該用 FPGA；選 CPLD 是為了「開機即用 + 延遲固定 + 便宜 + 省電」。**

---

## Question 3：PLD

### 3-1 PLD 是什麼？它的外觀？

**PLD（Programmable Logic Device，可程式化邏輯元件）** 是**所有可程式化邏輯元件的統稱**，是一個上位分類名詞，涵蓋：

```
PLD
├── SPLD（Simple PLD）── 一般口語講「PLD」時通常指這一層
│   ├── PROM  （AND 陣列固定，OR 陣列可程式）
│   ├── PLA   （AND、OR 陣列皆可程式 → 最靈活但最慢最貴）
│   ├── PAL   （AND 可程式，OR 固定 → 速度快，成為主流）
│   └── GAL   （PAL 架構 + EEPROM，可重複抹寫）
├── CPLD（Complex PLD）
└── FPGA
```

三種陣列架構差異（這是考試最愛考的）：

| 型態 | AND 陣列 | OR 陣列 | 特性 |
|---|---|---|---|
| **PROM** | 固定（全解碼） | 可程式化 | 適合查表，輸入一多陣列就爆炸成長 |
| **PLA** | 可程式化 | 可程式化 | 最有彈性，但兩層都可程式 → 延遲大、成本高 |
| **PAL** | 可程式化 | 固定 | 只有一層可程式 → 快、便宜，**商業上最成功** |

**外觀：** 早期為 **DIP-20 / DIP-24 黑色塑膠雙排包裝**（約 25 mm × 7 mm，2.54 mm 腳距），亦有 **PLCC-20/28（J 型腳，方形）** 與後期的 TQFP。開窗版（EPLD，UV 抹除）表面有石英玻璃窗，可用紫外燈抹除重寫。

### 3-2 內部組成

1. **輸入緩衝器**：每個輸入產生「原信號 + 反相信號」兩條線送入陣列
2. **可程式化 AND 陣列**：交叉點上有可程式化元件，形成 **product term（積項）**
3. **OR 陣列**：把數個 product term 相加 → 形成 **SOP（Sum-of-Products，積之和）**
4. **可程式化元件（依世代不同）**：
   - 熔絲 Fuse（燒斷式，OTP）
   - 反熔絲 Antifuse（燒通式，OTP，抗輻射）
   - EPROM cell（UV 抹除）
   - EEPROM / Flash cell（電子抹除，可重複）
5. **輸出巨集單元（Output Macrocell）**：D-FF、極性選擇 XOR、三態輸出緩衝、回授路徑（feedback）

### 3-3 工作頻率範圍

- 1980 年代初期：**tPD 25~45 ns → fMAX 約 16~40 MHz**
- 1990 年代高速版本（如 PALCE16V8-5）：**tPD 5~7.5 ns → fMAX 100~166 MHz**
- **全部落在 MHz 級，與 GHz 完全無關。**

### 3-4 I/O count / Gate count

- **腳位總數：20 ~ 28 pin**（扣除 VCC/GND 後，可用 I/O 約 **16 ~ 24**）
- **等效閘數：數十 ~ 數百 gate**，典型 **100 ~ 750 gate**
- 巨集單元數：**8 ~ 10 個**

---

## Question 4：GAL

### 4-1 GAL 是什麼？它的外觀？

**GAL（Generic Array Logic，通用陣列邏輯）** 是 **Lattice Semiconductor 於 1985 年推出的註冊商標**，本質是「**用 EEPROM 取代熔絲的 PAL 相容元件**」。

三個關鍵賣點：
1. **可電子抹除、重複燒錄 100 次以上**（PAL 燒錯就報廢，GAL 可以重來）
2. **一顆 GAL16V8 可模擬 20 多種不同型號的 PAL**（"Generic" 的由來），大幅簡化庫存
3. 內建 **security fuse** 防拷貝，與 **electronic signature** 供識別

**外觀：** 與 PAL 完全相同，**DIP-20 / DIP-24 黑色塑膠封裝**，或 **PLCC-20 / PLCC-28**。上蓋絲印如「GAL16V8D-15LP」。因為 EEPROM 是電子抹除，**外觀上沒有石英窗**（這是與 EPROM 型 EPLD 最好認的差別）。

### 4-2 內部組成

| 區塊 | 說明 |
|---|---|
| **可程式化 AND 陣列** | 由 **EEPROM cell** 構成交叉點，取代 PAL 的金屬熔絲 |
| **固定 OR 陣列** | 每個輸出固定分配 7~16 個 product term |
| **OLMC（Output Logic Macro Cell）** | **GAL 的靈魂**。每個 OLMC 含 D-FF、4-to-1 輸出多工器、XOR 極性控制、三態緩衝、回授多工器。透過 SYN / AC0 / AC1 / XOR 四個組態位元，可切換成 **Registered / Complex / Simple / Dedicated Input** 四種模式 → 這就是能模擬多種 PAL 的原因 |
| **EEPROM 組態陣列** | 儲存熔絲圖（JEDEC fuse map），非揮發，資料保存 20 年以上 |
| **Security Cell** | 燒錄後無法回讀，防止逆向 |

### 4-3 工作頻率範圍

| 型號 | tPD | fMAX |
|---|---|---|
| GAL16V8-25 | 25 ns | 約 40 MHz |
| GAL16V8-15 | 15 ns | 約 62 MHz |
| GAL16V8D-7 | 7.5 ns | **100 MHz** |
| GAL22V10D-4 | 4.5 ns | **166 ~ 250 MHz** |

**MHz 級，最高約 250 MHz，不到 GHz。**

### 4-4 I/O count / Gate count

| 型號 | 封裝 | 專用輸入 | I/O 腳 | OLMC 數 | 等效 Gate |
|---|---|---|---|---|---|
| **GAL16V8** | DIP-20 | 8 | 8 | 8 | 約 **300** |
| **GAL20V8** | DIP-24 | 12 | 8 | 8 | 約 **400** |
| **GAL22V10** | DIP-24 | 12 | 10 | 10 | 約 **500 ~ 750** |
| **GAL26CV12** | DIP-28 | 14 | 12 | 12 | 約 **900** |

> 命名規則：**GAL 16 V 8** = 最多 **16** 個陣列輸入 / **V**ariable（OLMC 可變組態）/ **8** 個輸出。這個規則同樣適用於 PAL。

---

## Question 5：PAL

### 5-1 PAL 是什麼？它的外觀？

**PAL（Programmable Array Logic，可程式化陣列邏輯）** 由 **MMI（Monolithic Memories Inc.）的 John Birkner 與 H. T. Chua 於 1978 年發明**，是可程式化邏輯商業化的真正起點（MMI 後被 AMD 併購，PAL 業務再分拆為 Vantis，最終賣給 Lattice）。

**設計上的關鍵取捨**：PLA 兩層陣列都可程式化，靈活但慢又貴；PAL **只讓 AND 陣列可程式化、OR 陣列固定**，犧牲部分彈性換來**更快的速度與更低的成本**——結果大獲成功，取代了電路板上大量的 74 系列 TTL 邏輯。

**最大缺點：使用金屬熔絲（fusible link），一次性燒錄（OTP），燒錯只能丟掉。** 這正是 GAL 出現的理由。

**外觀：** **DIP-20 / DIP-24 黑色塑膠或陶瓷封裝**，或 PLCC。絲印如「PAL16L8ACN」「PAL22V10-15PC」。與 GAL 從外觀上幾乎無法分辨，只能看料號。

### 5-2 內部組成

1. **輸入緩衝器**（產生真值/補數兩條線）
2. **可程式化 AND 陣列**：交叉點為 **NiCr 或多晶矽熔絲**，燒錄時用高電流燒斷 → 不可逆
3. **固定 OR 閘**：每個輸出接收固定數量（通常 7~8 個，22V10 為 8~16 個）的 product term
4. **輸出區**（依系列而異）：
   - **L**（Active Low）：組合輸出、低態動作，如 PAL16L8
   - **H**（Active High）：組合輸出、高態動作
   - **R**（Registered）：輸出經 D-FF，如 PAL16R8
   - **V**（Versatile）：可組態巨集單元，如 PAL22V10
5. **三態輸出緩衝 + 回授路徑**

### 5-3 工作頻率範圍

| 世代 | tPD | fMAX |
|---|---|---|
| 標準 PAL（1978~1982） | 35 ~ 45 ns | 約 **16 ~ 25 MHz** |
| A / B 系列 | 15 ~ 25 ns | 約 **37 ~ 55 MHz** |
| D 系列 / PALCE 高速版 | 5 ~ 10 ns | **90 ~ 125 MHz** |
| 極速版（PAL22V10-5） | 5 ns | 約 **125 ~ 166 MHz** |

**MHz 級，與 GHz 無關。**

### 5-4 I/O count / Gate count

| 型號 | 封裝 | 輸入 | 輸出 | 輸出型態 | 等效 Gate |
|---|---|---|---|---|---|
| **PAL16L8** | DIP-20 | 10（+6 I/O 可當輸入） | 8（其中 6 個為雙向 I/O） | 組合、Active Low | 約 **300** |
| **PAL16R8** | DIP-20 | 8 | 8 | 全暫存器輸出 | 約 **300** |
| **PAL16R4 / R6** | DIP-20 | 8 | 8（4 或 6 個暫存器 + 其餘組合） | 混合 | 約 **300** |
| **PAL20L8** | DIP-24 | 14 | 8 | 組合 | 約 **400** |
| **PAL22V10** | DIP-24 | 12 | 10（可變組態） | 可組態 | 約 **500 ~ 750** |

> 補充：PAL22V10 的每個輸出分配的 product term 數量**不平均**（8、10、12、14、16、16、14、12、10、8），這是為了讓複雜邏輯集中在中間幾支腳——考試常考的細節。

---

## Question 6：Standard Cell

### 6-1 Standard Cell 是什麼？它的外觀？

**Standard Cell（標準單元）** 是 **ASIC / SoC 設計中，由晶圓廠（或 IP 供應商）預先設計、佈局、萃取、驗證完成的基本邏輯電路積木**。設計者不需畫電晶體，只要寫 RTL，合成工具（Design Compiler / Genus）就會自動從 **Standard Cell Library** 挑選並串接這些單元。

**注意：Standard Cell 不是一顆可以買回來插在板子上的元件**，它是晶片內部的一個圖形區塊（layout）。它「外觀」指的是版圖上的樣子：

**版圖外觀特徵：**

```
  ←─────── VDD power rail ────────→
  ┌────┬──────┬────┬────────┬────┐
  │INV │ NAND2│BUF │  DFF   │AOI │   ← Row 1（所有 cell 高度相同）
  └────┴──────┴────┴────────┴────┘
  ←─────── VSS power rail ────────→
  ┌──────┬────┬────────┬──────────┐
  │ MUX2 │INV │  DFF   │  NOR3    │   ← Row 2（上下翻轉，共用 power rail）
  └──────┴────┴────────┴──────────┘
```

- **統一高度（cell height）**：以 **track 數**表示，如 12T（舊製程）、9T、7.5T、6T（先進節點）。高度統一才能排成 row。
- **寬度為 poly pitch（CPP）的整數倍**：邏輯越複雜、驅動力越大 → 越寬。
- **上下相鄰 row 鏡射（mirror）**，共用 VDD / VSS 電源軌 → 省面積。
- **接腳（pin）在特定金屬層**（M1 或 M2），位置對齊繞線格點（routing grid）。

**Library 內容分類：**

| 類別 | 例子 |
|---|---|
| 組合邏輯 | INV、BUF、NAND、NOR、AND、OR、XOR、AOI/OAI、MUX、半加器/全加器 |
| 序向邏輯 | DFF（含 set/reset/scan/enable 各種變體）、Latch |
| 特殊單元 | Clock Buffer、Delay Cell、Level Shifter、Isolation Cell、Retention FF、Power Switch |
| 實體單元（無功能） | **Filler cell、Decap cell、Tap cell、Antenna diode、End-cap cell** |
| 驅動強度變體 | 同一功能有 X1 / X2 / X4 / X8 / X16 多種驅動力供 timing 最佳化選用 |
| Vt 變體 | **LVT / SVT / HVT / ULVT**（低臨界電壓快但漏電大 ↔ 高臨界電壓慢但省電） |

每顆 cell 都附帶 **.lib（Liberty，時序/功耗模型）、.lef（實體抽象）、GDSII（完整版圖）、SPICE netlist、Verilog 功能模型**——這一整套就是 EDA 流程的基礎。

**最終產品的外觀**：使用 Standard Cell 做出來的成品就是各種 **ASIC / SoC**，封裝成 BGA、QFN、QFP、CSP，肉眼是看不到 cell 的（需要開蓋後用電子顯微鏡才看得到那一排排 row）。

### 6-2 工作頻率範圍

Standard Cell 本身沒有「工作頻率」，它決定的是**單級延遲（stage delay）**，最終頻率取決於製程節點、Vt 選擇、pipeline 深度與關鍵路徑長度。

| 製程節點 | 單一 FO4 反相器延遲 | 典型設計可達頻率 |
|---|---|---|
| 180 nm | ~ 90 ps | 100 ~ 400 MHz |
| 90 nm | ~ 45 ps | 300 MHz ~ 1 GHz |
| 40 nm | ~ 20 ps | 500 MHz ~ 2 GHz |
| 16/14 nm FinFET | ~ 10 ps | 1 ~ 3.5 GHz |
| 7/5 nm | ~ 6 ps | 2 ~ 5 GHz |
| 3/2 nm | ~ 4 ps | **3 ~ 6 GHz**（高效能 library） |

實務區間：
- **低功耗 IoT / MCU**：50 ~ 500 MHz
- **行動 SoC**：1.8 ~ 4.0 GHz
- **桌機/伺服器 CPU**：3 ~ 6 GHz（用 High-Performance / ULVT library + custom circuit）
- 環形振盪器（ring oscillator，僅供製程監控）可衝到 10 GHz 以上，但那不是可用設計。

> 關鍵觀念：**同一份 RTL，選 HVT library 可能只跑 800 MHz 但很省電；選 ULVT library 可跑 2 GHz 但漏電暴增 10 倍。** 這是 physical design 的核心取捨。

---

## Question 7：全世界著名的晶圓廠（Wafer Fab）

### 7-1 純晶圓代工廠（Pure-play Foundry）— 只做代工，不賣自有品牌晶片

2026 年全球前十大代工廠依序約為：TSMC（台灣）、Samsung Foundry（南韓）、SMIC 中芯國際（中國）、UMC 聯電（台灣）、GlobalFoundries（美國）、華虹集團（中國）、Tower Semiconductor（以色列）、世界先進 VIS（台灣）、Nexchip 晶合集成（中國）、力積電 PSMC（台灣）。

| 公司 | 總部 | 特色 | 領先製程 |
|---|---|---|---|
| **台積電 TSMC** | 台灣新竹 | 絕對龍頭，佔全球代工營收約 66~70%；AI/HPC 大客戶（NVIDIA、Apple、AMD、Broadcom）；CoWoS 先進封裝 | N2 / N3 |
| **三星 Samsung Foundry** | 南韓器興/華城/平澤 | 唯一在先進製程上與台積電競爭者，GAA 技術先行 | SF2 / SF3 |
| **中芯國際 SMIC** | 中國上海 | 中國最大代工廠，受出口管制影響，主攻成熟製程與 N+2 | 7 nm 級 |
| **聯電 UMC** | 台灣新竹 | 台灣第二大，成熟製程（28 nm、22 nm）與特殊製程強項 | 22 / 14 nm |
| **格羅方德 GlobalFoundries** | 美國紐約 Malta | 已放棄 7 nm，專攻 **FD-SOI、RF、車用、特色製程** | 12 nm |
| **華虹 Hua Hong** | 中國上海 | 功率元件、嵌入式記憶體、類比 | 成熟製程 |
| **高塔 Tower Semiconductor** | 以色列 Migdal Haemek | **類比、RF、SiGe、影像感測、矽光子** | 特色製程 |
| **世界先進 VIS** | 台灣新竹 | 電源管理 IC、顯示驅動 IC、感測器 | 成熟製程 |
| **力積電 PSMC** | 台灣竹科/銅鑼 | 由 DRAM 廠轉型，特殊記憶體與邏輯代工 | 成熟製程 |
| **Intel Foundry（IFS）** | 美國 | 新進代工者，18A 為 sub-2 nm 級，採 GAA + 背面供電（PowerVia），2026 年對外部客戶量產爬坡中 | 18A / 14A |
| **Rapidus** | 日本北海道千歲 | 日本國家隊，與 IBM 合作，目標 2 nm | 2 nm（試產） |

### 7-2 IDM（Integrated Device Manufacturer）— 自有設計 + 自有晶圓廠

| 領域 | 公司 |
|---|---|
| **CPU / 邏輯** | Intel、AMD（已 fabless）、IBM（已轉出製造） |
| **記憶體** | **Samsung、SK Hynix、Micron 美光、Kioxia 鎧俠**、南亞科 Nanya、華邦 Winbond、旺宏 Macronix、長江存儲 YMTC、長鑫存儲 CXMT |
| **車用 / 工業 / 功率** | **Infineon 英飛凌、STMicroelectronics 意法、NXP 恩智浦、Renesas 瑞薩、onsemi 安森美、Bosch 博世、ROHM 羅姆、三菱電機** |
| **類比 / 混合訊號** | **Texas Instruments（TI）、Analog Devices（ADI）、Microchip、Skyworks、Qorvo** |
| **影像感測** | **Sony 索尼**（CIS 全球第一）、Samsung |
| **化合物半導體（SiC / GaN）** | Wolfspeed、Infineon、onsemi、ROHM、II-VI/Coherent |

### 7-3 台灣半導體聚落（值得記住的完整鏈）

| 環節 | 代表公司 |
|---|---|
| IC 設計 | 聯發科 MediaTek、聯詠 Novatek、瑞昱 Realtek、群聯 Phison、瑞鼎、譜瑞 |
| **晶圓代工** | **台積電、聯電、力積電、世界先進、漢磊（化合物）** |
| 記憶體 | 南亞科、華邦、旺宏 |
| **封裝測試（OSAT）** | **日月光 ASE（全球第一）、矽品 SPIL、力成 PTI、京元電 KYEC（測試）、南茂 ChipMOS** |
| 材料 / 設備 | 中美晶、環球晶 GlobalWafers（矽晶圓全球第三）、家登、崇越、帆宣 |

> 補充：全球封測（OSAT）龍頭依序為 **日月光 ASE、Amkor（美國）、江蘇長電 JCET（中國）、力成 PTI、通富微電**。這一段常被忽略，但 Question 8 的「IC 封裝」與「IC 測試」正是由這些公司執行。

---

## Question 8：一顆 IC 從無到有的完整流程

```
【前段：設計】                        【後段：製造】
                                    
1. IC 功能需求 ──→ 2. IC 設計 ──→ 5. 晶圓製造 ──→ 6. 晶圓測試
        ↑              ↓ ↑              (Fab)         (CP/Sort)
        │      3. 電路模擬 │                              ↓
        │      4. 電路驗證 │                        7. IC 封裝
        │              ↓ │                              ↓
        └──── 9. IC 功能驗證 ←──────────────────── 8. IC 測試
                （Silicon Validation）                (FT)
```

---

### 步驟 1 — IC 功能需求（Specification）

**目標：把「市場想要什麼」翻譯成「工程可以執行的規格書」。**

| 工作項目 | 內容 |
|---|---|
| 市場/客戶需求分析 | 目標應用、競品分析、量產時程（time-to-market）、預估出貨量 |
| 功能規格定義 | 功能清單、介面協定（PCIe/USB/MIPI/CAN）、暫存器定義 |
| 效能/功耗/面積（PPA）目標 | 目標頻率、TDP、die size 預算 |
| 系統架構設計 | 匯流排架構、記憶體階層、CPU/DSP/加速器切分、軟硬體切分 |
| 演算法建模 | MATLAB / Simulink / C++ 建立 golden model，做 bit-accurate 驗證 |
| 製程與 IP 選型 | 選晶圓廠與節點（成本 vs 效能）、外購 IP（ARM core、DDR PHY、SerDes） |
| 成本評估 | NRE（光罩 + 設計人力）、die cost、封裝成本、預估良率 |

**產出：Spec Document、Architecture Spec、Verification Plan、專案排程與 BOM 成本模型。**

> 這一步做錯，後面全錯——先進節點一次 tape-out 光罩成本可達數百萬至上千萬美元。

---

### 步驟 2 — IC 設計（Design / Implementation）

**A. 數位前端（Front-end）**

| 階段 | 說明 | 工具 |
|---|---|---|
| RTL 設計 | 用 Verilog / SystemVerilog / VHDL 描述行為 | VS Code、Verdi |
| Lint / CDC / RDC 檢查 | 語法規範、跨時脈域檢查、重置域檢查 | SpyGlass、Meridian |
| **邏輯合成（Synthesis）** | RTL + **Standard Cell Library** + 時序約束（SDC）→ **Gate-level Netlist** | Design Compiler、Genus、Fusion Compiler |
| DFT 插入 | Scan chain、MBIST、JTAG/IEEE 1149.1、boundary scan | DFT Compiler、Tessent |
| 形式驗證 | RTL vs Netlist 邏輯等價檢查（LEC） | Formality、Conformal |

**B. 數位後端 / 實體設計（Back-end / Physical Design）**

| 階段 | 說明 | 工具 |
|---|---|---|
| Floorplan | 決定 die 尺寸、macro（RAM/PLL）擺放、I/O ring、電源規劃（Power Plan） |  |
| Placement | 把數百萬~數十億顆 standard cell 擺進 row | IC Compiler II、Innovus |
| **CTS（Clock Tree Synthesis）** | 建時脈樹，控制 skew 與 latency |  |
| Routing | 金屬層繞線（先進製程 15~20 層金屬） |  |
| **STA（靜態時序分析）** | 檢查 setup / hold，多 corner 多模式（MCMM） | PrimeTime、Tempus |
| 訊號完整性 / IR Drop | crosstalk、EM/IR 分析 | RedHawk、Voltus |
| **實體驗證** | **DRC**（設計規則）、**LVS**（版圖對電路）、**ERC**、Antenna | Calibre、ICV、Pegasus |
| 寄生萃取（RC Extraction） | 產生 SPEF 供後模擬與 STA | StarRC、Quantus |
| **Tape-out** | 產出 **GDSII / OASIS** 交付晶圓廠 |  |

**C. 類比 / 混合訊號（Analog / Mixed-Signal）**
- 手繪 Schematic → SPICE 模擬 → **Custom Layout（手工佈局，講究 matching、對稱、guard ring）** → LVS/DRC → post-layout 模擬
- 工具：Virtuoso、Spectre、HSPICE、Calibre

---

### 步驟 3 — 電路模擬（Circuit Simulation）

**確認「電路在物理層面是否真的能動」。**

| 類型 | 說明 |
|---|---|
| **SPICE / 電晶體級模擬** | HSPICE、Spectre、FineSim、Eldo。用於類比電路、記憶體 bit cell、I/O buffer、標準單元特性化 |
| **Corner / PVT 模擬** | Process（SS/TT/FF/SF/FS）× Voltage（±10%）× Temperature（−40 ~ 125 °C），確保全條件下都能工作 |
| **Monte Carlo 模擬** | 分析製程變異（mismatch、random dopant fluctuation）對良率的影響 |
| **Gate-level Simulation** | 帶 SDF 反標時序的閘級模擬，抓 X-propagation、reset 問題 |
| **Post-layout Simulation** | 加入 RC 寄生後重跑，通常效能會掉 10~30% |
| **功耗分析** | 動態/靜態功耗、IR drop、電源完整性 |
| **可靠度模擬** | EM（電遷移）、ESD、Latch-up、NBTI/HCI 老化 |

---

### 步驟 4 — 電路驗證（Verification）

**確認「電路的行為是否符合規格」——這一步通常佔整個專案 50~70% 的工時。**

| 方法 | 說明 |
|---|---|
| **功能驗證（Functional Verification）** | **UVM / SystemVerilog** 建 testbench，constrained-random 隨機測試 + directed test |
| **覆蓋率驅動驗證（CDV）** | Code coverage（line/toggle/FSM/branch）+ Functional coverage，目標接近 100% |
| **Assertion-Based Verification** | **SVA（SystemVerilog Assertion）** 內嵌斷言，即時抓錯 |
| **形式驗證（Formal）** | 數學方法窮舉所有狀態，證明性質必成立；亦用於 LEC 等價檢查 |
| **硬體加速（Emulation）** | Palladium、Veloce、ZeBu — 跑到 MHz 級，可跑完整 OS boot |
| **FPGA 原型驗證（Prototyping）** | 把設計燒進大型 FPGA，讓軟體團隊提早開發驅動與韌體 |
| **靜態時序分析（STA）** | 不需 vector，窮舉所有路徑檢查 setup/hold |
| **低功耗驗證** | UPF/CPF 描述電源域，驗證 power gating、isolation、retention 正確 |

> Front-end 驗證與 Back-end 實體驗證（DRC/LVS）是兩件不同的事，容易混淆：**前者驗「邏輯對不對」，後者驗「版圖畫得合不合法」。**

---

### 步驟 5 — 晶圓製造（Wafer Fabrication）

**GDSII → 光罩 → 實體晶圓。這是最昂貴、耗時最長的一段（先進製程 cycle time 約 2~4 個月，數百至上千道製程步驟）。**

| 階段 | 說明 |
|---|---|
| **光罩製作（Mask Making）** | 資料處理（Fracturing）→ **OPC 光學鄰近修正** → RET（相位移、SRAF）→ 電子束寫在石英上 → 檢測修補。先進節點一套光罩 3,000 萬~1 億美元以上 |
| **矽晶圓製備** | 長晶（**CZ 柴氏長晶法**）→ 切片 → 研磨 → 拋光 → 磊晶（Epi）。主流 **12 吋（300 mm）**，成熟製程 8 吋（200 mm） |
| **氧化（Oxidation）** | 高溫爐管長二氧化矽 |
| **薄膜沉積（Deposition）** | **CVD / PECVD / PVD 濺鍍 / ALD 原子層沉積**，鋪介電層與金屬層 |
| **微影（Photolithography）** | 塗光阻 → 軟烤 → **曝光（DUV 193 nm 浸潤式 / EUV 13.5 nm）** → 曝後烤 → 顯影。整個製程重複 40~100 次 |
| **蝕刻（Etching）** | 乾式（電漿/RIE）為主，濕式為輔，把圖形轉印到薄膜 |
| **離子佈植 + 退火** | 打入 B / P / As 摻雜形成 source/drain、well；RTA 活化 |
| **CMP 化學機械研磨** | 每層做完把表面磨平，讓下一層微影能對焦 |
| **金屬化（Metallization）** | 銅製程（大馬士革 Damascene）+ low-k 介電，先進節點 15~20 層互連 |
| **保護層（Passivation）** | 蓋 SiN/SiO₂ 保護層，開 pad 窗口 |
| **製程監控** | 逐站量測（膜厚、CD、疊對 overlay）、缺陷檢測、**WAT/PCM 電性測試** |

**FinFET / GAA 補充**：16 nm 以下改用 **FinFET**（立體鰭式），3 nm/2 nm 起改用 **GAA / Nanosheet**，並導入 **背面供電（BSPDN / PowerVia）**。

---

### 步驟 6 — 晶圓測試（Wafer Sort / CP，Chip Probe）

**在切割前，逐一 die 電性測試，把壞的挑出來，避免浪費封裝成本。**

| 項目 | 說明 |
|---|---|
| 設備 | **ATE 測試機（Advantest / Teradyne）+ Prober 探針台 + Probe Card 探針卡** |
| 測試內容 | 開短路測試（Open/Short）、DC 參數、功能測試、掃描鏈（Scan/ATPG）、MBIST 記憶體自我測試 |
| 溫度條件 | 常溫、高溫、低溫（依產品規格） |
| 標記壞 die | 早期用 **Ink Dot 點墨**；現在用 **Electronic Wafer Map（電子晶圓圖）** |
| **良率計算 Yield** | 好 die 數 / 總 die 數。良率是晶圓廠與設計公司最關注的財務指標 |
| 修補（Repair） | 記憶體產品可用備援列/行（redundancy）+ **雷射熔絲或 eFuse** 修補壞 cell 救回良率 |
| **WAT / PCM** | 量測切割道上的測試結構（電晶體 Vt、電阻、電容），監控製程是否漂移 |
| 良率分析 | Bin map 分析、缺陷分佈（edge / center / cluster）回饋至 Fab 改善 |

---

### 步驟 7 — IC 封裝（Assembly / Packaging）

**把裸晶保護起來，並把微米級的 pad 轉接成毫米級可焊接的腳位。**

| 製程步驟 | 說明 |
|---|---|
| 1. **晶圓研磨（Backgrinding）** | 把晶圓背面從 775 μm 磨薄到 50~200 μm（3D 堆疊需更薄） |
| 2. **晶圓切割（Dicing）** | 鑽石刀輪切割或 **雷射隱形切割（Stealth Dicing）** |
| 3. **黏晶（Die Attach）** | 用銀膠 / DAF 膜 / 共晶焊把 die 貼到基板或導線架 |
| 4. **接合（Interconnect）** | **打線 Wire Bond**（金線/銅線，成本低）或 **覆晶 Flip Chip**（C4 bump / Cu pillar，高腳數高效能） |
| 5. **封膠（Molding）** | 環氧樹脂（EMC）壓模成型 |
| 6. **植球 / 電鍍 / 剪切成型** | BGA 植錫球；導線架產品電鍍後 **Trim & Form** 剪切彎腳 |
| 7. **雷射打標（Marking）** | 印上料號、Lot 號、日期碼 |

**封裝型式分類：**

| 類型 | 例子 |
|---|---|
| 傳統 | DIP、SOP、SSOP、QFP、TQFP、QFN、SOT |
| 陣列型 | **BGA、FBGA、LGA、CSP（Chip Scale Package）**、WLCSP |
| **先進封裝** | **SiP 系統級封裝、PoP 堆疊、Fan-Out（InFO）、2.5D（CoWoS + 矽中介層 + HBM）、3D IC（TSV 矽穿孔、SoIC 混合鍵合）、Chiplet 小晶片** |

> **先進封裝已成為後摩爾定律時代的主戰場**——台積電 CoWoS 產能直接決定了全球 AI 加速器（如 NVIDIA GPU）的出貨量。

---

### 步驟 8 — IC 測試（Final Test，FT）

**封裝完成後的成品測試，是出貨前的最後把關。**

| 項目 | 說明 |
|---|---|
| 設備 | **ATE 測試機 + Handler 分類機 + Load Board / Socket** |
| 測試項目 | 開短路、DC 參數（漏電/驅動）、AC 參數（setup/hold/tPD）、功能測試、Scan/ATPG、MBIST、類比參數、RF 測試 |
| **速度分級（Binning）** | 依實測 fMAX 分成不同等級販售（同一片 die 可能被賣成 i5 或 i9） |
| **溫度測試** | 高溫 / 常溫 / 低溫三溫測試，確保全溫度範圍規格 |
| **燒機（Burn-in）** | 高溫高壓加速老化，篩掉早夭品（infant mortality），車規/軍規/醫療必做 |
| **系統級測試（SLT）** | 在近似真實系統的環境中跑實際負載，抓 ATE 抓不到的問題（高階 SoC 越來越依賴） |
| 產出 | 良品 → Tape & Reel / Tray 包裝出貨；不良品分 bin 分析 |

> **CP 與 FT 的差別**：CP 在**切割前、裸晶狀態**測，目的是「不要浪費封裝錢」；FT 在**封裝後**測，目的是「不要出貨不良品給客戶」。

---

### 步驟 9 — IC 功能驗證（Silicon Validation / Bring-up）

**首批晶片回來後，在真實系統中驗證是否符合當初的 Spec——這是「規格 → 矽晶」的閉環。**

| 階段 | 說明 |
|---|---|
| **First Silicon Bring-up** | 在驗證板（EVB / Bring-up board）上上電、量電流、跑最基本的 JTAG 讀 ID、boot ROM |
| **功能驗證** | 逐項對照 Spec 跑功能、跑 OS、跑應用、跑客戶實際場景 |
| **特性化（Characterization）** | 掃描電壓 × 頻率 × 溫度，畫 **Shmoo Plot** 找出真實操作邊界，據此訂 datasheet 規格 |
| **相容性 / 合規測試** | PCIe / USB / HDMI / Ethernet 協定認證，EMI/EMC，安規 |
| **可靠度驗證（Qualification）** | **HTOL**（高溫工作壽命）、**TC**（溫度循環）、**HAST**（高加速應力）、**ESD / Latch-up**、**MSL** 濕氣敏感等級。車規需符合 **AEC-Q100**，並依 **ISO 26262** 做功能安全 |
| **除錯與修正** | 找到 bug 後：能用軟體/韌體 workaround 最好；否則 **Metal-layer ECO（只改上層金屬光罩，便宜）**；再不行只能 **Full re-spin（全部重來，燒錢燒時間）** |
| **量產認證（PRA / Ramp）** | 通過所有驗證後進入量產，同時建立 yield learning 與 outlier 篩選機制 |

---

## 一頁重點總結

1. **PLD 是統稱**，家族由簡到繁：PROM/PLA → PAL（OTP）→ GAL（可抹寫）→ CPLD（非揮發、開機即用）→ FPGA（LUT 架構、規模最大）。
2. **PAL vs GAL 的核心差異只有一個字：可不可以重燒。** PAL 用熔絲（一次性），GAL 用 EEPROM（可重複 100 次以上），架構完全相容。
3. **CPLD vs FPGA 不是「大小」之爭，而是取捨之爭**：CPLD 要的是「非揮發 + 延遲固定 + 便宜」，FPGA 要的是「規模 + RAM + DSP + 高速 I/O」。
4. **PAL / GAL / PLD / CPLD 全部在 MHz 級**；只有 **FPGA 的 SerDes 才進入 GHz 級**，FPGA fabric 本身仍是百 MHz 級。
5. **Standard Cell 不是一顆料，是版圖上的積木**；它的統一高度與共用電源軌，是自動化 P&R 得以存在的前提。
6. **晶圓代工前三強 TSMC / Samsung / SMIC 佔全球代工營收八成以上**，台灣在前十大中佔四席，加上封測（日月光）與矽晶圓（環球晶），構成完整聚落。
7. **IC 流程的閉環邏輯**：Spec 定義「要什麼」→ 設計/模擬/驗證確保「設計正確」→ Fab/CP/封裝/FT 確保「製造正確」→ 最終 Validation 回頭檢查「做出來的東西真的符合當初的 Spec 嗎」。
