# run.do : ModelSim script for 05_DFF_SR
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog D_FF_SR.v D_FF_SR_tb.v
vsim -voptargs=+acc work.D_FF_SR_tb
add wave -r /*
run -all
