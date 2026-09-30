# run.do : ModelSim script for 12_TwosComp
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog TwosComp.v TwosComp_tb.v
vsim -voptargs=+acc work.TwosComp_tb
add wave -r /*
run -all
