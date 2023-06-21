# (C) Copyright 2020 - 2022 Xilinx, Inc.
# SPDX-License-Identifier: Apache-2.0

CP = cp -rf
MKDIR = mkdir -p
RM = rm -rf
XSCT = $(XILINX_VITIS)/bin/xsct
JOBS ?= 8

PLATFORM ?= zcu102_rpiMipiRx_DP
VERSION ?= 202210_1

PFM_DIR = xilinx_$(PLATFORM)_$(VERSION)
PFM_PRJ_DIR = xsct/$(PLATFORM)/$(PLATFORM)/export/$(PLATFORM)
PFM_SCRIPTS_DIR = scripts

PFM_TCL = $(PFM_SCRIPTS_DIR)/pfm.tcl
PFM_XPFM = $(PFM_DIR)/$(PLATFORM).xpfm

VIV_DIR = vivado/$(PLATFORM)
VIV_XSA = $(VIV_DIR)/project/$(PLATFORM).xsa

PETL_DIR = petalinux/$(PLATFORM)
PETL_IMG_DIR = $(PETL_DIR)/images/linux
PETL_BL31_ELF = $(PETL_IMG_DIR)/bl31.elf
PETL_PMUFW_ELF = $(PETL_IMG_DIR)/pmufw.elf
PETL_FSBL_ELF = $(PETL_IMG_DIR)/zynqmp_fsbl.elf
PETL_DTB = $(PETL_IMG_DIR)/system.dtb

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make platform'
	@echo '    Generate Vitis platform'
	@echo ''

.PHONY: all
all: platform

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM): $(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB)
	$(XSCT) $(PFM_TCL) -xsa $(VIV_XSA)
	@$(CP) $(PFM_PRJ_DIR) $(PFM_DIR)
	@echo 'Vitis platform available at $(PFM_DIR)'

$(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB): $(VIV_XSA)
	make -C petalinux petalinux PFM=$(PLATFORM)

$(VIV_XSA):
	make -C $(VIV_DIR) xsa JOBS=$(JOBS)

.PHONY: clean
clean:
	-@$(RM) .Xil boot image linux.bif ws $(PFM_DIR)
	make -C $(VIV_DIR) clean
	make -C $(PETL_DIR) clean

