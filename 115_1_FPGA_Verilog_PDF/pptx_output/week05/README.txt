Verilog 硬體描述語言 — 函數 (Function) 與任務 (Task) 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行
  *_說明.md 範例說明

ModelSim 的詳細操作（腳本 / 手動指令 / 圖形介面）請看 ../week03/ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_Func_AS）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  01_Func_AS         function 基本用法：加 / 減 / 加 1 / 減 1 運算器（講義第 2~5 頁）
                     檔案：Func_AS.v, Func_AS_tb.v
                     另附 `include 版本（講義沒有，額外補充）：把函數獨立成 Sub_Inc_Dec.vh
                     檔案：Sub_Inc_Dec.vh, Func_AS_inc.v, Func_AS_inc_tb.v　執行：do run_inc.do
  02_Even_Parity16   以 8 位元偶同位函數完成 16 位元偶同位元產生器（範例練習 6-001，講義第 6~8 頁）
                     檔案：even_parity_16.v, even_parity_16_tb.v
  03_Decod_Fcn       以 2 對 4 解碼器函數產生 3 對 8 解碼器（範例練習 6-002，講義第 9~12 頁）
                     檔案：decod_fcn.v, decod_fcn_tb.v
  04_Sort4           task 基本用法：4 筆資料排序，inout 引數（講義第 14~17 頁）
                     檔案：Sort_4_Data.v, Sort_4_Data_tb.v
  05_Odd_Parity16    以 8 位元奇同位任務完成 16 位元奇同位元產生器（範例練習 6-003，講義第 18~22 頁）
                     檔案：odd_parity_16.v, odd_parity_16_tb.v
  06_Even16_Fun_Fun  函數呼叫函數：16 位元偶同位元產生器（範例練習 6-004，講義第 24~27 頁）
                     檔案：even16_fun_fun.v, even16_fun_fun_tb.v
  07_Comp16_T_TF     任務呼叫函數與任務：16 位元比較器（範例練習 6-005，講義第 29~33 頁）
                     檔案：comp16_t_tf.v, comp16_t_tf_tb.v
  08_System_Task     系統函數與任務：$display / $write / $time / $finish（講義第 35 頁）
                     檔案：System_Task_tb.v

與講義不同之處：
  - 所有電路模組的埠宣告改用 Verilog-2001（ANSI）寫法，埠順序不變，功能相同
  - function / task 的引數也改用 Verilog-2001 寫法，直接寫在括號裡：
      function [3:0] f (input [3:0] a, input b);      講義：function [3:0] f;  input [3:0] a;  input b;
  - 組合邏輯 always 的敏感清單改用 @(*)（講義手動列出）
  - 02、05：講義的標題頁和程式碼對不起來，本範例依程式碼為準
        6-001 標題寫「奇同位」，但程式是 even_parity_16（偶同位，^）  → 02 做偶同位
        6-003 標題寫「16 位元偶同位」，但程式是 odd_parity_16（奇同位，~^）→ 05 做奇同位
  - 03：測試平台的 Din 在時脈邊緣更新，改用非阻隔式 <=
  - 04：測試平台改為「幾筆例子 + 65536 種輸入自動檢查」
  - 05：任務 odd8 的輸出講義也取名 odd8（和任務同名，ModelSim 可以編譯），這裡改名為 P 避免混淆
  - 06：測試平台加上 65536 種輸入和 ^Din 的自動比對
  - 07：compare4_T 的引數講義寫 [7:4]，改為 [3:0]（寬度相同）；講義沒有列出測試平台，自行補上
  - 08：講義用 $finish，改用 $stop
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
