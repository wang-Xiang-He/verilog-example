# run.do : ModelSim script for 06_Reg16
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Reg_16.v Reg_16_tb.v
vsim -voptargs=+acc work.Reg_16_tb
add wave -r /*
run -all
