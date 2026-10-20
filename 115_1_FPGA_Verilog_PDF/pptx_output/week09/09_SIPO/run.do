# run.do : ModelSim script for 09_SIPO
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog SIPO_Shift_Register.v SIPO_Shift_Register_1.v SIPO_tb.v
vsim -voptargs=+acc work.SIPO_tb
add wave -r /*
run -all
