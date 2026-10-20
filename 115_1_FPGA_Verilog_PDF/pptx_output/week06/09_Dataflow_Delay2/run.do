# run.do : ModelSim script for 09_Dataflow_Delay2
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog dataflow_delay2.v dataflow_delay2_tb.v
vsim -voptargs=+acc work.dataflow_delay2_tb
add wave -r /*
run -all
