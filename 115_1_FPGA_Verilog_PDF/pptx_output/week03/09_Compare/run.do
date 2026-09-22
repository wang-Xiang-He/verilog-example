# run.do : ModelSim script for 09_Compare
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Comparator.v Comparator_tb.v
vsim -voptargs=+acc work.Comparator_tb
add wave -r /*
run -all
