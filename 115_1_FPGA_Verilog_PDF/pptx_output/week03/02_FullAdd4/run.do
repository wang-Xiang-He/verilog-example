# run.do : ModelSim script for 02_FullAdd4
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog FullAdd.v FullAdd4.v FullAdd4_tb.v
vsim -voptargs=+acc work.FullAdd4_tb
add wave -r /*
run -all
