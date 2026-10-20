# run.do : ModelSim script for 05_Encoder2_3
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Encoder2.v Encoder3.v Encoder2_3_tb.v
vsim -voptargs=+acc work.Encoder2_3_tb
add wave -r /*
run -all
