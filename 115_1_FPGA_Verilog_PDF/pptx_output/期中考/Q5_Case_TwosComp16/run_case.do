# run_case.do : 第 5 題 (A)(B) case / casez / casex 比較
vlib work
vmap work work
vlog case_compare.v case_compare_tb.v
vsim -voptargs=+acc work.case_compare_tb
add wave -radix binary /case_compare_tb/*
run -all
