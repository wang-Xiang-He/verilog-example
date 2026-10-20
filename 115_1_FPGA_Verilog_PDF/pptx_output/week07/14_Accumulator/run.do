# run.do : ModelSim script for 14_Accumulator
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Accumulator.v Accumulator_tb.v
vsim -voptargs=+acc work.Accumulator_tb
add wave -r /*
run -all
