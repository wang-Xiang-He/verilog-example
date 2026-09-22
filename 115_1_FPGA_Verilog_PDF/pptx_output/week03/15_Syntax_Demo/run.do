# run.do : ModelSim script for 15_Syntax_Demo
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Syntax_Demo_tb.v
vsim -voptargs=+acc work.Syntax_Demo_tb
add wave -r /*
run -all
