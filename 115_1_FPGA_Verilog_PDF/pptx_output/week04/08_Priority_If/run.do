# run.do : ModelSim script for 08_Priority_If
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Prio_IfElse.v Prio_MultiIf.v Priority_If_tb.v
vsim -voptargs=+acc work.Priority_If_tb
add wave -r /*
run -all
