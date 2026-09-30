# run.do : ModelSim script for 17_BCDadder4
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog adder4.v BCDadder4.v BCDadder4_tb.v
vsim -voptargs=+acc work.BCDadder4_tb
add wave -r /*
run -all
