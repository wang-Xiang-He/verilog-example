# ModelSim 波形與操作筆記

> 環境：ModelSim - Intel FPGA Starter Edition 2020.1
> 以 `02_FullAdd4`（4 位元漣波進位加法器）的模擬畫面為例

---

## 1. Wave 視窗的組成

```
┌──────────────────┬────────┬──────────────────────────────┐
│ 訊號名稱         │ 數值欄 │ 波形區（黑底）                │
│ /FullAdd4_tb/a   │ 1111   │ ▔▔▔▔\____/▔▔▔▔▔▔▔▔           │
│ ...              │ ...    │                              │
├──────────────────┼────────┼──────────────────────────────┤
│ Now              │60000 ps│ 時間軸 0 ps ... 60000 ps      │
│ Cursor 1         │  0 ps  │                              │
└──────────────────┴────────┴──────────────────────────────┘
```

| 區域 | 用途 |
|---|---|
| **訊號名稱** | 顯示完整的階層路徑，例如 `/FullAdd4_tb/uut/fa0/Sum` |
| **數值欄（標題寫 Msgs）** | 顯示每個訊號在「某個時間點」的值，見第 2 節 |
| **波形區** | 綠線是 1 位元訊號；有數字的長條是多位元向量，數字變化處就是值改變的時間點 |
| **Now** | 模擬目前跑到的時間。停在 `$stop` 時就是 `$stop` 被執行的時間 |
| **Cursor 1** | 黃色游標所在的時間 |

---

## 2. 數值欄（Values / Msgs）

顯示每個訊號在**某個時間點**的值：

- 在波形上點一下，放了**黃色游標（Cursor）** → 顯示**游標所在時間**的值
- 還沒點游標 → 顯示模擬**目前時間（Now）**的值

**用法**：在波形上點一下或拖動游標，數值欄就會跟著變，可以逐段檢查每一組輸入的結果。

### 範例：游標在 59,633 ps 時

游標在約 59.6 ns，對應 `01_FullAdd` 的 t=50 那組輸入：

| 訊號 | 值 | 說明 |
|---|---|---|
| a | 1 | |
| b | 0 | |
| Carry_In | 1 | |
| Sum | St0 | 1 + 0 + 1 = 2 = 二進位 `10`，低位元 = 0 |
| Carry_Out | St1 | 高位元 = 1 |

---

## 3. 數值的寫法：`1` 和 `St1` 有什麼不同

值的顯示方式和訊號的**型態**有關：

| 顯示 | 型態 | 意思 |
|---|---|---|
| `0`、`1` | **reg**（變數） | 只有數值，沒有驅動強度 |
| `x` | reg | 未知值（unknown），通常是還沒被賦值 |
| `St0`、`St1` | **wire**（線） | St = **Strong（強驅動）**。這條線被邏輯閘或 `assign` 以正常強度驅動成 0 或 1。最常見 |
| `StX` | wire | 強驅動的未知值。通常是兩個來源互相衝突，或輸入本身是 x |
| `HiZ` | wire | 高阻抗（High impedance，即 `z`），沒有任何東西在驅動這條線 |
| `1111`、`11111` | 多位元向量 | 向量只顯示數值，不顯示強度 |

> 其他強度（較少見）：`Pu` = Pull（上拉 / 下拉）、`We` = Weak（弱驅動）、`Su` = Supply（電源）。

### 對照講義的規則

同一條線在不同位置，顯示方式可能不一樣：

| 訊號 | 顯示 | 原因 |
|---|---|---|
| `FullAdd4_tb/Carry_In` | `1` | testbench 裡宣告成 `reg`（要在 `initial` 裡被賦值） |
| `FullAdd4_tb/uut/Carry_In` | `St1` | 進到模組後是 `input`，而 **input 一定是 wire** |

---

## 4. 為什麼 `do run.do` 的波形那麼多條

`run.do` 裡加入波形的指令是：

```tcl
add wave -r /*
```

`-r` = **recursive（遞迴）**，會把 testbench 以及**底下所有子模組**的訊號全部加進來。

### FullAdd4 的階層

```
FullAdd4_tb         ← a, b, Carry_In, Sum, Carry_Out, total          (6 條)
 └ uut (FullAdd4)   ← a, b, Carry_In, Sum, Carry_Out, Carry_Out1~3   (8 條)
    ├ fa0 (FullAdd) ← a, b, Carry_In, Sum, Carry_Out                 (5 條)
    ├ fa1           ← 5 條
    ├ fa2           ← 5 條
    └ fa3           ← 5 條
                                                             合計 34 條
```

