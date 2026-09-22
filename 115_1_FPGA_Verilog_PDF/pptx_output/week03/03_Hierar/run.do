# run.do : ModelSim script for 03_Hierar
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Mux.v Register8.v Rotate_Data.v Top1.v Top2.v Hierar_tb.v
vsim -voptargs=+acc work.Hierar_tb
add wave -r /*
run -all
