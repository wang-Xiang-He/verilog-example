@echo off
chcp 65001 >nul
cd /d "%~dp0"
del /q report_liberty.txt 2>nul

echo.
echo  ============================================================
echo   ASIC 流程第二步：映射到【標準元件庫】
echo.
echo   元件庫檔案：tiny_cells.lib（自製的玩具級元件庫，可以打開看）
echo.
echo   三個步驟：
echo     dfflibmap  把正反器換成元件庫裡的 DFF / DFFR
echo     abc        把組合邏輯挑成元件庫裡的閘（照面積最佳化）
echo     stat       依元件庫的 area 欄位算出總面積
echo  ============================================================
echo.

for %%M in (fa adder4 counter4 alu4) do (
    echo  ---- %%M ----
    yosys -p "read_verilog 01_generic_synth.v; synth -top %%M -flatten; dfflibmap -liberty tiny_cells.lib; abc -liberty tiny_cells.lib; opt_clean; tee -a report_liberty.txt stat -liberty tiny_cells.lib; write_verilog -noattr %%M_mapped.v" > nul 2>&1
    if errorlevel 1 (echo      [X] 失敗) else (echo      OK  -^> %%M_mapped.v)
)

echo.
echo  ============================================================
echo   參考結果（本專案實測）
echo.
echo     模組       元件數   總面積   組成
echo     ---------------------------------------------------------
echo     fa            7      19     2 AND2 + 1 MUX2 + 3 NOR2 + 1 OR2
echo     adder4       29      69
echo     counter4     12     109     ★ 4 DFFR 就佔 88（81%%）
echo     alu4         55     136
echo.
echo   ★★ counter4 那一行是本週最重要的一個數字：
echo.
echo       整個計數器面積 109，其中【4 顆正反器就吃掉 88】。
echo       組合邏輯（AND/NAND/NOR/NOT/XOR 共 8 顆）只用了 21。
echo.
echo       正反器佔了 81%% 的面積。
echo.
echo       這就是 ASIC 和 FPGA 最大的觀念差異：
echo         FPGA  正反器本來就在那裡，不用白不用 -^> 盡量切管線
echo         ASIC  每一顆正反器都是真實的面積和功耗 -^> 切管線要算清楚
echo.
echo       第 12 週說「切管線很划算」，在 FPGA 上成立；
echo       在 ASIC 上，多插一級管線的成本要用這張表重新評估。
echo.
echo   完整報告：report_liberty.txt
echo   映射後的網表：fa_mapped.v / adder4_mapped.v / …（可以打開看真的元件）
echo  ============================================================
echo.
