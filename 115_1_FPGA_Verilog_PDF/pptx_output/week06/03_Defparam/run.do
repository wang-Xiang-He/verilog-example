# run.do : ModelSim script for 03_Defparam
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : Scalable.v is NOT listed in vlog. It is pulled in by `include inside Adder8.v

vlib work
vlog Adder8.v Adder8_tb.v
vsim -voptargs=+acc work.Adder8_tb
add wave -r /*
run -all
