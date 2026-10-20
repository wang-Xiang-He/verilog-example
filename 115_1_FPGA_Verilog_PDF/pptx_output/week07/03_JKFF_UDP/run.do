# run.do : ModelSim script for 03_JKFF_UDP
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog JKF_pr.v JKF_pr_tb.v
vsim -voptargs=+acc work.JKF_pr_tb
add wave -r /*
run -all
