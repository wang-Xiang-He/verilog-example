# run.do : ModelSim script for 12_Mux2to1
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Mux2to1.v Mux2to1_tb.v
vsim -voptargs=+acc work.Mux2to1_tb
add wave -r /*
run -all
