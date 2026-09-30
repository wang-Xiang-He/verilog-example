# run.do : ModelSim script for 04_BiDir
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog BiDir.v BiDir_tb.v
vsim -voptargs=+acc work.BiDir_tb
add wave -r /*
run -all
