# run.do : ModelSim script for 08_Dataflow_Delay1
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog dataflow_delay1.v dataflow_delay1_tb.v
vsim -voptargs=+acc work.dataflow_delay1_tb
add wave -r /*
run -all
