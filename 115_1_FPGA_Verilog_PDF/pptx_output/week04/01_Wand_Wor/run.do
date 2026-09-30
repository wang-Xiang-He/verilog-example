# run.do : ModelSim script for 01_Wand_Wor
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog wand_test.v wor_test.v wire_test.v WiredLogic_tb.v
vsim -voptargs=+acc work.WiredLogic_tb
add wave -r /*
run -all
