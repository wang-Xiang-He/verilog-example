# run.do : ModelSim script for 11_Casez
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog casez_machine.v casez_machine_tb.v
vsim -voptargs=+acc work.casez_machine_tb
add wave -r /*
run -all
