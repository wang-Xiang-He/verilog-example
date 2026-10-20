# run.do : ModelSim script for 12_FCPath_Delay
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog fcpath_delay1.v fcpath_delay1_tb.v
vsim -voptargs=+acc work.fcpath_delay1_tb
add wave -r /*
run -all
