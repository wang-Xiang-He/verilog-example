# run.do : ModelSim script for 03_Decod_Fcn
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog decod_fcn.v decod_fcn_tb.v
vsim -voptargs=+acc work.decod_fcn_tb
add wave -r /*
run -all
