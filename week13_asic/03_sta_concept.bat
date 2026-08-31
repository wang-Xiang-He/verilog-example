@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   靜態時序分析：三條長度不同的路徑，各能跑多快
echo  ============================================================
echo.

for %%M in (path_short path_medium path_long sta_demo) do (
    echo  ---- %%M ----
    yosys -q -p "read_verilog 03_sta_concept.v; synth_ice40 -top %%M -json %%M.json"
    nextpnr-ice40 --hx8k --package ct256 --json %%M.json --freq 50 --placer heap --seed 1 2>&1 | findstr /C:"Max frequency"
    echo.
)

echo  ============================================================
echo   參考結果（本專案實測，iCE40 HX8K, seed=1）
echo.
echo     模組          路徑內容                 最高時脈
echo     ---------------------------------------------------------
echo     path_short    8 顆 XOR（一層邏輯）      655.31 MHz
echo     path_medium   8 位元加法器              244.20 MHz
echo     path_long     8x8 乘法器                116.05 MHz
echo     sta_demo      三條全放在同一個模組      ★ 約等於 path_long
echo.
echo   ★★ 最後一行是本範例最重要的一課：
echo.
echo       sta_demo 裡面有一條 655 MHz 的路徑、一條 244 MHz 的，
echo       但整個模組的最高時脈【只有 116 MHz】。
echo.
echo       ★ 整個設計的速度由【最慢的那一條路徑】決定。
echo         其他路徑再快都沒有用。
echo.
echo       這條最慢的路徑就叫【關鍵路徑 Critical Path】。
echo       時序收斂的工作，就是不斷找出關鍵路徑、把它縮短，
echo       縮到某個程度之後，另一條路徑會變成新的關鍵路徑。
echo.
echo   ★ 縮短關鍵路徑的三個方法：
echo       1. 切管線（第 12 週）      -^> 把長路徑切成幾段
echo       2. 換演算法               -^> 例如乘法改成位移相加
echo       3. 讓工具多花點力氣最佳化  -^> nextpnr 加 --opt-timing
echo  ============================================================
echo.
