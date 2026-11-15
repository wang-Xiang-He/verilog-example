# run.do : ModelSim script for Q2_FPGA_LUT
vlib work
vmap work work
vlog FPGA_LUT_f.v FPGA_LUT_f_tb.v
vsim -voptargs=+acc work.FPGA_LUT_f_tb
add wave -r /*
run -all
