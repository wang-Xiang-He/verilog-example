# run.do : ModelSim script for 07_Reg4_Async_Sync
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog RAS_NRPC.v RS_NRPC.v Reg4_tb.v
vsim -voptargs=+acc work.Reg4_tb
add wave -r /*
run -all
