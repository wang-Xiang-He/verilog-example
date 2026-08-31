@echo off
chcp 65001 >nul
cd /d "%~dp0"
del /q report_util.txt 2>nul

echo.
echo  ============================================================
echo   資源使用率分析
echo.
echo   iCE40 HX8K 有什麼：
echo     ICESTORM_LC    7680 個   邏輯單元（1 個 LUT4 + 1 個 DFF）
echo     ICESTORM_RAM     32 個   4Kbit Block RAM
echo     SB_IO           206 支   輸出入腳位
echo     SB_GB             8 個   全域緩衝（時脈網路）
echo     ICESTORM_PLL      2 個   鎖相迴路
echo  ============================================================
echo.

for %%M in (util_small util_medium util_large util_bram util_lutram) do (
    echo  ---- %%M ----
    yosys -p "read_verilog 04_utilization.v; synth_ice40 -top %%M; tee -a report_util.txt stat" > nul 2>&1
    if errorlevel 1 (echo      [X] 失敗) else (echo      OK)
)

echo.
echo  ============================================================
echo   一、設計變大時，資源怎麼長（本專案實測）
echo.
echo     模組         N   SB_LUT4  SB_DFFR  SB_CARRY   佔 7680 的
echo     ----------------------------------------------------------
echo     util_small   2      400      48       55        5%%
echo     util_medium  8     1800     144      213       23%%
echo     util_large  32     7110     528      841     ★ 93%%
echo.
echo   ★ N 從 2 變 32（16 倍），LUT 從 400 變 7110（17.8 倍）——
echo     幾乎是線性成長，因為每一路 MAC 是獨立的。
echo.
echo   ⚠️ util_large 用掉 93%% 的晶片。這在實務上【已經太滿】：
echo       - 佈局繞線會變得很難，最高時脈掉很多
echo       - 之後想加任何功能都塞不下
echo       - 一般會把使用率控制在 70~80%% 以下
echo.
echo  ============================================================
echo   二、★★★ 本週最重要的一組數字：BRAM vs LUT
echo.
echo     同樣是 512 x 8 bit 的記憶體，只差【讀取方式】：
echo.
echo     模組          寫法              SB_LUT4   DFF     BRAM
echo     ----------------------------------------------------------
echo     util_bram     同步讀（dout^<=）      17    27       1
echo     util_lutram   非同步讀（assign）   4004  4096       0
echo.
echo     ★★★ 差了【235 倍】的 LUT。
echo.
echo     為什麼？
echo       Block RAM 是晶片上【本來就做好的專用硬體】，
echo       但它的讀取【一定是同步的】—— 硬體上就沒有非同步讀這條路。
echo.
echo       你寫成 assign dout = mem[addr]（非同步讀），
echo       綜合工具就【用不了 BRAM】，只好拿 4096 顆正反器
echo       加 4004 顆 LUT 硬拼出一塊記憶體。
echo.
echo       整顆 HX8K 只有 7680 個邏輯單元 —— 一塊 512 位元組的記憶體
echo       就吃掉一半以上。這就是第 9 週說的
echo       「FPGA 有專用的記憶體硬體，但你要【寫對寫法】它才會用」。
echo.
echo     ★ 記住這個寫法：
echo         always @(posedge clk) begin
echo             if (we) mem[addr] ^<= din;
echo             dout ^<= mem[addr];      ^<-- ★ 同步讀，這一行是關鍵
echo         end
echo.
echo   完整報告：report_util.txt
echo  ============================================================
echo.
