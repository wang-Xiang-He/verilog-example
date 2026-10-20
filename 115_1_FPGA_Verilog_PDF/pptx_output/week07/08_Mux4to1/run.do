# run.do : ModelSim script for 08_Mux4to1
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Mux4to1_1.v Mux4to1_1_tb.v
vsim -voptargs=+acc work.Mux4to1_1_tb
add wave -r /*
run -all
