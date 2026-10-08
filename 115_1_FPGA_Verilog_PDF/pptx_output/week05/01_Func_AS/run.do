# run.do : ModelSim script for 01_Func_AS
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Func_AS.v Func_AS_tb.v
vsim -voptargs=+acc work.Func_AS_tb
add wave -r /*
run -all
