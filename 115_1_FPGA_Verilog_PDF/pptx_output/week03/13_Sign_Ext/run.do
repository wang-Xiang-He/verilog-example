# run.do : ModelSim script for 13_Sign_Ext
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Sign_Extend.v Sign_Extend_tb.v
vsim -voptargs=+acc work.Sign_Extend_tb
add wave -r /*
run -all
