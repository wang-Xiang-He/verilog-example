# run.do : ModelSim script for 08_System_Task
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog System_Task_tb.v
vsim -voptargs=+acc work.System_Task_tb
add wave -r /*
run -all
