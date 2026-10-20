# run.do : ModelSim script for 01_Mux4_UDP
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog mux2_1pr.v mux4_1pr.v mux4_1pr_tb.v
vsim -voptargs=+acc work.mux4_1pr_tb
add wave -r /*
run -all
