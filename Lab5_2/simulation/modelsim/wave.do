onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /testbench/Clk
add wave -noupdate /testbench/Continue
add wave -noupdate /testbench/Run
add wave -noupdate /testbench/Switches
add wave -noupdate /testbench/LED
add wave -noupdate /testbench/HEX0
add wave -noupdate /testbench/HEX1
add wave -noupdate /testbench/HEX2
add wave -noupdate /testbench/HEX3
add wave -noupdate -radix hexadecimal /testbench/IR
add wave -noupdate -radix hexadecimal /testbench/PC
add wave -noupdate -radix hexadecimal /testbench/R1
add wave -noupdate -radix hexadecimal /testbench/MAR
add wave -noupdate -radix hexadecimal /testbench/MDR
add wave -noupdate -radix hexadecimal /testbench/BUS
add wave -noupdate -radix hexadecimal /testbench/ADDR2MUX_out
add wave -noupdate -radix hexadecimal /testbench/ADDR1MUX_out
add wave -noupdate -radix hexadecimal /testbench/ADDR_out
add wave -noupdate /testbench/state
add wave -noupdate /testbench/DRMUX_out
add wave -noupdate /testbench/SR1MUX_out
add wave -noupdate /testbench/topLev/slc/state_controller/SR2MUX
add wave -noupdate /testbench/topLev/slc/state_controller/State
add wave -noupdate /testbench/topLev/slc/nzp_reg/N
add wave -noupdate /testbench/topLev/slc/nzp_reg/Z
add wave -noupdate /testbench/topLev/slc/nzp_reg/P
add wave -noupdate /testbench/topLev/slc/BEN_ff/data_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r0_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r1_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r2_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r3_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r4_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r5_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r6_out
add wave -noupdate -radix hexadecimal /testbench/topLev/slc/reg_u/r7_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {9999050 ps} {10000050 ps}
