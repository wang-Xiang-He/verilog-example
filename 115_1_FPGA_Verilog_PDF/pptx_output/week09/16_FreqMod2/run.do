# run.do : ModelSim script for 16_FreqMod2
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog FreqMod2.v FreqMod2_tb.v
vsim -voptargs=+acc work.FreqMod2_tb
add wave -r /*
run -all
