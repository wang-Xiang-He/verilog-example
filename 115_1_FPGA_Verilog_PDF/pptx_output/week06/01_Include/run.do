# run.do : ModelSim script for 01_Include
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : FullAdd.v is NOT listed in vlog. It is pulled in by `include inside FullAdd4.v

vlib work
vlog FullAdd4.v FullAdd4_tb.v
vsim -voptargs=+acc work.FullAdd4_tb
add wave -r /*
run -all
