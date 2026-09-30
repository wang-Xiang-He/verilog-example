# run.do : ModelSim script for 06_Always_Edge
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog And3_Level.v And3_Posedge.v And3_Negedge.v Always_tb.v
vsim -voptargs=+acc work.Always_tb
add wave -r /*
run -all
