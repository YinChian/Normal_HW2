transcript on
if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vlog -vlog01compat -work work +incdir+. {hw2.vo}

vlog -vlog01compat -work work +incdir+D:/Digital_Logic_Design/Normal/Homework\ 2 {D:/Digital_Logic_Design/Normal/Homework 2/hw2_tb.v}
vlog -vlog01compat -work work +incdir+D:/Digital_Logic_Design/Normal/Homework\ 2 {D:/Digital_Logic_Design/Normal/Homework 2/M25AA010A.v}

vsim -t 1ps +transport_int_delays +transport_path_delays -L altera_ver -L cycloneive_ver -L gate_work -L work -voptargs="+acc"  hw2_tb

add wave *
view structure
view signals
run -all
