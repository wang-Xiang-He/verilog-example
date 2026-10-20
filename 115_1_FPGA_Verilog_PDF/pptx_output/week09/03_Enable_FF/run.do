# run.do : ModelSim script for 03_Enable_FF
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Enable_FF1.v Enable_FF1_tb.v
vsim -voptargs=+acc work.Enable_FF1_tb
add wave -r /*
run -all
