# (C) Copyright 2020 - 2022 Xilinx, Inc.
# SPDX-License-Identifier: Apache-2.0

# DCI_CASCADE is required since banks 66 and 67 do not have 240 ohm resistor on VRP pins
# https://support.xilinx.com/s/article/67565?language=en_US
set_property DCI_CASCADE {66 67} [get_iobanks 65] 

#MIPI Cam1
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam1_clk_p}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam1_clk_n}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam1_data_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam1_data_n[*]}]

#MIPI Cam2
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam2_clk_p}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam2_clk_n}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam2_data_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {mipi_phy_if_cam2_data_n[*]}]

#Raspi Enable Cam1
set_property PACKAGE_PIN W1 [get_ports {rpi_cam1_en}]
set_property IOSTANDARD LVCMOS12 [get_ports {rpi_cam1_en}]
set_property SLEW SLOW [get_ports {rpi_cam1_en}]
set_property DRIVE 4 [get_ports {rpi_cam1_en}]

#Raspi Enable Cam2
set_property PACKAGE_PIN K13 [get_ports {rpi_cam2_en}]
set_property IOSTANDARD LVCMOS12 [get_ports {rpi_cam2_en}]
set_property SLEW SLOW [get_ports {rpi_cam2_en}]
set_property DRIVE 4 [get_ports {rpi_cam2_en}]

#I2C signals --> RPi Camera FMC Cam1
set_property PACKAGE_PIN AC3 [get_ports iic_cam1_scl_io]
set_property PACKAGE_PIN AB3 [get_ports iic_cam1_sda_io]

#I2C signals --> RPi Camera FMC Cam2
set_property PACKAGE_PIN U6 [get_ports iic_cam2_scl_io]
set_property PACKAGE_PIN V6 [get_ports iic_cam2_sda_io]

# All I2C
set_property IOSTANDARD LVCMOS12 [get_ports iic_*]
set_property SLEW SLOW [get_ports iic_*]
set_property DRIVE 4 [get_ports iic_*]

# CAM1 and CAM3 CLK_SEL signals
set_property PACKAGE_PIN L11 [get_ports {clk_sel[0]}]; # LA25_N
set_property IOSTANDARD LVCMOS12 [get_ports {clk_sel[0]}]

set_property PACKAGE_PIN M11 [get_ports {clk_sel[1]}]; # LA25_P
set_property IOSTANDARD LVCMOS12 [get_ports {clk_sel[1]}]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

