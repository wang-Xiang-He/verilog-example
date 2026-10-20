# run.do : ModelSim script for 12_Counter2
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Counter2.v Counter2_tb.v
vsim -voptargs=+acc work.Counter2_tb
add wave -r /*
run -all
