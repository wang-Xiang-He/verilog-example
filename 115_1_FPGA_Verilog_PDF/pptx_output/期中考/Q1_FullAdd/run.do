# run.do : ModelSim script for Q1_FullAdd
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vmap work work
vlog FullAdd.v FullAdd_test.v
vsim -voptargs=+acc work.FullAdd_test
add wave -r /*
run -all