很多其實是**同一條線在不同階層的名字**，例如 `FullAdd4_tb/a` 和 `FullAdd4_tb/uut/a` 是同一條線。

### 數值欄每一列的意思（FullAdd4，Now = 60 ns，最後一組 1111 + 1111 + 1）

| 列 | 訊號 | 值 | 意思 |
|---|---|---|---|
| 1 | `FullAdd4_tb/a` | 1111 | 輸入 a = 15 |
| 2 | `FullAdd4_tb/b` | 1111 | 輸入 b = 15 |
| 3 | `FullAdd4_tb/Carry_In` | 1 | 進位輸入 = 1 |
| 4 | `FullAdd4_tb/Sum` | 1111 | 和（低 4 位元） |
| 5 | `FullAdd4_tb/Carry_Out` | St1 | 進位輸出 = 1 |
| 6 | `FullAdd4_tb/total` | 11111 | {Carry_Out, Sum} = 31 |
| 7~11 | `uut/a`、`b`、`Carry_In`、`Sum`、`Carry_Out` | 同上 | FullAdd4 內部看到的同一組線 |
| 12~14 | `uut/Carry_Out1~3` | St1 | fa0→fa1、fa1→fa2、fa2→fa3 之間的進位線 |
| 15 以下 | `uut/fa0~fa3` 的 `a`、`b`、`Carry_In`、`Sum`、`Carry_Out` | St1 | 4 個 1 位元全加器的內部訊號。最後一組每個位元都是 1+1+1，所以全部是 1 |

### 控制要加入多少訊號

| 做法 | 加入的訊號 |
|---|---|
| `add wave -r /*` | 全部階層（run.do 預設） |
| `add wave /FullAdd4_tb/*` | 只有 testbench 那一層 |
| `add wave /FullAdd4_tb/a /FullAdd4_tb/Sum` | 只有指定的訊號 |
| GUI：sim 視窗在 `FullAdd4_tb` 上按右鍵 > **Add Wave** | 只有那一層 |
| GUI：右鍵 > **Add to > Wave > All items in region and below** | 那一層加上所有子模組 |
| 在 Wave 視窗選取訊號 → 按 **Delete** | 從波形視窗移除（不影響電路） |

**遞迴加入的好處**：在多層設計（例如 `03_Hierar`）可以同時看到每一級的輸出。在 FullAdd4 可以看到 `Carry_Out1~3` 一級一級往上傳，也就是「漣波（Ripple）」這個名稱的由來。

---

## 5. 波形的縮放與顯示

### 波形看起來只有平的直線？

通常是**放大到很小的一段時間**，而那段時間訊號剛好沒變化。先看下方時間軸的範圍，例如 77,600 ~ 80,000 ps 只有 2.4 ns。

**Zoom Full（縮放到看見全部）**，三種方式擇一：
- 在黑色波形區**點一下**（讓視窗取得焦點），再按鍵盤 **F**
- 選單 **Wave > Zoom > Zoom Full**
- 工具列放大鏡圖示中的 Zoom Full

### 常用操作

| 操作 | 方法 |
|---|---|
| 縮放到看見全部 | **F** |
| 放大 / 縮小 | **I**（in）/ **O**（out），或工具列放大鏡 |
| 看某個時間點的值 | 在波形上點一下，黃色游標移過去，看數值欄 |
| 改成十進位顯示 | 訊號名稱上按右鍵 > **Radix** > **Unsigned**（無號）/ **Decimal**（有號）；另有 Binary（二進位）、Hexadecimal（十六進位） |
| 展開向量的每個位元 | 點訊號名稱左邊的 **+** |
| 切回波形視窗 | 畫面下方的 **Wave** 分頁 |

---

## 6. 執行按鈕與 Run Length

工具列上有一個寫著 `0 ps`（或 `100 ps`）的輸入框，右邊依序是 5 個按鈕：

```
[Restart]  [ 0 ps ▲▼ ]  [Run]  [Continue]  [Run -All]  [✗ Break]  [● Stop]
```

| 元件 | 用途 | 等於指令 |
|---|---|---|
| **Restart** | 時間倒回 0，波形清空，已加入的訊號保留 | `restart -f` |
| **Run Length 輸入框** | 設定每按一次 **Run** 要跑多久 | — |
| **Run** | 往前跑 Run Length 設定的時間 | `run 10ns` |
| **Continue** | 從暫停處繼續跑 | `run -continue` |
| **Run -All** | 一路跑到 `$stop` / `$finish`（**不看** Run Length） | `run -all` |
| **Break** | 中斷正在跑的模擬（例如忘了寫 `$stop`） | — |

