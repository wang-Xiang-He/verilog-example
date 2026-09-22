# run.do : ModelSim script for 08_AddOrSub
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Add_or_Subtract.v Add_or_Subtract_tb.v
vsim -voptargs=+acc work.Add_or_Subtract_tb
add wave -r /*
run -all
