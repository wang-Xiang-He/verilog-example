# run.do : ModelSim script for 09_Mux4_By_Mux2E
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : Mux2to1E.v is NOT listed in vlog. It is pulled in by `include inside Mux4x1_By_Mux2to1E.v

vlib work
vlog Mux4x1_By_Mux2to1E.v Mux4x1_By_Mux2to1E_tb.v
vsim -voptargs=+acc work.Mux4x1_By_Mux2to1E_tb
add wave -r /*
run -all
