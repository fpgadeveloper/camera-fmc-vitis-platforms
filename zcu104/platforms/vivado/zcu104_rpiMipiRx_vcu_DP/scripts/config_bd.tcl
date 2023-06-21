set ::PS_INST PS_0
set PS_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e PS_0 ]


apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells PS_0]


set_property -dict [ list \
CONFIG.PSU__CRF_APB__DPLL_FRAC_CFG__ENABLED  {0} \
CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED  {0} \
CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {1} \
CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} \
CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
CONFIG.PSU__FPGA_PL0_ENABLE {1} \
CONFIG.PSU__FPGA_PL1_ENABLE {1} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {92} \
CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
CONFIG.PSU__TTC0__WAVEOUT__IO {EMIO} \
CONFIG.PSU__MAXIGP0__DATA_WIDTH {32} \
CONFIG.PSU__MAXIGP1__DATA_WIDTH {32} \
CONFIG.PSU__MAXIGP2__DATA_WIDTH {32} \
CONFIG.PSU__NUM_FABRIC_RESETS {2} \
CONFIG.PSU__SAXIGP0__DATA_WIDTH {128} \
CONFIG.PSU__SAXIGP1__DATA_WIDTH {128} \
CONFIG.PSU__SAXIGP2__DATA_WIDTH {64} \
CONFIG.PSU__SAXIGP3__DATA_WIDTH {128} \
CONFIG.PSU__SAXIGP4__DATA_WIDTH {128} \
CONFIG.PSU__SAXIGP5__DATA_WIDTH {128} \
CONFIG.PSU__SAXIGP6__DATA_WIDTH {128} \
CONFIG.PSU__USE__IRQ0 {1} \
CONFIG.PSU__USE__IRQ1 {1} \
CONFIG.PSU__USE__M_AXI_GP0 {1} \
CONFIG.PSU__USE__M_AXI_GP1 {1} \
CONFIG.PSU__USE__M_AXI_GP2 {1} \
CONFIG.PSU__USE__S_AXI_ACE {0} \
CONFIG.PSU__USE__S_AXI_ACP {0} \
CONFIG.PSU__USE__S_AXI_GP0 {1} \
CONFIG.PSU__USE__S_AXI_GP1 {1} \
CONFIG.PSU__USE__S_AXI_GP2 {1} \
CONFIG.PSU__USE__S_AXI_GP3 {1} \
CONFIG.PSU__USE__S_AXI_GP4 {1} \
CONFIG.PSU__USE__S_AXI_GP5 {1} \
CONFIG.PSU__USE__S_AXI_GP6 {1} \
] $PS_0

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: vcu
proc create_hier_cell_vcu { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_vcu() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_VCU_DEC

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_VCU_EN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_VCU_MCU

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE


  # Create pins
  create_bd_pin -dir I -from 91 -to 0 Din
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I -type clk m_axi_dec_aclk
  create_bd_pin -dir I -type clk pll_ref_clk
  create_bd_pin -dir I -type clk s_axi_lite_aclk
  create_bd_pin -dir O -type intr vcu_host_interrupt

  # Create instance: axi_ic_vcu_dec, and set properties
  set axi_ic_vcu_dec [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_vcu_dec ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {1} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_REGSLICE {1} \
   CONFIG.S01_HAS_REGSLICE {1} \
 ] $axi_ic_vcu_dec

  # Create instance: axi_ic_vcu_enc, and set properties
  set axi_ic_vcu_enc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_vcu_enc ]
  set_property -dict [ list \
   CONFIG.M00_HAS_REGSLICE {1} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_REGSLICE {1} \
   CONFIG.S01_HAS_REGSLICE {1} \
 ] $axi_ic_vcu_enc

  # Create instance: axi_reg_slice_vmcu, and set properties
  set axi_reg_slice_vmcu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_register_slice:2.1 axi_reg_slice_vmcu ]

  # Create instance: vcu_0, and set properties
  set vcu_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vcu:1.2 vcu_0 ]
  set_property -dict [ list \
   CONFIG.DEC_CODING_TYPE {0} \
   CONFIG.DEC_COLOR_DEPTH {0} \
   CONFIG.DEC_COLOR_FORMAT {0} \
   CONFIG.DEC_FPS {1} \
   CONFIG.DEC_FRAME_SIZE {4} \
   CONFIG.ENABLE_DECODER {true} \
   CONFIG.ENC_BUFFER_EN {true} \
   CONFIG.ENC_BUFFER_MANUAL_OVERRIDE {1} \
   CONFIG.ENC_BUFFER_SIZE {253} \
   CONFIG.ENC_BUFFER_SIZE_ACTUAL {284} \
   CONFIG.ENC_BUFFER_TYPE {0} \
   CONFIG.ENC_CODING_TYPE {1} \
   CONFIG.ENC_COLOR_DEPTH {0} \
   CONFIG.ENC_COLOR_FORMAT {0} \
   CONFIG.ENC_FPS {1} \
   CONFIG.ENC_FRAME_SIZE {4} \
   CONFIG.ENC_MEM_BRAM_USED {0} \
   CONFIG.ENC_MEM_URAM_USED {284} \
   CONFIG.NO_OF_DEC_STREAMS {1} \
   CONFIG.NO_OF_STREAMS {1} \
   CONFIG.TABLE_NO {2} \
 ] $vcu_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {92} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_ic_vcu_enc/S00_AXI] [get_bd_intf_pins vcu_0/M_AXI_ENC0]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_ic_vcu_dec/S00_AXI] [get_bd_intf_pins vcu_0/M_AXI_DEC0]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins axi_ic_vcu_enc/S01_AXI] [get_bd_intf_pins vcu_0/M_AXI_ENC1]
  connect_bd_intf_net -intf_net S01_AXI_2 [get_bd_intf_pins axi_ic_vcu_dec/S01_AXI] [get_bd_intf_pins vcu_0/M_AXI_DEC1]
  connect_bd_intf_net -intf_net axi_ic_vcu_dec_M00_AXI [get_bd_intf_pins M00_AXI_VCU_DEC] [get_bd_intf_pins axi_ic_vcu_dec/M00_AXI]
  connect_bd_intf_net -intf_net axi_ic_vcu_enc_M00_AXI [get_bd_intf_pins M00_AXI_VCU_EN] [get_bd_intf_pins axi_ic_vcu_enc/M00_AXI]
  connect_bd_intf_net -intf_net axi_register_slice_0_M_AXI [get_bd_intf_pins M_AXI_VCU_MCU] [get_bd_intf_pins axi_reg_slice_vmcu/M_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins vcu_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net vcu_0_M_AXI_MCU [get_bd_intf_pins axi_reg_slice_vmcu/S_AXI] [get_bd_intf_pins vcu_0/M_AXI_MCU]

  # Create port connections
  connect_bd_net -net Din_1 [get_bd_pins Din] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net clk_wiz_0_clk_100M [get_bd_pins s_axi_lite_aclk] [get_bd_pins vcu_0/s_axi_lite_aclk]
  connect_bd_net -net clk_wiz_0_clk_300M [get_bd_pins m_axi_dec_aclk] [get_bd_pins axi_ic_vcu_dec/ACLK] [get_bd_pins axi_ic_vcu_dec/M00_ACLK] [get_bd_pins axi_ic_vcu_dec/S00_ACLK] [get_bd_pins axi_ic_vcu_dec/S01_ACLK] [get_bd_pins axi_ic_vcu_enc/ACLK] [get_bd_pins axi_ic_vcu_enc/M00_ACLK] [get_bd_pins axi_ic_vcu_enc/S00_ACLK] [get_bd_pins axi_ic_vcu_enc/S01_ACLK] [get_bd_pins axi_reg_slice_vmcu/aclk] [get_bd_pins vcu_0/m_axi_dec_aclk] [get_bd_pins vcu_0/m_axi_enc_aclk] [get_bd_pins vcu_0/m_axi_mcu_aclk]
  connect_bd_net -net clk_wiz_0_clk_50M [get_bd_pins pll_ref_clk] [get_bd_pins vcu_0/pll_ref_clk]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins axi_ic_vcu_dec/ARESETN] [get_bd_pins axi_ic_vcu_dec/M00_ARESETN] [get_bd_pins axi_ic_vcu_dec/S00_ARESETN] [get_bd_pins axi_ic_vcu_dec/S01_ARESETN] [get_bd_pins axi_ic_vcu_enc/ARESETN] [get_bd_pins axi_ic_vcu_enc/M00_ARESETN] [get_bd_pins axi_ic_vcu_enc/S00_ARESETN] [get_bd_pins axi_ic_vcu_enc/S01_ARESETN] [get_bd_pins axi_reg_slice_vmcu/aresetn]
  connect_bd_net -net vcu_0_vcu_host_interrupt [get_bd_pins vcu_host_interrupt] [get_bd_pins vcu_0/vcu_host_interrupt]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins vcu_0/vcu_resetn] [get_bd_pins xlslice_0/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: raspi_pipeline
proc create_hier_cell_raspi_pipeline { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_raspi_pipeline() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 csirxss_s_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_mm_video

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_dem

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_frmbuf

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_ctrl_vpss


  # Create pins
  create_bd_pin -dir I -from 91 -to 0 Din
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I bg0_pin6_nc_0
  create_bd_pin -dir I bg1_pin6_nc_0
  create_bd_pin -dir O -type intr csirxss_csi_irq
  create_bd_pin -dir O -type intr dem_irq
  create_bd_pin -dir I -type clk dphy_clk_200M
  create_bd_pin -dir O -type intr frm_buf_irq
  create_bd_pin -dir I -type clk lite_aclk
  create_bd_pin -dir I -type rst lite_aresetn

  # Create instance: ISPPipeline_accel_0, and set properties
  set ISPPipeline_accel_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:ISPPipeline_accel:1.0 ISPPipeline_accel_0 ]

  # Create instance: mipi_csi2_rx_subsyst_0, and set properties
  set mipi_csi2_rx_subsyst_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_rx_subsystem:5.1 mipi_csi2_rx_subsyst_0 ]
  set_property -dict [ list \
   CONFIG.AXIS_TDEST_WIDTH {4} \
   CONFIG.CLK_LANE_IO_LOC {H18} \
   CONFIG.CLK_LANE_IO_LOC_NAME {IO_L16P_T2U_N6_QBC_AD3P_67} \
   CONFIG.CMN_NUM_LANES {2} \
   CONFIG.CMN_NUM_PIXELS {1} \
   CONFIG.CMN_PXL_FORMAT {RAW10} \
   CONFIG.CMN_VC {All} \
   CONFIG.CSI_BUF_DEPTH {512} \
   CONFIG.C_CLK_LANE_IO_POSITION {32} \
   CONFIG.C_CSI_EN_ACTIVELANES {false} \
   CONFIG.C_CSI_EN_CRC {false} \
   CONFIG.C_CSI_FILTER_USERDATATYPE {false} \
   CONFIG.C_DATA_LANE0_IO_POSITION {13} \
   CONFIG.C_DATA_LANE1_IO_POSITION {10} \
   CONFIG.C_DPHY_LANES {2} \
   CONFIG.C_EN_BG0_PIN0 {false} \
   CONFIG.C_EN_BG0_PIN6 {true} \
   CONFIG.C_EN_BG1_PIN0 {false} \
   CONFIG.C_EN_BG1_PIN6 {true} \
   CONFIG.C_EN_BG3_PIN6 {false} \
   CONFIG.C_EN_CSI_V2_0 {false} \
   CONFIG.C_HS_LINE_RATE {912} \
   CONFIG.C_HS_SETTLE_NS {145} \
   CONFIG.C_STRETCH_LINE_RATE {1500} \
   CONFIG.DATA_LANE0_IO_LOC {D16} \
   CONFIG.DATA_LANE0_IO_LOC_NAME {IO_L7P_T1L_N0_QBC_AD13P_67} \
   CONFIG.DATA_LANE1_IO_LOC {C13} \
   CONFIG.DATA_LANE1_IO_LOC_NAME {IO_L6P_T0U_N10_AD6P_67} \
   CONFIG.DPY_EN_REG_IF {true} \
   CONFIG.DPY_LINE_RATE {912} \
   CONFIG.HP_IO_BANK_SELECTION {67} \
   CONFIG.SupportLevel {1} \
 ] $mipi_csi2_rx_subsyst_0

  # Create instance: v_frmbuf_wr_0, and set properties
  set v_frmbuf_wr_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_frmbuf_wr:2.4 v_frmbuf_wr_0 ]
  set_property -dict [ list \
   CONFIG.AXIMM_DATA_WIDTH {64} \
   CONFIG.C_M_AXI_MM_VIDEO_DATA_WIDTH {64} \
   CONFIG.HAS_BGR8 {1} \
   CONFIG.HAS_BGRX8 {0} \
   CONFIG.HAS_RGB8 {1} \
   CONFIG.HAS_UYVY8 {0} \
   CONFIG.HAS_YUV8 {0} \
   CONFIG.HAS_Y_UV8 {0} \
   CONFIG.HAS_Y_UV8_420 {1} \
   CONFIG.MAX_COLS {1920} \
   CONFIG.MAX_NR_PLANES {2} \
   CONFIG.MAX_ROWS {1080} \
   CONFIG.SAMPLES_PER_CLOCK {1} \
 ] $v_frmbuf_wr_0

  # Create instance: v_proc_ss_0, and set properties
  set v_proc_ss_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_proc_ss:2.3 v_proc_ss_0 ]
  set_property -dict [ list \
   CONFIG.C_COLORSPACE_SUPPORT {0} \
   CONFIG.C_ENABLE_CSC {true} \
   CONFIG.C_MAX_COLS {1920} \
   CONFIG.C_MAX_DATA_WIDTH {8} \
   CONFIG.C_MAX_ROWS {1080} \
   CONFIG.C_SAMPLES_PER_CLK {1} \
   CONFIG.C_TOPOLOGY {0} \
 ] $v_proc_ss_0

  # Create instance: xlslice_4, and set properties
  set xlslice_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_4 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {4} \
   CONFIG.DIN_TO {4} \
   CONFIG.DIN_WIDTH {92} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_4

  # Create instance: xlslice_5, and set properties
  set xlslice_5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_5 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {5} \
   CONFIG.DIN_TO {5} \
   CONFIG.DIN_WIDTH {92} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_5

  # Create instance: xlslice_6, and set properties
  set xlslice_6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_6 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {6} \
   CONFIG.DIN_TO {6} \
   CONFIG.DIN_WIDTH {92} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_6

  # Create interface connections
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins s_axi_ctrl_vpss] [get_bd_intf_pins v_proc_ss_0/s_axi_ctrl]
  connect_bd_intf_net -intf_net ISPPipeline_accel_0_m_axis_video [get_bd_intf_pins ISPPipeline_accel_0/m_axis_video] [get_bd_intf_pins v_proc_ss_0/s_axis]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins csirxss_s_axi] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/csirxss_s_axi]
  connect_bd_intf_net -intf_net axi_interconnect_0_M11_AXI [get_bd_intf_pins s_axi_ctrl_frmbuf] [get_bd_intf_pins v_frmbuf_wr_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net mipi_csi2_rx_subsyst_0_video_out [get_bd_intf_pins ISPPipeline_accel_0/s_axis_video] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/video_out]
  connect_bd_intf_net -intf_net mipi_phy_if_1 [get_bd_intf_pins mipi_phy_if] [get_bd_intf_pins mipi_csi2_rx_subsyst_0/mipi_phy_if]
  connect_bd_intf_net -intf_net s_axi_ctrl_dem_1 [get_bd_intf_pins s_axi_ctrl_dem] [get_bd_intf_pins ISPPipeline_accel_0/s_axi_CTRL]
  connect_bd_intf_net -intf_net v_frmbuf_wr_1_m_axi_mm_video [get_bd_intf_pins m_axi_mm_video] [get_bd_intf_pins v_frmbuf_wr_0/m_axi_mm_video]
  connect_bd_intf_net -intf_net v_proc_ss_0_m_axis [get_bd_intf_pins v_frmbuf_wr_0/s_axis_video] [get_bd_intf_pins v_proc_ss_0/m_axis]

  # Create port connections
  connect_bd_net -net Din_1 [get_bd_pins Din] [get_bd_pins xlslice_4/Din] [get_bd_pins xlslice_5/Din] [get_bd_pins xlslice_6/Din]
  connect_bd_net -net ISPPipeline_accel_0_interrupt [get_bd_pins dem_irq] [get_bd_pins ISPPipeline_accel_0/interrupt]
  connect_bd_net -net bg0_pin6_nc_0_1 [get_bd_pins bg0_pin6_nc_0] [get_bd_pins mipi_csi2_rx_subsyst_0/bg0_pin6_nc]
  connect_bd_net -net bg1_pin6_nc_0_1 [get_bd_pins bg1_pin6_nc_0] [get_bd_pins mipi_csi2_rx_subsyst_0/bg1_pin6_nc]
  connect_bd_net -net clk_wiz_0_clk_100M [get_bd_pins lite_aclk] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aclk]
  connect_bd_net -net clk_wiz_0_clk_200M [get_bd_pins dphy_clk_200M] [get_bd_pins mipi_csi2_rx_subsyst_0/dphy_clk_200M]
  connect_bd_net -net clk_wiz_0_clk_300M [get_bd_pins aclk] [get_bd_pins ISPPipeline_accel_0/ap_clk] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aclk] [get_bd_pins v_frmbuf_wr_0/ap_clk] [get_bd_pins v_proc_ss_0/aclk_axis] [get_bd_pins v_proc_ss_0/aclk_ctrl]
  connect_bd_net -net mipi_csi2_rx_subsyst_0_csirxss_csi_irq [get_bd_pins csirxss_csi_irq] [get_bd_pins mipi_csi2_rx_subsyst_0/csirxss_csi_irq]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins mipi_csi2_rx_subsyst_0/video_aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn [get_bd_pins lite_aresetn] [get_bd_pins mipi_csi2_rx_subsyst_0/lite_aresetn]
  connect_bd_net -net v_frmbuf_wr_1_interrupt [get_bd_pins frm_buf_irq] [get_bd_pins v_frmbuf_wr_0/interrupt]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins v_proc_ss_0/aresetn_ctrl] [get_bd_pins xlslice_5/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins v_frmbuf_wr_0/ap_rst_n] [get_bd_pins xlslice_6/Dout]
  connect_bd_net -net xlslice_4_Dout [get_bd_pins ISPPipeline_accel_0/ap_rst_n] [get_bd_pins xlslice_4/Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 iic ]

  set mipi_phy_if [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_phy_if ]


  # Create ports
  set bg0_pin6_nc_0 [ create_bd_port -dir I bg0_pin6_nc_0 ]
  set bg1_pin6_nc_0 [ create_bd_port -dir I bg1_pin6_nc_0 ]
  set clk_sel [ create_bd_port -dir O -from 1 -to 0 clk_sel ]
  set raspi_enable [ create_bd_port -dir O -from 0 -to 0 raspi_enable ]

  # Create instance: axi_ic_accel_ctrl, and set properties
  set axi_ic_accel_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_accel_ctrl ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.S00_HAS_REGSLICE {1} \
 ] $axi_ic_accel_ctrl

  # Create instance: axi_ic_ctrl_100, and set properties
  set axi_ic_ctrl_100 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_ctrl_100 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.NUM_MI {3} \
   CONFIG.S00_HAS_REGSLICE {1} \
 ] $axi_ic_ctrl_100

  # Create instance: axi_ic_ctrl_300, and set properties
  set axi_ic_ctrl_300 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_ctrl_300 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {3} \
 ] $axi_ic_ctrl_300

  # Create instance: axi_ic_mcu, and set properties
  set axi_ic_mcu [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_ic_mcu ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_ic_mcu

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.1 axi_iic_0 ]
  set_property -dict [ list \
   CONFIG.IIC_FREQ_KHZ {400} \
 ] $axi_iic_0

  # Create instance: axi_vip_0, and set properties
  set axi_vip_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0 ]
  set_property -dict [ list \
   CONFIG.INTERFACE_MODE {SLAVE} \
 ] $axi_vip_0

  # Create instance: clk_sel, and set properties
  set clk_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 clk_sel ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {2} \
   CONFIG.CONST_WIDTH {2} \
 ] $clk_sel

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {102.096} \
   CONFIG.CLKOUT1_PHASE_ERROR {87.187} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT2_JITTER {115.843} \
   CONFIG.CLKOUT2_PHASE_ERROR {87.187} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_JITTER {102.096} \
   CONFIG.CLKOUT3_MATCHED_ROUTING {true} \
   CONFIG.CLKOUT3_PHASE_ERROR {87.187} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {200.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_JITTER {132.698} \
   CONFIG.CLKOUT4_PHASE_ERROR {87.187} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {50.000} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_JITTER {90.083} \
   CONFIG.CLKOUT5_MATCHED_ROUTING {true} \
   CONFIG.CLKOUT5_PHASE_ERROR {87.187} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {400.000} \
   CONFIG.CLKOUT5_USED {true} \
   CONFIG.CLK_OUT1_PORT {clk_200M} \
   CONFIG.CLK_OUT2_PORT {clk_100M} \
   CONFIG.CLK_OUT3_PORT {clkv_200M} \
   CONFIG.CLK_OUT4_PORT {clk_50M} \
   CONFIG.CLK_OUT5_PORT {clk_400M} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {6} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {24} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {3} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {5} \
   CONFIG.PRIM_SOURCE {Global_buffer} \
   CONFIG.RESET_PORT {resetn} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
 ] $clk_wiz_0

  # Create instance: proc_sys_reset_100MHz, and set properties
  set proc_sys_reset_100MHz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_100MHz ]

  # Create instance: proc_sys_reset_200MHz, and set properties
  set proc_sys_reset_200MHz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_200MHz ]

  # Create instance: proc_sys_reset_400MHz, and set properties
  set proc_sys_reset_400MHz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_400MHz ]

  # Create instance: raspi_pipeline
  create_hier_cell_raspi_pipeline [current_bd_instance .] raspi_pipeline

  # Create instance: vcu
  create_hier_cell_vcu [current_bd_instance .] vcu

  # Create instance: xlconcat_0_0, and set properties
  set xlconcat_0_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {5} \
 ] $xlconcat_0_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net PS_0_M_AXI_HPM0_FPD [get_bd_intf_pins PS_0/M_AXI_HPM0_FPD] [get_bd_intf_pins axi_ic_accel_ctrl/S00_AXI]
  connect_bd_intf_net -intf_net PS_0_M_AXI_HPM1_FPD [get_bd_intf_pins PS_0/M_AXI_HPM1_FPD] [get_bd_intf_pins axi_ic_ctrl_300/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins PS_0/M_AXI_HPM0_LPD] [get_bd_intf_pins axi_ic_ctrl_100/S00_AXI]
  connect_bd_intf_net -intf_net axi_ic_accel_ctrl_M00_AXI [get_bd_intf_pins axi_ic_accel_ctrl/M00_AXI] [get_bd_intf_pins axi_vip_0/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_ctrl_100_M02_AXI [get_bd_intf_pins axi_ic_ctrl_100/M02_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
  connect_bd_intf_net -intf_net axi_ic_ctrl_300_M01_AXI [get_bd_intf_pins axi_ic_ctrl_300/M01_AXI] [get_bd_intf_pins raspi_pipeline/s_axi_ctrl_dem]
  connect_bd_intf_net -intf_net axi_ic_ctrl_300_M02_AXI [get_bd_intf_pins axi_ic_ctrl_300/M02_AXI] [get_bd_intf_pins raspi_pipeline/s_axi_ctrl_vpss]
  connect_bd_intf_net -intf_net axi_ic_mcu_M00_AXI [get_bd_intf_pins PS_0/S_AXI_LPD] [get_bd_intf_pins axi_ic_mcu/M00_AXI]
  connect_bd_intf_net -intf_net axi_iic_0_IIC [get_bd_intf_ports iic] [get_bd_intf_pins axi_iic_0/IIC]
  connect_bd_intf_net -intf_net axi_interconnect_ctrl_100_M01_AXI [get_bd_intf_pins axi_ic_ctrl_100/M01_AXI] [get_bd_intf_pins vcu/S_AXI_LITE]
  connect_bd_intf_net -intf_net csirxss_s_axi_1 [get_bd_intf_pins axi_ic_ctrl_100/M00_AXI] [get_bd_intf_pins raspi_pipeline/csirxss_s_axi]
  connect_bd_intf_net -intf_net mipi_phy_if_1 [get_bd_intf_ports mipi_phy_if] [get_bd_intf_pins raspi_pipeline/mipi_phy_if]
  connect_bd_intf_net -intf_net raspi_pipeline_m_axi_mm_video [get_bd_intf_pins PS_0/S_AXI_HP0_FPD] [get_bd_intf_pins raspi_pipeline/m_axi_mm_video]
  connect_bd_intf_net -intf_net s_axi_ctrl_frmbuf_1 [get_bd_intf_pins axi_ic_ctrl_300/M00_AXI] [get_bd_intf_pins raspi_pipeline/s_axi_ctrl_frmbuf]
  connect_bd_intf_net -intf_net vcu_M00_AXI_VCU_DEC [get_bd_intf_pins PS_0/S_AXI_HPC0_FPD] [get_bd_intf_pins vcu/M00_AXI_VCU_EN]
  connect_bd_intf_net -intf_net vcu_M00_AXI_VCU_EN [get_bd_intf_pins PS_0/S_AXI_HP2_FPD] [get_bd_intf_pins vcu/M00_AXI_VCU_DEC]
  connect_bd_intf_net -intf_net vcu_M_AXI_VCU_MCU [get_bd_intf_pins axi_ic_mcu/S00_AXI] [get_bd_intf_pins vcu/M_AXI_VCU_MCU]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_ic_ctrl_100/ARESETN] [get_bd_pins proc_sys_reset_100MHz/interconnect_aresetn]
  connect_bd_net -net PS_0_emio_gpio_o [get_bd_pins PS_0/emio_gpio_o] [get_bd_pins raspi_pipeline/Din] [get_bd_pins vcu/Din]
  connect_bd_net -net PS_0_pl_clk0 [get_bd_pins PS_0/pl_clk0] [get_bd_pins clk_wiz_0/clk_in1]
  connect_bd_net -net PS_0_pl_resetn0 [get_bd_pins PS_0/pl_resetn0] [get_bd_pins clk_wiz_0/resetn] [get_bd_pins proc_sys_reset_100MHz/ext_reset_in] [get_bd_pins proc_sys_reset_200MHz/ext_reset_in] [get_bd_pins proc_sys_reset_400MHz/ext_reset_in]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins axi_iic_0/iic2intc_irpt] [get_bd_pins xlconcat_0_0/In3]
  connect_bd_net -net bg0_pin6_nc_0_1 [get_bd_ports bg0_pin6_nc_0] [get_bd_pins raspi_pipeline/bg0_pin6_nc_0]
  connect_bd_net -net bg1_pin6_nc_0_1 [get_bd_ports bg1_pin6_nc_0] [get_bd_pins raspi_pipeline/bg1_pin6_nc_0]
  connect_bd_net -net clk_sel_dout [get_bd_ports clk_sel] [get_bd_pins clk_sel/dout]
  connect_bd_net -net clk_wiz_0_clk_100M [get_bd_pins PS_0/maxihpm0_lpd_aclk] [get_bd_pins axi_ic_ctrl_100/ACLK] [get_bd_pins axi_ic_ctrl_100/M00_ACLK] [get_bd_pins axi_ic_ctrl_100/M01_ACLK] [get_bd_pins axi_ic_ctrl_100/M02_ACLK] [get_bd_pins axi_ic_ctrl_100/S00_ACLK] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins clk_wiz_0/clk_100M] [get_bd_pins proc_sys_reset_100MHz/slowest_sync_clk] [get_bd_pins raspi_pipeline/lite_aclk] [get_bd_pins vcu/s_axi_lite_aclk]
  connect_bd_net -net clk_wiz_0_clk_200M [get_bd_pins clk_wiz_0/clk_200M] [get_bd_pins raspi_pipeline/dphy_clk_200M]
  connect_bd_net -net clk_wiz_0_clk_300M [get_bd_pins PS_0/maxihpm0_fpd_aclk] [get_bd_pins PS_0/maxihpm1_fpd_aclk] [get_bd_pins PS_0/saxi_lpd_aclk] [get_bd_pins PS_0/saxihp0_fpd_aclk] [get_bd_pins PS_0/saxihp1_fpd_aclk] [get_bd_pins PS_0/saxihp2_fpd_aclk] [get_bd_pins PS_0/saxihp3_fpd_aclk] [get_bd_pins PS_0/saxihpc0_fpd_aclk] [get_bd_pins PS_0/saxihpc1_fpd_aclk] [get_bd_pins axi_ic_accel_ctrl/ACLK] [get_bd_pins axi_ic_accel_ctrl/M00_ACLK] [get_bd_pins axi_ic_accel_ctrl/S00_ACLK] [get_bd_pins axi_ic_ctrl_300/ACLK] [get_bd_pins axi_ic_ctrl_300/M00_ACLK] [get_bd_pins axi_ic_ctrl_300/M01_ACLK] [get_bd_pins axi_ic_ctrl_300/M02_ACLK] [get_bd_pins axi_ic_ctrl_300/S00_ACLK] [get_bd_pins axi_ic_mcu/ACLK] [get_bd_pins axi_ic_mcu/M00_ACLK] [get_bd_pins axi_ic_mcu/S00_ACLK] [get_bd_pins axi_vip_0/aclk] [get_bd_pins clk_wiz_0/clkv_200M] [get_bd_pins proc_sys_reset_200MHz/slowest_sync_clk] [get_bd_pins raspi_pipeline/aclk] [get_bd_pins vcu/m_axi_dec_aclk]
  connect_bd_net -net clk_wiz_0_clk_400M [get_bd_pins clk_wiz_0/clk_400M] [get_bd_pins proc_sys_reset_400MHz/slowest_sync_clk]
  connect_bd_net -net clk_wiz_0_clk_50M [get_bd_pins clk_wiz_0/clk_50M] [get_bd_pins vcu/pll_ref_clk]
  connect_bd_net -net clk_wiz_0_locked [get_bd_pins clk_wiz_0/locked] [get_bd_pins proc_sys_reset_100MHz/dcm_locked] [get_bd_pins proc_sys_reset_200MHz/dcm_locked] [get_bd_pins proc_sys_reset_400MHz/dcm_locked]
  connect_bd_net -net proc_sys_reset_1_interconnect_aresetn [get_bd_pins axi_ic_accel_ctrl/ARESETN] [get_bd_pins axi_ic_ctrl_300/ARESETN] [get_bd_pins axi_ic_mcu/ARESETN] [get_bd_pins proc_sys_reset_200MHz/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_1_peripheral_aresetn [get_bd_pins axi_ic_accel_ctrl/M00_ARESETN] [get_bd_pins axi_ic_accel_ctrl/S00_ARESETN] [get_bd_pins axi_ic_ctrl_300/M00_ARESETN] [get_bd_pins axi_ic_ctrl_300/M01_ARESETN] [get_bd_pins axi_ic_ctrl_300/M02_ARESETN] [get_bd_pins axi_ic_ctrl_300/S00_ARESETN] [get_bd_pins axi_ic_mcu/M00_ARESETN] [get_bd_pins axi_ic_mcu/S00_ARESETN] [get_bd_pins axi_vip_0/aresetn] [get_bd_pins proc_sys_reset_200MHz/peripheral_aresetn] [get_bd_pins raspi_pipeline/aresetn] [get_bd_pins vcu/aresetn]
  connect_bd_net -net proc_sys_reset_2_peripheral_aresetn [get_bd_pins axi_ic_ctrl_100/M00_ARESETN] [get_bd_pins axi_ic_ctrl_100/M01_ARESETN] [get_bd_pins axi_ic_ctrl_100/M02_ARESETN] [get_bd_pins axi_ic_ctrl_100/S00_ARESETN] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins proc_sys_reset_100MHz/peripheral_aresetn] [get_bd_pins raspi_pipeline/lite_aresetn]
  connect_bd_net -net raspi_pipeline_csirxss_csi_irq [get_bd_pins raspi_pipeline/csirxss_csi_irq] [get_bd_pins xlconcat_0_0/In0]
  connect_bd_net -net raspi_pipeline_dem_irq [get_bd_pins raspi_pipeline/dem_irq] [get_bd_pins xlconcat_0_0/In1]
  connect_bd_net -net raspi_pipeline_frm_buf_irq [get_bd_pins raspi_pipeline/frm_buf_irq] [get_bd_pins xlconcat_0_0/In4]
  connect_bd_net -net vcu_0_vcu_host_interrupt [get_bd_pins vcu/vcu_host_interrupt] [get_bd_pins xlconcat_0_0/In2]
  connect_bd_net -net xlconcat_0_0_dout [get_bd_pins PS_0/pl_ps_irq1] [get_bd_pins xlconcat_0_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_ports raspi_enable] [get_bd_pins xlconstant_1/dout]

  # Create address segments
  assign_bd_address -offset 0xB0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs raspi_pipeline/ISPPipeline_accel_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs axi_iic_0/S_AXI/Reg] -force
  assign_bd_address -offset 0xA0000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs axi_vip_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80002000 -range 0x00002000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs raspi_pipeline/mipi_csi2_rx_subsyst_0/csirxss_s_axi/Reg] -force
  assign_bd_address -offset 0xB0080000 -range 0x00010000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs raspi_pipeline/v_frmbuf_wr_0/s_axi_CTRL/Reg] -force
  assign_bd_address -offset 0xB0040000 -range 0x00040000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs raspi_pipeline/v_proc_ss_0/s_axi_ctrl/Reg] -force
  assign_bd_address -offset 0x80100000 -range 0x00100000 -target_address_space [get_bd_addr_spaces PS_0/Data] [get_bd_addr_segs vcu/vcu_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces raspi_pipeline/v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs PS_0/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces raspi_pipeline/v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs PS_0/SAXIGP2/HP0_LPS_OCM] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces raspi_pipeline/v_frmbuf_wr_0/Data_m_axi_mm_video] [get_bd_addr_segs PS_0/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces vcu/vcu_0/Code] [get_bd_addr_segs PS_0/SAXIGP6/LPD_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces vcu/vcu_0/DecData0] [get_bd_addr_segs PS_0/SAXIGP4/HP2_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces vcu/vcu_0/DecData1] [get_bd_addr_segs PS_0/SAXIGP4/HP2_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces vcu/vcu_0/EncData0] [get_bd_addr_segs PS_0/SAXIGP0/HPC0_DDR_LOW] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces vcu/vcu_0/EncData1] [get_bd_addr_segs PS_0/SAXIGP0/HPC0_DDR_LOW] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  # Create PFM attributes
  set_property PFM_NAME {xilinx:zcu104_rpiMipiRx_vcu_DP:zcu104_rpiMipiRx_vcu_DP:1.0} [get_files [current_bd_design].bd]
  set_property PFM.AXI_PORT {S_AXI_HPC1_FPD {memport "S_AXI_HP" sptag "HPC1" memory "PS_0 HPC1_DDR_LOW" is_range "false"} S_AXI_HP1_FPD {memport "S_AXI_HP" sptag "HP1" memory "PS_0 HP1_DDR_LOW" is_range "false"} S_AXI_HP3_FPD {memport "S_AXI_HP" sptag "HP3" memory "PS_0 HP3_DDR_LOW" is_range "false"}} [get_bd_cells /PS_0]
  set_property PFM.IRQ {pl_ps_irq0 {id 0 range 7}} [get_bd_cells /PS_0]
  set_property PFM.AXI_PORT {M01_AXI {memport "M_AXI_GP" sptag "" memory ""} M02_AXI {memport "M_AXI_GP" sptag "" memory ""} M03_AXI {memport "M_AXI_GP" sptag "" memory ""} M04_AXI {memport "M_AXI_GP" sptag "" memory ""} M05_AXI {memport "M_AXI_GP" sptag "" memory ""} M06_AXI {memport "M_AXI_GP" sptag "" memory ""} M07_AXI {memport "M_AXI_GP" sptag "" memory ""} M08_AXI {memport "M_AXI_GP" sptag "" memory ""} M09_AXI {memport "M_AXI_GP" sptag "" memory ""} M10_AXI {memport "M_AXI_GP" sptag "" memory ""} M11_AXI {memport "M_AXI_GP" sptag "" memory ""} M12_AXI {memport "M_AXI_GP" sptag "" memory ""} M13_AXI {memport "M_AXI_GP" sptag "" memory ""} M14_AXI {memport "M_AXI_GP" sptag "" memory ""} M15_AXI {memport "M_AXI_GP" sptag "" memory ""}} [get_bd_cells /axi_ic_accel_ctrl]
  set_property PFM.CLOCK {clk_100M {id "2" is_default "false" proc_sys_reset "/proc_sys_reset_100MHz" status "fixed" freq_hz "99999000"} clkv_200M {id "18" is_default "true" proc_sys_reset "/proc_sys_reset_200MHz" status "fixed" freq_hz "199998000"} clk_400M {id "25" is_default "false" proc_sys_reset "/proc_sys_reset_400MHz" status "fixed" freq_hz "399960000"}} [get_bd_cells /clk_wiz_0]


  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


