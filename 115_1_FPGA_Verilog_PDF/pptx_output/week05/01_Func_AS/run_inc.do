# run_inc.do : ModelSim script for 01_Func_AS (`include version)
# Usage      : in the Transcript window, cd to this folder, then type:  do run_inc.do
# Note       : Sub_Inc_Dec.vh is NOT listed in vlog. It is pulled in by `include inside Func_AS_inc.v

vlib work
vlog Func_AS_inc.v Func_AS_inc_tb.v
vsim -voptargs=+acc work.Func_AS_inc_tb
add wave -r /*
run -all
