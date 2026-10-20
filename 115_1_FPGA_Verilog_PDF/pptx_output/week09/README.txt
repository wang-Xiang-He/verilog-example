Verilog 硬體描述語言 — 循序邏輯電路（Sequential State） 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行
  *_說明.md 範例說明

ModelSim 的詳細操作（腳本 / 手動指令 / 圖形介面）請看 ../week03/ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_Latch_RS）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  【閂鎖與正反器】
  01_Latch_RS        具重置、設定、致能的 D 型閂鎖，assign 迴授（講義第 1、2 頁）
                     檔案：Latch_RS.v, Latch_RS_tb.v
  02_DFF_RS          具重置、設定的 D 型正反器 + 除 2 功能（講義第 3~6 頁）
                     檔案：DFF_RS.v, DFF_RS_tb.v
  03_Enable_FF       具致能的正反器 + 除 2 功能（講義第 7、8 頁）
                     檔案：Enable_FF1.v, Enable_FF1_tb.v
  04_DFF_PR          非同步重置與預設的 D 型正反器（講義第 9、10 頁）
                     檔案：D_FF_PR.v, D_FF_PR_tb.v
  05_DFF_SR          同步重置的 D 型正反器（講義第 11、12 頁）
                     檔案：D_FF_SR.v, D_FF_SR_tb.v

  【暫存器與移位暫存器】
  06_Reg16           具清除訊號的 16 位元「暫存器」（其實是組合邏輯）（講義第 13、14 頁）
                     檔案：Reg_16.v, Reg_16_tb.v
  07_Reg4_Async_Sync 非同步 / 同步重置的 4 位元暫存器比較（講義第 15~18 頁）
                     檔案：RAS_NRPC.v, RS_NRPC.v, Reg4_tb.v
  08_SISO            串進串出移位暫存器，兩種寫法（講義第 19~24 頁）
                     檔案：SISO_Shift_Register.v, SISO_Shift_Register_For.v, SISO_tb.v
  09_SIPO            串進並出移位暫存器，含附錄的 temp 版本（講義第 25~28 頁）
                     檔案：SIPO_Shift_Register.v, SIPO_Shift_Register_1.v, SIPO_tb.v
  10_PISO            並進串出移位暫存器（講義第 29~32 頁）
                     檔案：PISO_Shift_Register.v, PISO_tb.v
  11_PIPO            並進並出暫存器，原版與講義的兩個修改版（講義第 33~39 頁）
                     檔案：PIPO_Shift_Register.v, PIPO_Shift_Register_new01.v, PIPO_Shift_Register_new02.v, PIPO_tb.v

  【計數器與除頻器】
  12_Counter2        具重置、載入、致能的 8 位元上數計數器（講義第 40~42 頁）
                     檔案：Counter2.v, Counter2_tb.v
  13_Counter3        兩個 always 區塊的計數器，Carry_In / Carry_Out（講義第 43~45 頁）
                     檔案：Counter3.v, Counter3_tb.v
  14_Counter4_5      10 位元計數器，Zero / Max_1023 / Even / Odd 旗標寫在 always 內 vs 外（講義第 46~50 頁）
                     檔案：Counter4.v, Counter5.v, Counter4_5_tb.v
  15_Counter6        上數 / 下數計數器（講義第 51、52 頁）
                     檔案：Counter6.v, Counter6_tb.v
  16_FreqMod2        除 2 器（講義第 53、54 頁）
                     檔案：FreqMod2.v, FreqMod2_tb.v
  17_FreqModN        可程式的除 N 器：原版、-1 修正版、50% duty 版、50% duty 修正版（講義第 55~60 頁）
                     檔案：FreqModN.v, FreqModN_Fix.v, FreqModN_Duty50.v, FreqModN_Duty50_Fix.v, FreqModN_tb.v

與講義不同之處：
  - 所有電路模組的埠宣告改用 Verilog-2001（ANSI）寫法，埠順序不變，功能相同
  - 組合邏輯 always 的敏感清單改用 @(*)（講義手動列出）
  - 時脈觸發的 always 區塊改用非阻隔式賦值 <=（講義用 =）
    ※ 08：講義問「順序更改，結果如何？」—— 用 = 時順序錯了資料會一次傳到底；用 <= 順序無關（說明檔有模擬對照）
    ※ 14：Counter4 的旗標寫在時脈 always 內，改用 <= 後旗標會晚一個時脈（說明檔有講義 = 版本的對照）
  - 01：講義第 2 頁說「Enable 輸入埠不見了，自行模擬」，testbench 自己控制 Enable
  - 02、03：testbench 加上除 2 功能的示範（講義第 6、8 頁的問題）
  - 04：講義的 else if (Clock) 改為 else（能執行到這裡一定是 Clock 正緣）
  - 05：testbench 的 Reset 都在時脈中間改變，避免和正緣同時發生的競爭條件
  - 07：講義第 17 頁標題寫「正準位重置」，但程式 if (!Reset) 是負準位，以程式為準
  - 08：講義兩個 SISO 範例的模組名稱相同，for 迴圈版改名為 SISO_Shift_Register_For；Reg4 用階層式名稱 u1.Reg4 顯示
  - 09：講義的 Data_Out = Data_Out << 1; Data_Out[0] = SI; 改用 <= 寫成 {Data_Out[2:0], SI}；temp 版的清 0 放在 Clear 分支
  - 11：三種寫法一起測；說明檔解釋講義「第一筆資料不見了」的原因並提供修正方式
  - 14：講義第 49 頁的模組名稱還是 Counter4，改為 Counter5
  - 17：除了講義原版（實際除 N+1），另外提供 -1 修正版，以及 50% duty 的講義版與修正版，testbench 自動量測週期
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
