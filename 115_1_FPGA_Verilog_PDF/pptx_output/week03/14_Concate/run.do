# run.do : ModelSim script for 14_Concate
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Concate.v Concate_tb.v
vsim -voptargs=+acc work.Concate_tb
add wave -r /*
run -all
