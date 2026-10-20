# run.do : ModelSim script for 02_Define
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : Traffic_Light.v must come first: the tb uses the `define macros it defines

vlib work
vlog Traffic_Light.v Traffic_Light_tb.v
vsim -voptargs=+acc work.Traffic_Light_tb
add wave -r /*
run -all
