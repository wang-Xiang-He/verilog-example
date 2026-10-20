# run.do : ModelSim script for 11_PPath_Delay
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog ppath_delay1.v ppath_delay1_tb.v
vsim -voptargs=+acc work.ppath_delay1_tb
add wave -r /*
run -all
