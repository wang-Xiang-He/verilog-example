# run.do : ModelSim script for 07_If_Reset
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Reg_RstHigh.v Reg_RstLow.v If_Reset_tb.v
vsim -voptargs=+acc work.If_Reset_tb
add wave -r /*
run -all
