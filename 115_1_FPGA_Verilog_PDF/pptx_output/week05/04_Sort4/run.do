# run.do : ModelSim script for 04_Sort4
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Sort_4_Data.v Sort_4_Data_tb.v
vsim -voptargs=+acc work.Sort_4_Data_tb
add wave -r /*
run -all
