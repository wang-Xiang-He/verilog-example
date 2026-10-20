# run.do : ModelSim script for 13_Counter3
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Counter3.v Counter3_tb.v
vsim -voptargs=+acc work.Counter3_tb
add wave -r /*
run -all
