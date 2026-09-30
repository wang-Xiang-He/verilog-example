Verilog 硬體描述語言 (II) — 時間與資料輸出 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行
  *_說明.md 範例說明

ModelSim 的詳細操作（腳本 / 手動指令 / 圖形介面）請看 ../week03/ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_Wand_Wor）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  01_Wand_Wor        Wired-AND / Wired-OR，和一般 wire 多重驅動比較（講義第 3~6 頁）
                     檔案：wand_test.v, wor_test.v, wire_test.v, WiredLogic_tb.v
  02_WireReg         wire 與 reg 的使用時機：assign 用 wire、always 用 reg（講義第 7、8、14 頁）
                     檔案：Zero_Detect.v, Add_Reg.v, Add_Wire.v, WireReg_tb.v
  03_Vector_Memory   向量、陣列、記憶體宣告；位元選取與部分選取（講義第 9~12 頁）
                     檔案：Vector_Memory_tb.v
  04_BiDir           雙向接腳 inout 與三態緩衝器 1'bz（講義第 14、15 頁）
                     檔案：BiDir.v, BiDir_tb.v
  05_Scalable        parameter 參數化位元寬度（講義第 17 頁）
                     檔案：ScalableDesign.v, ScalableDesign_tb.v
  06_Always_Edge     always 位準觸發 / 正緣觸發 / 負緣觸發比較（講義第 19、20 頁）
                     檔案：And3_Level.v, And3_Posedge.v, And3_Negedge.v, Always_tb.v
  07_If_Reset        if 敘述：正準位 / 負準位 Reset 暫存器（講義第 21~23 頁）
                     檔案：Reg_RstHigh.v, Reg_RstLow.v, If_Reset_tb.v
  08_Priority_If     if ... else 優先權解碼器，兩種寫法比較（講義第 24~26 頁）
                     檔案：Prio_IfElse.v, Prio_MultiIf.v, Priority_If_tb.v
  09_Demul1_4        1 對 4 解多工器，巢狀 if ... else（範例練習 5-001，講義第 27~29 頁）
                     檔案：demul1_4_if.v, demul1_4_if_tb.v
  10_Case_Casex      case 優先權寫法、case 多工器、casex 不在乎位元（講義第 30~33 頁）
                     檔案：Case_Prio.v, Mux_Case.v, Casex_Prio.v, Case_tb.v
  11_Casez           casez 範例（講義第 34~36 頁）
                     檔案：casez_machine.v, casez_machine_tb.v
  12_TwosComp        8 位元 2 的補數，casex 實作（講義第 37~39 頁）
                     檔案：TwosComp.v, TwosComp_tb.v
  13_For_Loop        for 迴圈與編譯時展開（講義第 41、42 頁）
                     檔案：For_XOR.v, For_XOR_tb.v
  14_Bin2Gray        8 位元二進制碼轉格雷碼，for 迴圈（範例練習 5-003，講義第 43~45 頁）
                     檔案：bin2gra.v, bin2gra_tb.v
  15_Forever_While   forever 產生時脈 + disable 停止、while 迴圈（講義第 46 頁）
                     檔案：Forever_While_tb.v
  16_Repeat_1s       repeat 迴圈計算位元組中 1 的個數（範例練習 5-004，講義第 47~49 頁）
                     檔案：repeat_1s.v, repeat_1s_tb.v
  17_BCDadder4       四位元 BCD 加法器（範例練習 5-005，講義第 50~53 頁）
                     檔案：adder4.v, BCDadder4.v, BCDadder4_tb.v

與講義不同之處：
  - 所有電路模組的埠宣告改用 Verilog-2001（ANSI）寫法，埠順序不變，功能相同
  - 有 parameter 的模組改寫成 module 名稱 #(parameter ...) (...) 的形式
  - 組合邏輯 always 的敏感清單改用 @(*)（講義手動列出，而且 08、10 有漏列的訊號）
  - 正反器 / 暫存器 / 時脈觸發的 always 區塊改用非阻隔式賦值 <=（講義用 =）
  - 03：講義第 9 頁 wire bus [15:0]; reg Result [31:0]; 寫成了陣列，改成向量 wire [15:0] bus;
  - 04：講義第 15 頁是 SpDE 合成後的等效式，改用標準的三態寫法 enable ? data : 1'bz
  - 10：Mux_Case 補上講義漏掉的 2'b10 項目（否則會合成出 Latch）
  - 13：講義 c = (a[i] | b[i]) & c; 沒有給 c 初值（c 用到自己的舊值 → 迴授），這裡先設 c = 1
  - 16：測試平台改用講義第 48 頁模擬結果的 9 筆資料（原本從 0 數到 255，輸出太長）
  - 17：講義沒有列出 adder4，依方塊圖自行補上；測試平台改為 200 筆合法 BCD 輸入自動檢查
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
