# run.do : ModelSim script for 13_For_Loop
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog For_XOR.v For_XOR_tb.v
vsim -voptargs=+acc work.For_XOR_tb
add wave -r /*
run -all
