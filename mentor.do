
# (C) 2001-2023 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Intel 
# Program License Subscription Agreement, Intel MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Intel and sold by Intel 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ----------------------------------------
# Auto-generated simulation script msim_setup.tcl
# ----------------------------------------
# This script provides commands to simulate the following IP detected in
# your Quartus project:
#     fifo.fifo
# 
# Intel recommends that you source this Quartus-generated IP simulation
# script from your own customized top-level script, and avoid editing this
# generated script.
# 
# To write a top-level script that compiles Intel simulation libraries and
# the Quartus-generated IP in your project, along with your design and
# testbench files, copy the text from the TOP-LEVEL TEMPLATE section below
# into a new file, e.g. named "mentor.do", and modify the text as directed.
# 
# ----------------------------------------
# # TOP-LEVEL TEMPLATE - BEGIN
# #
# # QSYS_SIMDIR is used in the Quartus-generated IP simulation script to
# # construct paths to the files required to simulate the IP in your Quartus
# # project. By default, the IP script assumes that you are launching the
# # simulator from the IP script location. If launching from another
# # location, set QSYS_SIMDIR to the output directory you specified when you
# # generated the IP script, relative to the directory from which you launch
# # the simulator.
# #
# set QSYS_SIMDIR <script generation output directory>
 set QSYS_SIMDIR .
# #
# # Source the generated IP simulation script.
 source $QSYS_SIMDIR/mentor/msim_setup.tcl
# #
# # Set any compilation options you require (this is unusual).
# set USER_DEFINED_COMPILE_OPTIONS <compilation options>
# set USER_DEFINED_VHDL_COMPILE_OPTIONS <compilation options for VHDL>
# set USER_DEFINED_VERILOG_COMPILE_OPTIONS <compilation options for Verilog>
# #
# # Call command to compile the Quartus EDA simulation library.
 dev_com
# #
# # Call command to compile the Quartus-generated IP simulation files.
 com
# #
# # Add commands to compile all design files and testbench files, including
# # the top level. (These are all the files required for simulation other
# # than the files compiled by the Quartus-generated IP simulation script)
# #
# vlog <compilation options> <design and testbench files>
 vlog -work work lab2.sv
 vlog -work work lab2_tb.sv
 vlog -work work testbench.sv
# #
# # Set the top-level simulation or testbench module/entity name, which is
# # used by the elab command to elaborate the top level.
# #
# set TOP_LEVEL_NAME <simulation top>
 set TOP_LEVEL_NAME lab2_tb
# #
# # Set any elaboration options you require.
# set USER_DEFINED_ELAB_OPTIONS <elaboration options>
# #
# # Call command to elaborate your design and testbench.
 elab
# #
add wave -position insertpoint  \
sim:/tb/dut/clk \
sim:/tb/dut/reset \
sim:/tb/dut/i_valid \
sim:/tb/dut/i_x \
sim:/tb/dut/i_valid_r \
sim:/tb/dut/x
add wave -position insertpoint  \
sim:/tb/dut/fifo1_out \
sim:/tb/dut/stage1_1 \
sim:/tb/dut/stage1_2 \
sim:/tb/dut/fifo2_out \
sim:/tb/dut/stage2_1 \
sim:/tb/dut/stage2_2 \
sim:/tb/dut/fifo3_out \
sim:/tb/dut/stage3_1 \
sim:/tb/dut/stage3_2 \
sim:/tb/dut/wr \
sim:/tb/dut/rd \
sim:/tb/dut/full \
sim:/tb/dut/empty \
sim:/tb/dut/counter \
sim:/tb/dut/used_wd1 \
sim:/tb/dut/used_wd2 \
sim:/tb/dut/used_wd3 \
sim:/tb/dut/current_state

add wave -position 6  sim:/tb/dut/fifo_1/fifo_0/scfifo_component/mem_data
add wave -position 9  sim:/tb/dut/fifo_2/fifo_0/scfifo_component/mem_data
add wave -position 12  sim:/tb/dut/fifo_3/fifo_0/scfifo_component/mem_data

add wave -position insertpoint  \
sim:/lab2_tb/clk \
sim:/lab2_tb/reset
add wave -position insertpoint  \
sim:/lab2_tb/dut/wr \
sim:/lab2_tb/dut/rd \
sim:/lab2_tb/dut/full \
sim:/lab2_tb/dut/empty
add wave -position insertpoint  \
sim:/lab2_tb/dut/counter
add wave -position insertpoint  \
sim:/lab2_tb/dut/used_wd1 \
sim:/lab2_tb/dut/used_wd2 \
sim:/lab2_tb/dut/used_wd3
add wave -position insertpoint  \
sim:/lab2_tb/dut/current_state
add wave -position insertpoint  \
sim:/lab2_tb/dut/fifo1_out \
sim:/lab2_tb/dut/stage1_1 \
sim:/lab2_tb/dut/stage1_2 \
sim:/lab2_tb/dut/fifo2_out \
sim:/lab2_tb/dut/stage2_1 \
sim:/lab2_tb/dut/stage2_2 \
sim:/lab2_tb/dut/fifo3_out
sim:/lab2_tb/dut/stage3_1 \
sim:/lab2_tb/dut/stage3_2 \
add wave -position insertpoint  \
sim:/lab2_tb/dut/temp_out
add wave -position insertpoint  \
sim:/lab2_tb/dut/valid
add wave -position insertpoint  \
sim:/lab2_tb/dut/i_ready
add wave -position insertpoint  \
sim:/lab2_tb/dut/stage3_1 \
sim:/lab2_tb/dut/stage3_2

# # Run the simulation.
 run -all
# #
# # Report success to the shell.
# exit -code 0
# #
# # TOP-LEVEL TEMPLATE - END
# ----------------------------------------
# 

