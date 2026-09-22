# run.do : ModelSim script for 04_DFF
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog dff.v dff_tb.v
vsim -voptargs=+acc work.dff_tb
add wave -r /*
run -all
