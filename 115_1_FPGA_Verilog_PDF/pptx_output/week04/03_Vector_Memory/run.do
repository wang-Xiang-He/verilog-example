# run.do : ModelSim script for 03_Vector_Memory
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Vector_Memory_tb.v
vsim -voptargs=+acc work.Vector_Memory_tb
add wave -r /*
run -all
