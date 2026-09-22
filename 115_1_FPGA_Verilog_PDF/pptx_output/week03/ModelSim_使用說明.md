# ModelSim 使用說明

ModelSim 有三種操作方式，做的事情完全一樣，差別只在「怎麼下命令」：

| 方式 | 適合 | 做法 |
|---|---|---|
| A. 腳本（`run.do`） | 範例跑很多次、只想快速看結果 | 輸入一行 `do run.do` |
| B. 手動輸入指令 | 想知道每一步在做什麼、改程式後快速重跑 | 在 Transcript 視窗一行一行輸入 |
| C. 圖形介面（GUI，Graphical User Interface） | 課堂上老師示範的方式、不想記指令 | 用滑鼠點選單 |

不論哪一種，流程都是這 5 步：

```
建立工作庫 → 編譯 → 載入模擬 → 加入波形 → 執行
 vlib        vlog    vsim       add wave    run
```

---

## 開始前：資料夾路徑

ModelSim 對**中文、空白**的路徑支援不好，常見錯誤是找不到檔案或無法建立工作庫。建議把 zip 解壓縮到像這樣的位置：

```
C:/verilog/Verilog_CH02_Examples/01_FullAdd
```

⚠️ 在 ModelSim 裡寫路徑要用 **斜線 `/`**，不要用 Windows 的反斜線 `\`（ModelSim 的指令語言 Tcl 會把 `\` 當成跳脫字元）。

---

## ModelSim 的視窗介紹

| 視窗 | 用途 |
|---|---|
| **Transcript**（最下方） | 輸入指令、顯示編譯訊息與 `$display` / `$monitor` 的文字輸出。輸出的每一行前面會多一個 `#` 號 |
| **Library** | 列出工作庫 `work` 裡已經編譯好的模組 |
| **Project** | 使用專案模式時才會出現，列出專案裡的檔案和編譯狀態 |
| **sim**（Structure） | 載入模擬後出現，顯示模組的階層結構（testbench → uut → 子模組） |
| **Objects** | 在 sim 視窗點選某個模組後，列出該模組內的訊號 |
| **Wave** | 波形視窗 |

找不到某個視窗時，從選單 **View** 打開。

---

## 方式 A：用腳本 `run.do`

### run.do 是什麼

`run.do` 是我預先幫每個範例寫好的 **DO 檔**（ModelSim 的指令腳本）。它就是把「方式 B」要手動輸入的指令，照順序存成一個文字檔。ModelSim 的指令語言是 Tcl（Tool Command Language，一種腳本語言），所以 DO 檔其實就是 Tcl 腳本。

以 `01_FullAdd/run.do` 為例（← 後面是說明，不在檔案裡）：

```tcl
# run.do : ModelSim script for 01_FullAdd        ← # 開頭是註解
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work                                   ← 1. 建立工作庫
vlog FullAdd.v FullAdd_tb.v                 ← 2. 編譯
vsim -voptargs=+acc work.FullAdd_tb         ← 3. 載入模擬
add wave -r /*                              ← 4. 加入所有訊號到波形視窗
run -all                                    ← 5. 執行到 $stop 為止
```

每一行的意思在下面「方式 B」有詳細說明。

### 使用步驟

1. 開啟 ModelSim。
2. 切換到範例資料夾，兩種方式擇一：
   - 選單 **File > Change Directory...**，選 `01_FullAdd` 資料夾
   - 或在 Transcript 輸入：
     ```tcl
     cd C:/verilog/Verilog_CH02_Examples/01_FullAdd
     ```
3. 在 Transcript 輸入：
   ```tcl
   do run.do
   ```
   也可以用選單 **Tools > Tcl > Execute Macro...** 選 `run.do`，效果相同。
4. 波形視窗會跳出來、Transcript 會印出結果，然後停在 `$stop`。
5. 看完輸入 `quit -sim` 結束模擬，再換下一個資料夾。

### 改了程式碼之後

先結束目前的模擬，再重跑腳本：

```tcl
quit -sim
do run.do
```

> 不先 `quit -sim` 的話，ModelSim 會跳出視窗問你「是否結束目前的模擬」，按「是」也可以。

### 自己寫一個 DO 檔

用任何文字編輯器新增一個副檔名為 `.do` 的檔案，把要輸入的指令逐行寫進去即可。常用的額外指令：

```tcl
add wave -radix unsigned /FullAdd4_tb/Sum   ;# 這個訊號用十進位（無號數）顯示
wave zoom full                              ;# 波形縮放到剛好看到全部
```

> ⚠️ DO 檔裡建議只用英文。中文註解在某些 ModelSim 版本會造成讀檔錯誤，所以 `run.do` 裡的說明都寫成英文。

---

## 方式 B：手動輸入指令（沒有腳本時）

先 `cd` 到範例資料夾（同方式 A 的步驟 2），然後在 Transcript 逐行輸入：

### 0. 建立工作庫

```tcl
vlib work
```

