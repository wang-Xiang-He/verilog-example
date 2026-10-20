Verilog 硬體描述語言 — 進階編譯命令與時序延遲設定 講義範例（ModelSim 版）
============================================================

每個資料夾 = 一個範例，內容包含：
  *.v      電路本體（design）
  *_tb.v   測試平台（testbench），檔案最後有【預期輸出】【ModelSim 執行指令】的註解
  run.do   ModelSim 腳本，一鍵完成 編譯 → 載入 → 加波形 → 執行
  *_說明.md 範例說明

ModelSim 的詳細操作（腳本 / 手動指令 / 圖形介面）請看 ../week03/ModelSim_使用說明.md

最快的用法：
  1. 開 ModelSim
  2. File > Change Directory... 選到某個範例資料夾（例如 01_Include）
  3. 在下方 Transcript 視窗輸入：  do run.do
  4. 看完後輸入：  quit -sim   再換下一個資料夾重複 2~3

範例清單：
  【進階編譯命令】
  01_Include         `include 引用另一個檔案：4 位元漣波進位加法器（講義第 2~4 頁）
                     檔案：FullAdd.v, FullAdd4.v, FullAdd4_tb.v
                     ※ FullAdd.v 由 `include 帶入，vlog 不列
  02_Define          `define 定義常數 + parameter 定義狀態：紅綠燈控制器（講義第 5、16、17 頁）
                     檔案：Traffic_Light.v, Traffic_Light_tb.v
  03_Defparam        Scalable Design，用 defparam 改寫 parameter：8 位元加法器（講義第 6~8 頁）
                     檔案：Scalable.v, Adder8.v, Adder8_tb.v
                     ※ Scalable.v 由 `include 帶入，vlog 不列
  04_Param_Hash      用 # 改寫 parameter，依順序 / 依名稱：16 位元加法器（講義第 9、10 頁）
                     檔案：Scalable.v, Adder16.v, Adder16_tb.v
                     ※ Scalable.v 由 `include 帶入，vlog 不列
  05_Param_Multi     一次改寫多個 parameter，一對一 / 多對多 / 少對多（講義第 11~14 頁）
                     檔案：Scalable.v, Adder16.v, Adder16_tb.v
                     ※ Scalable.v 由 `include 帶入，vlog 不列
  06_Timescale       `timescale 時間單位 / 時間精度，$time、$realtime、%t 的差別（講義第 18 頁）
                     檔案：time_scale_tb.v

  【時序延遲設定】（07~13 是同一個電路 y = (a1 & a2) | (a3 & a4)，延遲設在不同地方）
  07_Gate_Delay      邏輯閘層描述，設定個別邏輯閘的延遲（範例練習 7-001，講義第 20~22 頁）
                     檔案：gate_delay1.v, gate_delay1_tb.v
  08_Dataflow_Delay1 資料流描述，設定個別邏輯閘的延遲（範例練習 7-002，講義第 23、24 頁）
                     檔案：dataflow_delay1.v, dataflow_delay1_tb.v
  09_Dataflow_Delay2 資料流描述，只設定輸出端邏輯閘的延遲（範例練習 7-003，講義第 25~28 頁）
                     檔案：dataflow_delay2.v, dataflow_delay2_tb.v
  10_Net_Delay       邏輯閘層描述，設定連接線延遲 wire #2（範例練習 7-004，講義第 29~31 頁）
                     檔案：gate_delay2.v, gate_delay2_tb.v
  11_PPath_Delay     specify 並列路徑延遲 =>（範例練習 7-005，講義第 32~35 頁）
                     檔案：ppath_delay1.v, ppath_delay1_tb.v
  12_FCPath_Delay    specify 完全連接路徑延遲 *>（範例練習 7-006，講義第 36~38 頁）
                     檔案：fcpath_delay1.v, fcpath_delay1_tb.v
  13_CFCPath_Delay   specify 條件式完全連接路徑延遲 if (...)（範例練習 7-009，講義第 39~42 頁）
                     檔案：cfcpath_delay.v, cfcpath_delay_tb.v
  ※ 講義沒有範例練習 7-007、7-008

與講義不同之處：
  - 所有電路模組的埠宣告改用 Verilog-2001（ANSI）寫法，埠順序不變，功能相同
  - 有 parameter 的模組改寫成 module 名稱 #(parameter ...) (...) 的形式
  - 時脈觸發的 always 區塊改用非阻隔式賦值 <=（講義用 =）
  - 01：講義第 3 頁說 Carry_Out1~3「可不宣告」（隱含宣告），這裡還是宣告出來
  - 01：FullAdd 的埠名依講義第 3 頁用 CarryIn / CarryOut（week03 版本是 Carry_In / Carry_Out）
  - 02：講義只有紅綠燈的程式片段（中間寫「略」），依片段補成完整可模擬的電路與測試平台
  - 03、04：測試數值依講義第 8、10 頁波形；第 3 組 1 + 15 + 1 是波形最右邊游標處的值
  - 04：測試平台另外用 #(.our_size(4)) 依名稱改寫，回答講義「如何修改數字 (By order, By name)」
  - 05：講義 Scalable.v 的 wire [size1-1:0] sum;（小寫 s，沒有用到）拿掉
  - 05：講義的測試平台模組名稱是 t（Adder16_test.v），改為 Adder16_tb（Adder16_tb.v）
  - 05：測試平台另外加一個 Adder #(4)，示範「少對多」
  - 06：講義的 'timescale（單引號）改為 `timescale（反引號）、Initial 改為 initial
  - 06：補上 $monitor 印出時間，並比較 %t、$time、$realtime 三種寫法
  - 07~13：$monitor 另外印出內部訊號 uut.y1、uut.y2，方便看出延遲加在哪一級
  - 07~13：測試平台的實例名稱講義和模組同名（gate_delay1 gate_delay1(...)），改為 uut
  - 所有 testbench 用 $stop 結束（ModelSim 用 $finish 會跳出是否關閉的詢問視窗）
  - 中文註解為 UTF-8 編碼；若 ModelSim 內建編輯器顯示亂碼，不影響編譯，可改用 VS Code / Notepad++ 開啟閱讀
