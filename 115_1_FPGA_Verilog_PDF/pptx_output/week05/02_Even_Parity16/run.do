# run.do : ModelSim script for 02_Even_Parity16
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog even_parity_16.v even_parity_16_tb.v
vsim -voptargs=+acc work.even_parity_16_tb
add wave -r /*
run -all
