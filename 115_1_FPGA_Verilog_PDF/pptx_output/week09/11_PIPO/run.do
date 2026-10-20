# run.do : ModelSim script for 11_PIPO
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog PIPO_Shift_Register.v PIPO_Shift_Register_new01.v PIPO_Shift_Register_new02.v PIPO_tb.v
vsim -voptargs=+acc work.PIPO_tb
add wave -r /*
run -all
