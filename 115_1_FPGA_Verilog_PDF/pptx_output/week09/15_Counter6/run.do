# run.do : ModelSim script for 15_Counter6
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Counter6.v Counter6_tb.v
vsim -voptargs=+acc work.Counter6_tb
add wave -r /*
run -all
