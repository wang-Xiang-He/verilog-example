# run.do : ModelSim script for 07_Gate_Delay
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog gate_delay1.v gate_delay1_tb.v
vsim -voptargs=+acc work.gate_delay1_tb
add wave -r /*
run -all
