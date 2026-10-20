# run.do : ModelSim script for 17_FreqModN
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog FreqModN.v FreqModN_Fix.v FreqModN_Duty50.v FreqModN_Duty50_Fix.v FreqModN_tb.v
vsim -voptargs=+acc work.FreqModN_tb
add wave -r /*
run -all
