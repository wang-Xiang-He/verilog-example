# run.do : ModelSim script for Q3_bin2gra
vlib work
vmap work work
vlog bin2gra.v bin2gra_test.v
vsim -voptargs=+acc work.bin2gra_test
add wave -radix binary /bin2gra_test/Bin /bin2gra_test/Gry
run -all
