@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo  ============================================================
echo   同一個功能三種寫法，實測最高時脈
echo   ★ 用 --seed 1 固定佈局，結果才可重現
echo  ============================================================
echo.

for %%M in (sum_linear sum_tree sum_pipe) do (
    echo  ---- %%M ----
    yosys -q -p "read_verilog 03_optimize.v; synth_ice40 -top %%M -json %%M.json; stat"
    nextpnr-ice40 --hx8k --package ct256 --json %%M.json --freq 50 --placer heap --seed 1 2>&1 | findstr /C:"Max frequency" /C:"ICESTORM_LC:"
    echo.
)

echo  ============================================================
echo   參考結果（本專案實測，iCE40 HX8K, seed=1）
echo.
echo     版本         最高時脈      邏輯單元   延遲   吞吐量
echo     ------------------------------------------------------
echo     sum_linear   109.30 MHz      170     2 拍   每拍 1 筆
echo     sum_tree     109.30 MHz      170     2 拍   每拍 1 筆
echo     sum_pipe   ★ 230.04 MHz      141     4 拍   每拍 1 筆
echo.
echo   ★★ 兩個【出乎意料】的結果：
echo.
echo     1. linear 和 tree 【完全一樣】
echo.
echo        我手動把 a+b+c+d+e+f+g+h 改寫成
echo        ((a+b)+(c+d))+((e+f)+(g+h))，深度從 7 層變 3 層，
echo        結果最高時脈和面積【一個數字都沒變】。
echo.
echo        因為 Yosys 自己就會把加法鏈重新平衡 ——
echo        這種等級的最佳化是綜合工具的基本功。
echo.
echo        ★ 這正是第 11 週 03_area_compare 得到的同一個結論：
echo          「工具做得到的事，手動做只會讓程式碼變難讀」。
echo          樹狀寫法唯一的價值是【人比較看得懂結構】。
echo.
echo     2. pipe 比較快【而且比較小】
echo.
echo        141 vs 170 個邏輯單元 —— 一般以為切管線一定要多花資源，
echo        這裡反而省了 17%%。
echo.
echo        為什麼？因為切開之後每一級的加法器位元數比較窄：
echo          級 1 加 8 位元、級 2 加 9 位元、級 3 加 10 位元，
echo        不像一次全加要一路處理到 11 位元。
echo.
echo        ⚠️ 但在 ASIC 上要重算：多了 23 顆正反器，
echo           用第 13 週 tiny_cells.lib 的數字是 23 x 18 = 414 面積單位。
echo           ★ FPGA 划算的事，ASIC 不一定划算。
echo.
echo  ============================================================
echo   ★ 面積 vs 速度取捨，一句話總結：
echo.
echo     沒有「最好的寫法」，只有「符合你規格的寫法」。
echo.
echo       要 100 MHz  -^> 用 linear，最省事
echo       要 200 MHz  -^> 只能切管線，接受多 2 拍延遲
echo       要最省面積  -^> 回頭看第 10 週的移位相加（慢但小）
echo.
echo     ★ 先問「規格要多快」，再決定怎麼寫。
echo       不要一開始就為了「感覺比較好」去做沒必要的最佳化。
echo  ============================================================
echo.
