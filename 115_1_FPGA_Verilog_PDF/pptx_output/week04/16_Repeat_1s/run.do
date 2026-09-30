# run.do : ModelSim script for 16_Repeat_1s
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog repeat_1s.v repeat_1s_tb.v
vsim -voptargs=+acc work.repeat_1s_tb
add wave -r /*
run -all
