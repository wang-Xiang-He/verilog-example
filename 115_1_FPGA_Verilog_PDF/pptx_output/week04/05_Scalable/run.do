# run.do : ModelSim script for 05_Scalable
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog ScalableDesign.v ScalableDesign_tb.v
vsim -voptargs=+acc work.ScalableDesign_tb
add wave -r /*
run -all
