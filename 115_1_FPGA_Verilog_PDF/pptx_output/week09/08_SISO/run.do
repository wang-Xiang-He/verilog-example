# run.do : ModelSim script for 08_SISO
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog SISO_Shift_Register.v SISO_Shift_Register_For.v SISO_tb.v
vsim -voptargs=+acc work.SISO_tb
add wave -r /*
run -all
