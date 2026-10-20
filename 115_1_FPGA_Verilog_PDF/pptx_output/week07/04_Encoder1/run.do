# run.do : ModelSim script for 04_Encoder1
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Encoder1.v Encoder1_tb.v
vsim -voptargs=+acc work.Encoder1_tb
add wave -r /*
run -all
