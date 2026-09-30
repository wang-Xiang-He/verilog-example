# run.do : ModelSim script for 10_Case_Casex
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Case_Prio.v Mux_Case.v Casex_Prio.v Case_tb.v
vsim -voptargs=+acc work.Case_tb
add wave -r /*
run -all
