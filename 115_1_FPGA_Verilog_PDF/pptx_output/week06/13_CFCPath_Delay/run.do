# run.do : ModelSim script for 13_CFCPath_Delay
# Usage  : in the Transcript window, cd to this folder, then type:  do run.do

vlib work
vlog cfcpath_delay.v cfcpath_delay_tb.v
vsim -voptargs=+acc work.cfcpath_delay_tb
add wave -r /*
run -all
