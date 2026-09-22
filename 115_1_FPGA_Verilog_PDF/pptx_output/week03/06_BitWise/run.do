# run.do : ModelSim script for 06_BitWise
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog BitWise.v BitWise_tb.v
vsim -voptargs=+acc work.BitWise_tb
add wave -r /*
run -all
