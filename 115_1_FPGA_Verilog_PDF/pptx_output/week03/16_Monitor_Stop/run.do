# run.do : ModelSim script for 16_Monitor_Stop
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog monitest_tb.v
vsim -voptargs=+acc work.monitest
add wave -r /*
run -all
