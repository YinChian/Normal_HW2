transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Digital_Logic_Design/Normal/Homework\ 2 {D:/Digital_Logic_Design/Normal/Homework 2/hw2.v}

vlog -vlog01compat -work work +incdir+D:/Digital_Logic_Design/Normal/Homework\ 2 {D:/Digital_Logic_Design/Normal/Homework 2/hw2_tb.v}
vlog -vlog01compat -work work +incdir+D:/Digital_Logic_Design/Normal/Homework\ 2 {D:/Digital_Logic_Design/Normal/Homework 2/M25AA010A.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  hw2_tb

add wave *
view structure
view signals
run -all
