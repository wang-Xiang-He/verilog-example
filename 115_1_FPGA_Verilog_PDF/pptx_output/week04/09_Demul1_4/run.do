# run.do : ModelSim script for 09_Demul1_4
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog demul1_4_if.v demul1_4_if_tb.v
vsim -voptargs=+acc work.demul1_4_if_tb
add wave -r /*
run -all
