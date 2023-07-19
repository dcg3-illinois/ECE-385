transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Synchronizers.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Router.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Reg_4.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/HexDriver.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Control.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/compute.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Register_unit.sv}
vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385 {C:/Personal Stuff/School/ECE385/Processor.sv}

vlog -sv -work work +incdir+C:/Personal\ Stuff/School/ECE385/Lab2.2/.. {C:/Personal Stuff/School/ECE385/Lab2.2/../testbench_8.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
