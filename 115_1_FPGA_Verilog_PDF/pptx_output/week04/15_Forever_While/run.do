# run.do : ModelSim script for 15_Forever_While
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Forever_While_tb.v
vsim -voptargs=+acc work.Forever_While_tb
add wave -r /*
run -all
