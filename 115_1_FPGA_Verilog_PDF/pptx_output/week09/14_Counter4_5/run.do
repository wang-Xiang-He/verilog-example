# run.do : ModelSim script for 14_Counter4_5
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Counter4.v Counter5.v Counter4_5_tb.v
vsim -voptargs=+acc work.Counter4_5_tb
add wave -r /*
run -all
