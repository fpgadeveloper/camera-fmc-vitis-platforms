RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
PFM ?= zcu106_rpiMipiRx_vcu_DP
PETL_ROOT = $(shell pwd)

VIV_DIR = $(PETL_ROOT)/../platforms/vivado/$(PFM)
VIV_PRJ_DIR = $(VIV_DIR)/project

VIV_XSA = $(VIV_PRJ_DIR)/$(PFM).xsa

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

VITIS_DIR = $(PETL_ROOT)/../overlays/examples
VITIS_OVERLAY_DIR = $(VITIS_DIR)/$(OVERLAY)
VITIS_OVERLAY_BIT = $(VITIS_OVERLAY_DIR)/binary_container_1/link/int/system.bit
VITIS_OVERLAY_XCLBIN = $(VITIS_OVERLAY_DIR)/binary_container_1/dpu.xclbin

PETL_DIR = $(PETL_ROOT)/$(PFM)
PETL_IMG_DIR = $(PETL_DIR)/images/linux
PETL_BL31_ELF = $(PETL_IMG_DIR)/bl31.elf
PETL_PMUFW_ELF = $(PETL_IMG_DIR)/pmufw.elf
PETL_FSBL_ELF = $(PETL_IMG_DIR)/zynqmp_fsbl.elf
PETL_DTB = $(PETL_IMG_DIR)/system.dtb
PETL_BOOT_BIN = $(PETL_IMG_DIR)/BOOT.BIN
PETL_IMAGE_UB = $(PETL_IMG_DIR)/image.ub
PETL_CFG_DONE = $(PETL_DIR)/configdone.txt
PETL_COMP_DIR = $(PETL_DIR)/components

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make petalinux OVERLAY=<val>'
	@echo '    Build the PetaLinux project.'
	@echo ''
	@echo '    Valid options for OVERLAY: ${OVERLAY_LIST}'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''

.PHONY: petalinux
petalinux: $(PETL_BOOT_BIN) $(PETL_IMAGE_UB)
$(PETL_BOOT_BIN) $(PETL_IMAGE_UB): $(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB)
	@valid=0; \
	for p in $(OVERLAY_LIST); do \
	  if [ "$$p" = "$(OVERLAY)" ]; then \
	    valid=1; \
	    break; \
	  fi \
	done; \
	if [ "$$valid" -ne 1 ]; then \
	  echo 'Invalid parameter OVERLAY=$(OVERLAY). Choose one of: $(OVERLAY_LIST)'; \
	  exit 1; \
	fi; \
	echo 'Build PetaLinux project for $(OVERLAY)'; \
	cd $(PFM) && petalinux-package --boot --fsbl ./images/linux/zynqmp_fsbl.elf --fpga $(VITIS_OVERLAY_BIT) --u-boot
	
$(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB): $(PETL_CFG_DONE)
	cd $(PFM) && petalinux-build

$(PETL_CFG_DONE): $(PETL_COMP_DIR)
	cp -R ./bsp/$(PFM)/project-spec ./$(PFM)/.
	touch $(PFM)/configdone.txt
	cd $(PFM) && petalinux-config --silentconfig
	
$(PETL_COMP_DIR): $(PETL_DIR)
	cd $(PFM) && petalinux-config --get-hw-description $(VIV_XSA) --silentconfig
	
$(PETL_DIR): $(VITIS_OVERLAY_BIT)
	petalinux-create --type project --template zynqMP --name $(PFM)

$(VITIS_OVERLAY_BIT):
	$(MAKE) -C $(VITIS_OVERLAY_DIR) all PLATFORM=$(PFM_XPFM)

.PHONY: clean
clean:
	$(RM) $(PFM)