- `vlib` = Verilog library。建立一個叫 `work` 的資料夾，存放編譯後的結果。
- 同一個資料夾只需要建一次，再輸入會出現「已存在」的警告，可以忽略。

### 1. 編譯

```tcl
vlog FullAdd.v FullAdd_tb.v
```

- `vlog` = Verilog compile。把列出的 `.v` 檔編譯進 `work` 工作庫。
- **有用到的模組都要編譯**。例如 `02_FullAdd4` 要：
  ```tcl
  vlog FullAdd.v FullAdd4.v FullAdd4_tb.v
  ```
- 懶得列檔名時，可以用萬用字元一次編譯資料夾裡全部的 `.v` 檔：
  ```tcl
  vlog *.v
  ```
- 成功會顯示 `Errors: 0, Warnings: 0`。有錯誤時會顯示紅字和行號，**在紅字上點兩下**會直接跳到出錯的那一行。

### 2. 載入模擬

```tcl
vsim -voptargs=+acc work.FullAdd_tb
```

- `vsim` = Verilog simulate。`work.FullAdd_tb` 表示載入 `work` 工作庫裡的 `FullAdd_tb` 模組。
- **要載入的是 testbench**（最上層模組），不是電路本身。
- `-voptargs=+acc`：`vopt` 是 ModelSim 的最佳化器（optimizer），`+acc`（access）要求它保留所有訊號。沒加的話，新版 ModelSim 會把訊號最佳化掉，波形視窗可能加不進訊號。
  - 如果你的版本出現「不認得這個參數」的錯誤，改成 `vsim work.FullAdd_tb` 即可。

### 3. 加入波形

```tcl
add wave -r /*
```

- `-r` = recursive（遞迴），`/*` = 從最上層開始的所有訊號。等於把 testbench 和所有子模組的訊號全部加進 Wave 視窗。
- 只想看 testbench 那一層：
  ```tcl
  add wave /FullAdd_tb/*
  ```
- 只看特定訊號：
  ```tcl
  add wave /FullAdd_tb/a /FullAdd_tb/Sum
  ```

### 4. 執行

```tcl
run -all
```

- 一直跑到 `$stop` 或 `$finish` 為止。
- 也可以指定時間，例如 `run 30ns`（只跑 30 奈秒），可以一段一段往前跑。
- 只輸入 `run` 會跑預設的長度（通常是 100ns）。

### 5. 重跑或結束

| 指令 | 作用 |
|---|---|
| `restart -f` | 把時間倒回 0，波形清空，但保留已加入的訊號（`-f` = force，不詢問） |
| `quit -sim` | 結束這次模擬（ModelSim 不會關閉） |
| `quit` | 關閉 ModelSim |

### 改程式碼後最快的重跑方式

不需要全部重來，只要重新編譯修改過的檔案，再倒回重跑：

```tcl
vlog FullAdd.v
restart -f
run -all
```

### 常用指令一覽

| 指令 | 作用 |
|---|---|
| `pwd` | 顯示目前所在的資料夾 |
| `cd 路徑` | 切換資料夾 |
| `ls` 或 `dir` | 列出資料夾內的檔案 |
| `vlib work` | 建立工作庫 |
| `vlog 檔案.v ...` | 編譯 |
| `vsim -voptargs=+acc work.模組名` | 載入模擬 |
| `add wave -r /*` | 加入所有訊號到波形 |
| `run -all` / `run 100ns` | 執行 |
| `restart -f` | 倒回時間 0 |
| `quit -sim` | 結束模擬 |
| `do 檔案.do` | 執行腳本 |
| 鍵盤 ↑ | 叫出上一個輸入過的指令 |

---

## 方式 C：用圖形介面（GUI）

GUI 有兩種用法：**不建專案**（簡單，每個範例資料夾直接用）和**建專案**（課堂上常見，檔案管理比較清楚）。

### C-1. 不建專案

1. **切換資料夾**：**File > Change Directory...** → 選範例資料夾。
2. **建立工作庫**：**File > New > Library...** → 選「a new library and a logical mapping to it」，Library Name 填 `work` → **OK**。
3. **編譯**：**Compile > Compile...**
   - 在檔案清單中**全選**所有 `.v` 檔（按住 Ctrl 點選，或 Ctrl + A）
   - 按 **Compile**，完成後按 **Done**
   - 若跳出「Library work does not exist. Create?」→ 按 **Yes**（等於步驟 2）
4. **載入模擬**：**Simulate > Start Simulation...**
   - **Design** 分頁 → 展開 `work` → 點選 testbench，例如 `FullAdd_tb`
   - 視窗下方的 **Optimization** 區塊：取消勾選 **Enable optimization**；
     或按 **Optimization Options...** → 勾選 **Apply full visibility to all modules (full debug mode)**
     （這兩個選項等於指令的 `-voptargs=+acc`，不同版本會出現其中一個）
   - 按 **OK**
