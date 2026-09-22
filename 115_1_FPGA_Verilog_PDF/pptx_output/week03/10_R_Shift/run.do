# run.do : ModelSim script for 10_R_Shift
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog R_Shift.v R_Shift_tb.v
vsim -voptargs=+acc work.R_Shift_tb
add wave -r /*
run -all
