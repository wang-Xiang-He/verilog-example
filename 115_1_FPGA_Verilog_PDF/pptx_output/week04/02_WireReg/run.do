# run.do : ModelSim script for 02_WireReg
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Zero_Detect.v Add_Reg.v Add_Wire.v WireReg_tb.v
vsim -voptargs=+acc work.WireReg_tb
add wave -r /*
run -all
