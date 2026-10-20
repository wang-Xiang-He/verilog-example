Verilog 硬體描述語言 — 自定邏輯 (UDP) 與組合邏輯電路 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行
  *_說明.md 範例說明

ModelSim 的詳細操作（腳本 / 手動指令 / 圖形介面）請看 ../week03/ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_Mux4_UDP）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  【自定邏輯電路 UDP】
  01_Mux4_UDP        自定組合邏輯 mux2_1pr，3 顆組成 4 對 1 多工器 mux4_1pr（範例練習 8-001，講義第 1~6 頁）
                     檔案：mux2_1pr.v, mux4_1pr.v, mux4_1pr_tb.v
  02_DFF_UDP         自定序向邏輯：邊緣觸發 D 型正反器 DFF_pr（講義第 11~13 頁）
                     檔案：DFF_pr.v, DFF_pr_tb.v
  03_JKFF_UDP        自定序向邏輯：具重置的準位觸發 JK 正反器 JKF_pr（講義第 7~10 頁）
                     檔案：JKF_pr.v, JKF_pr_tb.v

  【組合邏輯電路】
  04_Encoder1        8 對 3 優先權編碼器，for 迴圈 + 具名區塊（講義第 14~17 頁）
                     檔案：Encoder1.v, Encoder1_tb.v
  05_Encoder2_3      優先權編碼器：assign 巢狀 ? : 寫法與 if ... else if 寫法（講義第 18~22 頁）
                     檔案：Encoder2.v, Encoder3.v, Encoder2_3_tb.v
  06_Decoder3to8     3 對 8 解碼器，低態致能、低態輸出，case 寫法（講義第 23~27 頁）
                     檔案：Decoder_3to8.v, Decoder_3to8_tb.v
  07_Mux2to1_4Ways   2 對 1 多工器的 4 種寫法：if、assign、if 含 x、case 含 default（講義第 28~36 頁）
                     檔案：Mux2to1_1.v, Mux2to1_2.v, Mux2to1_3.v, Mux2to1_4.v, Mux2to1_tb.v
  08_Mux4to1         4 對 1 多工器，case 寫法（講義第 37~39 頁）
                     檔案：Mux4to1_1.v, Mux4to1_1_tb.v
  09_Mux4_By_Mux2E   兩個具致能的 2 對 1 多工器擴充成 4 對 1（講義第 40~43 頁）
                     檔案：Mux2to1E.v, Mux4x1_By_Mux2to1E.v, Mux4x1_By_Mux2to1E_tb.v
                     ※ Mux2to1E.v 由 `include 帶入，vlog 不列
  10_DeMux1x2        1 對 2 解多工器：assign 與 if ... else（講義第 44~48 頁）
                     檔案：DeMux1X2_1.v, DeMux1X2_2.v, DeMux1X2_tb.v
  11_DeMux1x4        1 對 4 解多工器：assign 與 if ... else（講義第 49~51 頁）
                     檔案：DeMux1X4_1.v, DeMux1X4_2.v, DeMux1X4_tb.v
  12_DeMux1x4_By_1x2E 兩個具致能的 1 對 2 解多工器擴充成 1 對 4（講義第 52~57 頁）
                     檔案：DeMux1to2E.v, DeMux1x4_By_DeMux1to2E.v, DeMux1x4_By_DeMux1to2E_tb.v
                     ※ DeMux1to2E.v 由 `include 帶入，vlog 不列
  13_Comparator      同步 8 位元比較器 AGTB / AEQB / ALTB（講義第 58~60 頁）
                     檔案：Comparator.v, Comparator_tb.v
  14_Accumulator     16 位元累加器，非同步重置（講義第 61~63 頁）
                     檔案：Accumulator.v, Accumulator_tb.v

與講義不同之處：
  - 所有電路模組的埠宣告改用 Verilog-2001（ANSI）寫法，埠順序不變，功能相同
    （UDP 的 primitive 保留講義的寫法，說明檔裡有 Verilog-2001 的寫法）
  - 有 parameter 的模組改寫成 module 名稱 #(parameter ...) (...) 的形式
  - 組合邏輯 always 的敏感清單改用 @(*)（講義手動列出）
  - 時脈觸發的 always 區塊改用非阻隔式賦值 <=（講義用 =）
  - 01：講義第 4 頁的 UDP 依名稱連接（.Y(Y1) ...）在 ModelSim 載入時會 Fatal（vsim-3367），改用第 5 頁的依順序連接
  - 01~03：講義的 testbench 用 `timescale 1ps/1ps、#1 時脈；改成 1ns、時脈週期 10ns，輸出比較短
  - 02：DFF_pr 真值表補上 (??) ? : ? : - ;（D 改變時 Q 不變），否則 D 一變 Q 就變成 x
  - 02：講義第 11 頁的 ? (??) : ? : - ; 和 (01) 列衝突（編譯錯誤），依第 12 頁改成 ? (1?) : ? : - ;
  - 03：JKF_pr 補上 initial Q = 1'b0;（講義第 7 頁有提到但程式沒寫）；JK=10 的註解改為 set to 1
  - 06：Decoder_3to8 補上 default（A 有 x 時輸出 x）
  - 07、08：case 補上 default；第 29 頁的真值表（Select=0→a）和程式（Select=1→a）相反，以程式為準
  - 09：Mux2to1E 不致能時輸出 0（講義第 42 頁：「有誤？修正為 0 即可」）
  - 09、12：`include 的檔名和模組名稱一致（講義為 Mux2to1E.V、DeM1to2E.V）
  - 11：講義第 51 頁的模組名稱 DeMux1x4_1 和範例 1 重複，改為 DeMux1X4_2
  - 14：講義第 61 頁方塊圖寫 8 位元，程式是 16 位元，以程式為準
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
