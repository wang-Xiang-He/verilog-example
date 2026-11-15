# run.do : 第 5 題 (C) TwosComp16
vlib work
vmap work work
vlog TwosComp16.v TwosComp16_tb.v
vsim -voptargs=+acc work.TwosComp16_tb
add wave -radix hex /TwosComp16_tb/In_Data /TwosComp16_tb/Out_Data
run -all
