# run.do : ModelSim script for 06_Decoder3to8
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog Decoder_3to8.v Decoder_3to8_tb.v
vsim -voptargs=+acc work.Decoder_3to8_tb
add wave -r /*
run -all
