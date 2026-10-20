# run.do : ModelSim script for 02_DFF_RS
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog DFF_RS.v DFF_RS_tb.v
vsim -voptargs=+acc work.DFF_RS_tb
add wave -r /*
run -all
