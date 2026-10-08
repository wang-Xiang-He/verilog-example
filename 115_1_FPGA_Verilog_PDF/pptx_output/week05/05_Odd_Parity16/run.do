# run.do : ModelSim script for 05_Odd_Parity16
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog odd_parity_16.v odd_parity_16_tb.v
vsim -voptargs=+acc work.odd_parity_16_tb
add wave -r /*
run -all
