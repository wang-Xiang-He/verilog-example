# run.do : ModelSim script for Q4_Bidirectional
vlib work
vmap work work
vlog Bidirectional.v Bidirectional_tb.v
vsim -voptargs=+acc work.Bidirectional_tb
add wave /Bidirectional_tb/enable_in_out /Bidirectional_tb/data_in /Bidirectional_tb/data /Bidirectional_tb/tri_inout
run -all
