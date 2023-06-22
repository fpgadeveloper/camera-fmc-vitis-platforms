# (C) Copyright 2020 - 2022 Xilinx, Inc.
# SPDX-License-Identifier: Apache-2.0

CP = cp -f

PWD = $(shell readlink -f .)

# the platform directory has to be an absolute path when passed to v++
PFM_DIR = $(PWD)/platforms
PFM_VER = 202210_1

PLNX_DIR = $(PWD)/petalinux

# valid platforms / overlays
PFM_LIST = zcu106_rpiMipiRx_vcu_DP zcu106_rpiMipiRx_DP
OVERLAY_LIST = smartcam nlp-smartvision

# override platform name based on overlay
ifeq ($(OVERLAY),smartcam)
  override PFM = zcu106_rpiMipiRx_vcu_DP
endif
ifeq ($(OVERLAY),nlp-smartvision)
  override PFM = zcu106_rpiMipiRx_DP
endif

PFM_XPFM = $(PFM_DIR)/xilinx_$(PFM)_$(PFM_VER)/$(PFM).xpfm

VITIS_DIR = overlays/examples
VITIS_OVERLAY_DIR = $(VITIS_DIR)/$(OVERLAY)
VITIS_OVERLAY_BIT = $(VITIS_OVERLAY_DIR)/binary_container_1/link/int/system.bit
VITIS_OVERLAY_XCLBIN = $(VITIS_OVERLAY_DIR)/binary_container_1/dpu.xclbin

# the PAC dir
PAC_NAME = $(OVERLAY)_pac
PF_NAME = $(OVERLAY)_platform
PAC_STRUCT = hwconfig/cfg/zcu106
PAC_ROOT = $(PWD)/pac
PAC_DIR = $(PAC_ROOT)/$(PAC_NAME)
PAC_SUBDIR = $(PAC_DIR)/$(PAC_STRUCT)
PAC_ZIP = $(PAC_ROOT)/$(PAC_NAME).zip
PAC_MANIFEST = $(PAC_SUBDIR)/../manifest.yaml
PAC_BOOTGEN = $(PAC_SUBDIR)/bootgen.bif

PETL_DIR = petalinux/$(PFM)
PETL_IMG_DIR = $(PETL_DIR)/images/linux
PETL_BL31_ELF = $(PETL_IMG_DIR)/bl31.elf
PETL_PMUFW_ELF = $(PETL_IMG_DIR)/pmufw.elf
PETL_FSBL_ELF = $(PETL_IMG_DIR)/zynqmp_fsbl.elf
PETL_DTB = $(PETL_IMG_DIR)/system.dtb

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make pac OVERLAY=<val>'
	@echo '    Build the Platform Assets Container (PAC).'
	@echo ''
	@echo '  make petalinux OVERLAY=<val>'
	@echo '    Build the PetaLinux project.'
	@echo ''
	@echo '  make overlay OVERLAY=<val>'
	@echo '    Build the Vitis application overlay.'
	@echo ''
	@echo '    Valid options for OVERLAY: ${OVERLAY_LIST}'
	@echo ''
	@echo '  make platform PFM=<val> JOBS=<n>'
	@echo '    Build the Vitis platform.'
	@echo ''
	@echo '    Valid options for PFM: ${PFM_LIST}'
	@echo '    JOBS: optional param to set number of synthesis jobs (default 8)'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''

