115-1 高等 FPGA 系統設計 期中考（交卷期限 115/11/19 四）
============================================================

完整解答：期中考_解答.md

每個資料夾 = 一題，內容包含：
  *.v            電路本體 / 測試平台
  run.do         ModelSim 腳本，一鍵完成 編譯 -> 載入 -> 加波形 -> 執行
  *.png          題目要求的電路圖 / 訊號流動圖 / 波形圖

!! ModelSim 不支援中文路徑 !!
  「期中考」資料夾內直接執行會出現 sqlite3_open ... unable to open database file。
  請先把要跑的資料夾複製到全英文路徑（例如 D:\midterm\Q3_bin2gra），
  再 File > Change Directory... 切過去，在 Transcript 輸入：  do run.do

題目清單：
  Q1_FullAdd           第 1 題  ModelSim 模擬流程示範（FullAdd.v, FullAdd_test.v）
  Q2_FPGA_LUT          第 2 題  f = (x1+x2)x3' + x1x3' + x1'x4' 的 2 輸入 LUT FPGA 電路
                                 Q2_FPGA_circuit.png, FPGA_LUT_f.v, FPGA_LUT_f_tb.v
  Q3_bin2gra           第 3 題  bin2gra 的 Test bench（bin2gra.v, bin2gra_test.v）
  Q4_Bidirectional     第 4 題  enable_in_out=1, data_in=1 的訊號流動
                                 Q4_signal_flow.png, Q4_waveform.png, Bidirectional.v, Bidirectional_tb.v
  Q5_Case_TwosComp16   第 5 題  (A)(B) case/casez/casex 比較：do run_case.do
                                 (C) TwosComp16 16 位元 2 的補數：do run.do
