Verilog 硬體描述語言 (I) — 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行

詳細的 ModelSim 操作（腳本 / 手動指令 / 圖形介面）請看 ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_FullAdd）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  01_FullAdd         1 位元全加器（講義第 6、7 頁）
                     檔案：FullAdd.v, FullAdd_tb.v
  02_FullAdd4        4 位元漣波進位加法器（Ripple Carry Adder）（講義第 4、5、7、8 頁）
                     檔案：FullAdd.v, FullAdd4.v, FullAdd4_tb.v
  03_Hierar          階層式設計：Mux + Register8 + Rotate_Data，依順序 / 依名稱埠對應（講義第 22~28 頁）
                     檔案：Mux.v, Register8.v, Rotate_Data.v, Top1.v, Top2.v, Hierar_tb.v
  04_DFF             D 型正反器（範例練習 3-001）（講義第 29、31 頁）
                     檔案：dff.v, dff_tb.v
  05_DFF_Sel         正反器選擇電路：2 個 D 型正反器 + 多工器（講義第 30、32 頁）
                     檔案：dff.v, mux2_1.v, dff_sel.v, dff_sel_tb.v
  06_BitWise         縮減運算子應用：判斷奇同位、偶同位、全為 1（講義第 49、50 頁）
                     檔案：BitWise.v, BitWise_tb.v
  07_Deco2_4g        2-4 高態輸出解碼器（範例練習 3-002，邏輯閘層次）（講義第 51~54 頁）
                     檔案：deco2_4g.v, deco2_4g_tb.v
  08_AddOrSub        加減法器（parameter 參數 + 條件運算子）（講義第 59、60 頁）
                     檔案：Add_or_Subtract.v, Add_or_Subtract_tb.v
  09_Compare         比較器（關係 / 等式運算子）（講義第 62、63 頁）
                     檔案：Comparator.v, Comparator_tb.v
  10_R_Shift         右移運算子（除以 2 的次方）（講義第 65、66 頁）
                     檔案：R_Shift.v, R_Shift_tb.v
  11_Decoder         3 對 8 解碼器（左移運算子）（講義第 67、68 頁）
                     檔案：Decoder.v, Decoder_tb.v
  12_Mux2to1         2 對 1 多工器（條件運算子）（講義第 69、70 頁）
                     檔案：Mux2to1.v, Mux2to1_tb.v
  13_Sign_Ext        符號位元擴展（重複運算子）（講義第 71~73 頁）
                     檔案：Sign_Extend.v, Sign_Extend_tb.v
  14_Concate         連結運算子：交換高低 4 位元（講義第 74~76 頁）
                     檔案：Concate.v, Concate_tb.v
  15_Syntax_Demo     基本語法：數值、底線、問號、字串、$display / $write（講義第 12~19 頁）
                     檔案：Syntax_Demo_tb.v
  16_Monitor_Stop    $monitor 持續監視、$strobe、$stop / $finish（講義第 20、21 頁）
                     檔案：monitest_tb.v

與講義不同之處：
  - 正反器 / 暫存器的 always 區塊改用非阻隔式賦值 <=（講義用 =），原因寫在 03_Hierar/Register8.v
  - FullAdd4 補上講義漏寫的內部進位 wire 宣告
  - 05_DFF_Sel 的 mux2_1 講義沒有列出，依方塊圖自行補上
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