5. **加入波形**：在 **sim** 視窗的 `FullAdd_tb` 上**按右鍵 > Add Wave**（或 **Add to > Wave > All items in region and below**，會連子模組一起加入）。
6. **執行**：工具列上的按鈕（滑鼠停在圖示上會顯示名稱）：
   | 按鈕 | 等於指令 |
   |---|---|
   | **Run -All** | `run -all` |
   | **Run**（旁邊的欄位可以填時間，例如 `100 ns`） | `run 100ns` |
   | **Restart** | `restart` |
   | **Break** | 中斷正在跑的模擬（例如忘了寫 `$stop` 時） |
7. **結束**：**Simulate > End Simulation**。

### C-2. 建專案（Project）

1. **File > New > Project...**
   - Project Name：例如 `FullAdd`
   - Project Location：選範例資料夾
   - Default Library Name：保持 `work`
   - 按 **OK**
2. 跳出「Add items to the Project」視窗 → 點 **Add Existing File** → **Browse** 全選資料夾裡的 `.v` 檔 → **OK** → **Close**。
3. **Compile > Compile All**。
   - Project 視窗每個檔案後面的 **?** 會變成綠色 **✓**（成功）或紅色 **✗**（失敗）。
   - 失敗時到 Transcript 找紅字，點兩下跳到錯誤行。
4. 之後同 C-1 的步驟 4~7（載入模擬 → 加入波形 → 執行 → 結束）。
5. 下次要用：**File > Open > Project...**，或從 **File > Recent Projects** 選。

### 波形視窗常用操作

| 操作 | 方法 |
|---|---|
| 縮放到看到全部波形 | 工具列 **Zoom Full**，或在波形區按 **F** 鍵 |
| 放大 / 縮小 | 工具列放大鏡圖示，或按 **I**（in）/ **O**（out） |
| 查看某個時間點的值 | 在波形上點一下，出現黃色游標（cursor），左邊會顯示該時間點每個訊號的值 |
| 改變數值顯示方式 | 訊號名稱上**按右鍵 > Radix** → Binary（二進位）/ Unsigned（無號十進位）/ Decimal（有號十進位）/ Hexadecimal（十六進位） |
| 展開向量的每個位元 | 點訊號名稱左邊的 **+** |
| 把波形視窗獨立出來放大 | 波形視窗右上角的 **Dock / Undock** 按鈕 |
| 另存波形設定 | **File > Save Format...** 存成 `wave.do`，下次 `do wave.do` 就能加回同樣的訊號 |

---

## 三種方式對照

| 步驟 | 腳本 | 指令 | 選單 |
|---|---|---|---|
| 切換資料夾 | （手動先做） | `cd 路徑` | File > Change Directory |
| 建工作庫 | `run.do` 第 1 個指令 | `vlib work` | File > New > Library |
| 編譯 | `run.do` 第 2 個指令 | `vlog *.v` | Compile > Compile... |
| 載入模擬 | `run.do` 第 3 個指令 | `vsim -voptargs=+acc work.XXX_tb` | Simulate > Start Simulation |
| 加波形 | `run.do` 第 4 個指令 | `add wave -r /*` | sim 視窗右鍵 > Add Wave |
| 執行 | `run.do` 第 5 個指令 | `run -all` | Run -All 按鈕 |
| 結束 | — | `quit -sim` | Simulate > End Simulation |

---

## 常見狀況

| 狀況 | 原因與處理 |
|---|---|
| 執行到 `$stop` 後跳出一個程式碼視窗，游標停在 `$stop` 那一行 | 正常。這是 ModelSim 在告訴你模擬暫停的位置，波形和結果都在 |
| `Module 'FullAdd' is not defined` 或 `Instantiation of 'xxx' failed` | 用到的子模組沒有一起編譯。用 `vlog *.v` 全部編譯 |
| `vsim` 找不到 `work.xxx_tb` | 模組名稱打錯，或還沒編譯 testbench。看 Library 視窗 `work` 底下有哪些名稱 |
| Wave 視窗加不進訊號或是空的 | 載入模擬時沒加 `-voptargs=+acc`（或 GUI 沒關掉最佳化） |
| 模擬一直跑、停不下來 | testbench 沒寫 `$stop`，而且有 `always` 產生的時脈會無限執行。按 **Break** 中斷，再到 testbench 補上 `$stop` |
| 用 `$finish` 時跳出「Are you sure you want to finish?」 | 按「否」可以留在 ModelSim 看波形；按「是」會關閉 ModelSim。所以範例都改用 `$stop` |
| 中文註解顯示亂碼 | 檔案是 UTF-8 編碼，ModelSim 內建編輯器可能不支援。**不影響編譯**，改用 VS Code 或 Notepad++ 閱讀 |
| `Unable to create directory` 或找不到檔案 | 路徑有中文或空白，搬到 `C:/verilog/...` 這類純英文路徑 |
| 輸出的時間是 `10000` 而不是 `10` | 在 `` `timescale 1ns/1ps `` 下，`%t` 會用最小精度 1ps 顯示。範例都改用 `%0d` 印 `$time`，顯示的就是 ns |
