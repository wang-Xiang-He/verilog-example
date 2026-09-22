# run.do : ModelSim script for 01_FullAdd
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog FullAdd.v FullAdd_tb.v
vsim -voptargs=+acc work.FullAdd_tb
add wave -r /*
run -all
