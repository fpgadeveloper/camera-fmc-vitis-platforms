RM = rm -rf
VIVADO = $(XILINX_VIVADO)/bin/vivado
JOBS ?= 8
PFM ?= zcu106_rpiMipiRx_vcu_DP
PETL_ROOT = $(shell pwd)

VIV_DIR = $(PETL_ROOT)/../vivado/$(PFM)
VIV_PRJ_DIR = $(VIV_DIR)/project

VIV_XSA = $(VIV_PRJ_DIR)/$(PFM).xsa

# valid platforms / overlays
PFM_LIST = zcu106_rpiMipiRx_vcu_DP zcu106_rpiMipiRx_DP

PETL_DIR = $(PETL_ROOT)/$(PFM)
PETL_IMG_DIR = $(PETL_DIR)/images/linux
PETL_BL31_ELF = $(PETL_IMG_DIR)/bl31.elf
PETL_PMUFW_ELF = $(PETL_IMG_DIR)/pmufw.elf
PETL_FSBL_ELF = $(PETL_IMG_DIR)/zynqmp_fsbl.elf
PETL_DTB = $(PETL_IMG_DIR)/system.dtb
PETL_CFG_DONE = $(PETL_DIR)/configdone.txt
PETL_COMP_DIR = $(PETL_DIR)/components

.PHONY: help
help:
	@echo 'Usage:'
	@echo ''
	@echo '  make petalinux PFM=<val>'
	@echo '    Build the PetaLinux project.'
	@echo ''
	@echo '    Valid options for PFM: ${PFM_LIST}'
	@echo ''
	@echo '  make clean'
	@echo '    Clean runs'
	@echo ''

.PHONY: petalinux
petalinux: $(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB)
$(PETL_BL31_ELF) $(PETL_PMUFW_ELF) $(PETL_FSBL_ELF) $(PETL_DTB): $(PETL_CFG_DONE)
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
	echo 'Build PetaLinux project for $(PFM)'; \
	cd $(PFM) && petalinux-build

$(PETL_CFG_DONE): $(PETL_COMP_DIR)
	cp -R ./bsp/$(PFM)/project-spec ./$(PFM)/.
	touch $(PFM)/configdone.txt
	cd $(PFM) && petalinux-config --silentconfig
	
$(PETL_COMP_DIR): $(PETL_DIR)
	cd $(PFM) && petalinux-config --get-hw-description $(VIV_XSA) --silentconfig
	
$(PETL_DIR): $(VIV_XSA)
	petalinux-create --type project --template zynqMP --name $(PFM)

$(VIV_XSA):
	make -C $(VIV_DIR) xsa JOBS=$(JOBS)

.PHONY: clean
clean:
	$(RM) $(PFM)

