# run.do : ModelSim script for 01_Latch_RS
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Latch_RS.v Latch_RS_tb.v
vsim -voptargs=+acc work.Latch_RS_tb
add wave -r /*
run -all
