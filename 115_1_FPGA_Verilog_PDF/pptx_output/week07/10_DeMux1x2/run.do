# run.do : ModelSim script for 10_DeMux1x2
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog DeMux1X2_1.v DeMux1X2_2.v DeMux1X2_tb.v
vsim -voptargs=+acc work.DeMux1X2_tb
add wave -r /*
run -all
