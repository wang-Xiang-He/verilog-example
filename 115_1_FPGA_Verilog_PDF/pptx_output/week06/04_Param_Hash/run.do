# run.do : ModelSim script for 04_Param_Hash
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : Scalable.v is NOT listed in vlog. It is pulled in by `include inside Adder16.v

vlib work
vlog Adder16.v Adder16_tb.v
vsim -voptargs=+acc work.Adder16_tb
add wave -r /*
run -all