.PHONY: pac
pac: $(PAC_ZIP)
$(PAC_ZIP): $(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB)
	@valid=0; \
	for o in $(OVERLAY_LIST); do \
	  if [ "$$o" = "$(OVERLAY)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter OVERLAY=$(OVERLAY). Choose one of: $(OVERLAY_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Create Platform Asset Container $(OVERLAY)'; \
	mkdir -p $(PAC_SUBDIR)
	cp $(VITIS_OVERLAY_BIT) $(PAC_SUBDIR)/.
	cp $(VITIS_OVERLAY_XCLBIN) $(PAC_SUBDIR)/.
	cp $(PETL_IMG_DIR)/system.dtb $(PAC_SUBDIR)/.
	cp $(PETL_IMG_DIR)/bl31.elf $(PAC_SUBDIR)/.
	cp $(PETL_IMG_DIR)/pmufw.elf $(PAC_SUBDIR)/.
	cp $(PETL_IMG_DIR)/zynqmp_fsbl.elf $(PAC_SUBDIR)/.
	@echo 'name: $(PF_NAME)' > $(PAC_MANIFEST)
	@echo 'description: Boot assets for $(OVERLAY) platform' >> $(PAC_MANIFEST)
	@echo 'revision: 1' >> $(PAC_MANIFEST)
	@echo 'assets:' >> $(PAC_MANIFEST)
	@echo '    zcu106: zcu106' >> $(PAC_MANIFEST)
	@echo 'the_ROM_image:' > $(PAC_BOOTGEN)
	@echo '{' >> $(PAC_BOOTGEN)
	@echo '        [bootloader, destination_cpu=a53-0] /usr/local/share/xlnx-config/$(PAC_NAME)/$(PAC_STRUCT)/zynqmp_fsbl.elf' >> $(PAC_BOOTGEN)
	@echo '        [pmufw_image] /usr/local/share/xlnx-config/$(PAC_NAME)/$(PAC_STRUCT)/pmufw.elf' >> $(PAC_BOOTGEN)
	@echo '        [destination_device=pl] /usr/local/share/xlnx-config/$(PAC_NAME)/$(PAC_STRUCT)/system.bit' >> $(PAC_BOOTGEN)
	@echo '        [destination_cpu=a53-0, exception_level=el-3, trustzone] /usr/local/share/xlnx-config/$(PAC_NAME)/$(PAC_STRUCT)/bl31.elf' >> $(PAC_BOOTGEN)
	@echo '        [destination_cpu=a53-0, load=0x00100000] /usr/local/share/xlnx-config/$(PAC_NAME)/$(PAC_STRUCT)/system.dtb' >> $(PAC_BOOTGEN)
	@echo '        [destination_cpu=a53-0, exception_level=el-2] /usr/lib/u-boot/xilinx_zynqmp_virt/u-boot.elf' >> $(PAC_BOOTGEN)
	@echo '}' >> $(PAC_BOOTGEN)
	cd $(PAC_ROOT) && zip -r $(PAC_ZIP) $(PAC_NAME)

.PHONY: petalinux
petalinux: $(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB)
$(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB): $(VITIS_OVERLAY_BIT)
	make -C petalinux petalinux OVERLAY=$(OVERLAY)

.PHONY: overlay
overlay: $(VITIS_OVERLAY_BIT)
$(VITIS_OVERLAY_BIT): $(PFM_XPFM)
	@valid=0; \
	for o in $(OVERLAY_LIST); do \
	  if [ "$$o" = "$(OVERLAY)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter OVERLAY=$(OVERLAY). Choose one of: $(OVERLAY_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Build $(OVERLAY) Vitis overlay using platform $(PFM)'; \
	$(MAKE) -C $(VITIS_OVERLAY_DIR) all PLATFORM=$(PFM_XPFM)

.PHONY: platform
platform: $(PFM_XPFM)
$(PFM_XPFM):
	@valid=0; \
	for p in $(PFM_LIST); do \
	  if [ "$$p" = "$(PFM)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter PFM=$(PFM). Choose one of: $(PFM_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Create Vitis platform $(PFM)'; \
	$(MAKE) -C $(PFM_DIR) platform PLATFORM=$(PFM) VERSION=$(PFM_VER)

.PHONY: clean
clean:
	$(foreach o, $(OVERLAY_LIST), $(MAKE) -C $(PLNX_DIR) clean OVERLAY=$(o);)
	$(foreach o, $(OVERLAY_LIST), $(MAKE) -C $(VITIS_DIR)/$(o) clean;)
	$(foreach p, $(PFM_LIST), $(MAKE) -C $(PFM_DIR) clean PLATFORM=$(p) VERSION=$(PFM_VER);)
	$(foreach p, $(PFM_LIST), rm -r $(PAC_ROOT);)
