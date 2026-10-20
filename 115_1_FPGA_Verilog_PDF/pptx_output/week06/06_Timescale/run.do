# run.do : ModelSim script for 06_Timescale
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog time_scale_tb.v
vsim -voptargs=+acc work.time_scale
add wave -r /*
run -all
