# run.do : ModelSim script for 05_DFF_Sel
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog dff.v mux2_1.v dff_sel.v dff_sel_tb.v
vsim -voptargs=+acc work.dff_sel_tb
add wave -r /*
run -all