> 圖示很像，把滑鼠停在圖示上會顯示名稱。

### 一組一組慢慢看

1. Run Length 輸入 `10 ns`
2. 按 **Restart**
3. 每按一次 **Run** → 前進 10 ns = testbench 裡的一組輸入（`#10`）
4. 同時觀察 Transcript 多印出的那一行、波形多出的那一段

---

## 7. 重跑模擬

### 程式沒改，只想從頭再跑

| GUI | 指令 |
|---|---|
| **Restart** → **OK** → **Run -All** | `restart -f` 然後 `run -all` |

### 改了 `.v` 程式碼

**一定要先重新編譯**，否則跑的還是舊版本。

1. 用 VS Code / Notepad++ 修改並存檔
2. 重新編譯：**Compile > Compile...** 選改過的檔案；或 **Library** 分頁 → `work` → 模組上按右鍵 > **Recompile**
3. **Restart** → **OK**
4. **Run -All**

指令版：

```tcl
vlog FullAdd.v        ;# 或 vlog *.v 全部重新編譯
restart -f
run -all
```

### 需要整個重來的情況

改了模組的**埠**（新增或刪除 input / output）時，只按 Restart 可能出錯，要：

| GUI | 指令 |
|---|---|
| **Simulate > End Simulation** → 重新 **Start Simulation** | `quit -sim` 然後 `do run.do` |

---

## 8. 換到下一個範例

1. **Simulate > End Simulation**（先結束目前的模擬）
2. **File > Change Directory...** → 選下一個範例資料夾
3. **Compile > Compile...** → **全選**資料夾裡的 `.v` 檔 → Compile → 出現「Library work does not exist」按 **Yes** → **Done**
4. **Simulate > Start Simulation...** → `work` → 選 **`xxx_tb`** → **取消勾選 Enable optimization** → OK
5. sim 視窗在 testbench 上按右鍵 > **Add Wave**
6. **Run -All** → 波形區點一下按 **F**

指令版：

```tcl
quit -sim
cd ../02_FullAdd4
do run.do
```

> ⚠️ 有用到的子模組都要一起編譯。例如 FullAdd4 由 4 個 FullAdd 組成，少編譯 `FullAdd.v` 會出現 `Module 'FullAdd' is not defined`。

---

## 9. 工作庫 `work`

`work` 是一個**真的資料夾**，建立在編譯時所在的目錄底下，存放編譯好的模組：

```
01_FullAdd/work     ← FullAdd、FullAdd_tb
02_FullAdd4/work    ← FullAdd、FullAdd4、FullAdd4_tb
```

| 問題 | 答案 |
|---|---|
| 換範例要不要刪舊的 `work`？ | **不用**。ModelSim 只使用目前資料夾底下的 `work`，其他資料夾的放著不影響，下次回來還能直接用 |
| 同一個 `work` 重複編譯會怎樣？ | 同名模組會被**最新一次的編譯覆蓋** |
| 刪掉 `.v` 裡的某個模組呢？ | 舊的編譯結果還會留在 `work` 裡，通常無害，只是 Library 清單會多出舊東西 |
| 什麼時候該刪掉重來？ | 遇到改了程式卻好像沒生效的怪錯誤，或想清乾淨 Library 清單時 |
| 刪除注意事項 | 先 **End Simulation** 再刪。模擬執行中檔案被佔用，可能刪不掉 |

---

## 10. 其他常見狀況

| 狀況 | 說明 |
|---|---|
| 跑完後跳出程式碼視窗，第 N 行左邊有藍色箭頭 | 正常，表示模擬停在 `$stop` 那一行。波形和結果都保留 |
| 中文註解變成亂碼 | 檔案是 UTF-8，ModelSim 內建編輯器用西歐字元（Latin-1）解讀。**只影響顯示，不影響編譯和模擬**。改用 VS Code / Notepad++ 閱讀和修改 |
| 看不到 `$monitor` 印出的文字 | 選單 **View > Transcript** 打開 Transcript 視窗 |
| Transcript 每行前面有 `#` | ModelSim 的輸出格式，正常 |
| Wave 視窗加不進訊號 | Start Simulation 時沒取消 **Enable optimization**（指令版要加 `-voptargs=+acc`）。成功時 sim 視窗的 Visibility 欄會顯示 `+acc=...` |
