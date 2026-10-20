# run.do : ModelSim script for 11_DeMux1x4
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog DeMux1X4_1.v DeMux1X4_2.v DeMux1X4_tb.v
vsim -voptargs=+acc work.DeMux1X4_tb
add wave -r /*
run -all
