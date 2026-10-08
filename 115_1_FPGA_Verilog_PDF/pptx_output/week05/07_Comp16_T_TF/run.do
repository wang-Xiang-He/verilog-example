# run.do : ModelSim script for 07_Comp16_T_TF
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog comp16_t_tf.v comp16_t_tf_tb.v
vsim -voptargs=+acc work.comp16_t_tf_tb
add wave -r /*
run -all
