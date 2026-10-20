# run.do : ModelSim script for 02_DFF_UDP
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog DFF_pr.v DFF_pr_tb.v
vsim -voptargs=+acc work.DFF_pr_tb
add wave -r /*
run -all
