# (C) Copyright 2020 - 2022 Xilinx, Inc.
# SPDX-License-Identifier: Apache-2.0

# DCI_CASCADE is required since banks 67 does not have 240 ohm resistor on VRP pin
# https://support.xilinx.com/s/article/67565?language=en_US
set_property DCI_CASCADE {67} [get_iobanks 68] 

#MIPI
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_clk_p}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_clk_n}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_data_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_data_n[*]}]

#Raspi Enable HDA09
set_property PACKAGE_PIN G16 [get_ports {raspi_enable}]
set_property IOSTANDARD LVCMOS12 [get_ports {raspi_enable}]
set_property SLEW SLOW [get_ports {raspi_enable}]
set_property DRIVE 4 [get_ports {raspi_enable}]

#I2C signals --> RPi Camera
set_property PACKAGE_PIN J17 [get_ports iic_scl_io]
set_property PACKAGE_PIN K17 [get_ports iic_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports iic_*]
set_property SLEW SLOW [get_ports iic_*]
set_property DRIVE 4 [get_ports iic_*]

# CAM1 and CAM3 CLK_SEL signals
set_property PACKAGE_PIN C6 [get_ports {clk_sel[0]}]; # LA25_N
set_property IOSTANDARD LVCMOS12 [get_ports {clk_sel[0]}]

set_property PACKAGE_PIN C7 [get_ports {clk_sel[1]}]; # LA25_P
set_property IOSTANDARD LVCMOS12 [get_ports {clk_sel[1]}]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

