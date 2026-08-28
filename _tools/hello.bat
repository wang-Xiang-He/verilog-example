@echo off
echo.
echo  ============================================================
echo   Verilog 課程環境已就緒
echo  ============================================================
echo.
echo   [ 跑一個範例：cd 進資料夾，然後這四行 ]
echo.
echo     cd week01_basics
echo.
echo     iverilog -o sim.out 01_gates.v 01_gates_tb.v      ^<- 編譯
echo     echo %%ERRORLEVEL%%                                 ^<- 印 0 才是成功
echo     vvp sim.out                                      ^<- 模擬
echo     gtkwave 01_gates.gtkw                            ^<- 開波形
echo.
echo   [ 查資料 ]
echo.
echo     weeks     列出所有週次和範例名稱
echo     dir *.v   看目前資料夾有哪些設計檔
echo     cd ..     回上一層
echo.
echo   按 上方向鍵 可以叫回上一個指令（改完 .v 重跑靠這個）
echo.
echo   每個範例的完整指令都在 HOWTO.md，課程規劃在 COURSE.md
echo   ^(打膩了也有我寫的捷徑 sim 範例名稱，但不是必要的^)
echo.
