# run.do : ModelSim script for 12_DeMux1x4_By_1x2E
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do
# Note   : DeMux1to2E.v is NOT listed in vlog. It is pulled in by `include inside DeMux1x4_By_DeMux1to2E.v

vlib work
vlog DeMux1x4_By_DeMux1to2E.v DeMux1x4_By_DeMux1to2E_tb.v
vsim -voptargs=+acc work.DeMux1x4_By_DeMux1to2E_tb
add wave -r /*
run -all
