# run.do : ModelSim script for 07_Mux2to1_4Ways
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Mux2to1_1.v Mux2to1_2.v Mux2to1_3.v Mux2to1_4.v Mux2to1_tb.v
vsim -voptargs=+acc work.Mux2to1_tb
add wave -r /*
run -all
