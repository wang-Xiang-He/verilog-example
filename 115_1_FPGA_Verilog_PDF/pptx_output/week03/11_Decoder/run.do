# run.do : ModelSim script for 11_Decoder
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Decoder.v Decoder_tb.v
vsim -voptargs=+acc work.Decoder_tb
add wave -r /*
run -all
