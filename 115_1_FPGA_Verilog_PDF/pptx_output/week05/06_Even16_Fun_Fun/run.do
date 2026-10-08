# run.do : ModelSim script for 06_Even16_Fun_Fun
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog even16_fun_fun.v even16_fun_fun_tb.v
vsim -voptargs=+acc work.even16_fun_fun_tb
add wave -r /*
run -all
