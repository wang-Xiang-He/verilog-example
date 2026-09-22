# run.do : ModelSim script for 07_Deco2_4g
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog deco2_4g.v deco2_4g_tb.v
vsim -voptargs=+acc work.deco2_4g_tb
add wave -r /*
run -all
