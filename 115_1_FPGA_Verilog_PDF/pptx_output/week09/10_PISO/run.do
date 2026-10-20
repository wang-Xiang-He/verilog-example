# run.do : ModelSim script for 10_PISO
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog PISO_Shift_Register.v PISO_tb.v
vsim -voptargs=+acc work.PISO_tb
add wave -r /*
run -all
