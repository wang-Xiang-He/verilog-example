# run.do : ModelSim script for 04_DFF_PR
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog D_FF_PR.v D_FF_PR_tb.v
vsim -voptargs=+acc work.D_FF_PR_tb
add wave -r /*
run -all
