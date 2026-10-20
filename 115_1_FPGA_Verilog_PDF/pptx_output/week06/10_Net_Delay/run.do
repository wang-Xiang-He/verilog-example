# run.do : ModelSim script for 10_Net_Delay
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog gate_delay2.v gate_delay2_tb.v
vsim -voptargs=+acc work.gate_delay2_tb
add wave -r /*
run -all
