# run.do : ModelSim script for 14_Bin2Gray
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog bin2gra.v bin2gra_tb.v
vsim -voptargs=+acc work.bin2gra_tb
add wave -r /*
run -all
