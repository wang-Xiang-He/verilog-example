@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   讀懂時序報告
echo  ============================================================
echo.

if not exist 01_pnr_flow.asc (
    echo  [!] 找不到 01_pnr_flow.asc，先跑 01_pnr_flow.bat
    exit /b 1
)

echo  ---- 一、nextpnr 的關鍵路徑報告 ----
echo.
nextpnr-ice40 --hx8k --package ct256 --json 01_pnr_flow.json --pcf pins.pcf --asc tmp_tr.asc --freq 50 --placer heap --seed 1 2>&1 | findstr /C:"Max frequency" /C:"Max delay" /C:"Critical path report" /C:"Info: curr"
echo.

echo  ---- 二、icetime 的逐段延遲 ----
echo.
icetime -d hx8k -mtr 02_timing.rpt 01_pnr_flow.asc
echo.
echo        完整報告在 02_timing.rpt，開起來看前 30 行。
echo.

echo  ============================================================
echo   ★★ 怎麼讀 icetime 報告
echo.
echo   報告會像這樣一行一行列出訊號經過的每一個元件：
echo.
echo       pre_io_33_23_0 (PRE_IO) [clk] -^> DIN0: 0.240 ns
echo    0.240 ns net_132566 (acc_...)              ← 累計時間
echo       odrv_33_23_132566_115753 (Odrv12) I -^> O: 0.540 ns
echo       t526 (Span12Mux_h12) I -^> O: 0.540 ns   ← ★ 走線的延遲
echo       t525 (Span12Mux_h12) I -^> O: 0.540 ns
echo       ...
echo       lc40_3_13_1 (LogicCell40) in0 -^> lcout: 0.449 ns  ← 邏輯的延遲
echo    3.887 ns net_9739 (...)
echo.
echo   ★★★ 這份報告最重要的一件事：
echo.
echo       數一數 Span12Mux / Span4Mux / LocalMux / InMux 這些
echo       【走線】元件佔了多少時間，再數 LogicCell40 這種
echo       【邏輯】元件佔多少。
echo.
echo       你會發現 —— ★ 走線的延遲【比邏輯還多】。
echo.
echo       這就是為什麼「佈局擺得好不好」會影響最高時脈那麼多，
echo       也是為什麼晶片越做越大之後，繞線變成主要瓶頸。
echo.
echo  ============================================================
echo   ⚠️ 為什麼 nextpnr 和 icetime 給的數字不一樣？
echo.
echo     nextpnr  ：258.26 MHz
echo     icetime  ：110.76 MHz
echo.
echo     兩個都沒錯，它們算的不是同一件事：
echo.
echo       nextpnr 算的是【正反器到正反器】的路徑（同步路徑），
echo               這是決定時脈上限的那個數字。
echo.
echo       icetime 預設開 max_span_hack（報告裡有寫
echo               "estimate is conservative"），會用【比較保守】的
echo               走線延遲估計，而且把 IO 路徑也算進去。
echo.
echo     ★ 實務判斷：
echo         要知道時脈上限 -^> 看 nextpnr 的 Max frequency
echo         要看路徑細節   -^> 看 icetime 的逐段報告
echo.
echo     ⚠️ 這也是很重要的一課：【不同工具給不同數字是常態】。
echo        報數字的時候一定要講清楚是哪個工具、什麼條件下量的。
echo  ============================================================
echo.
del /q tmp_tr.asc 2>nul
