# Opsero Camera FMC Vitis Platforms

## Introduction
This repository contains vitis platforms and overlays for Opsero Camera FMC accelerated applications.
These are intended to be run on [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx).

## Requirements

* Linux development PC with tools installed:
  - Vitis Core Dev Kit 2022.1 (Vivado, Vitis HLS)
  - PetaLinux 2022.1
* One of the supported dev boards (see below)
* [RPi Camera FMC](https://camerafmc.com)
* One Raspberry Pi v2 camera
* DisplayPort monitor and cable
* Ethernet cable to a network router (for network and internet access)

## Supported dev boards

* ZCU106
* ZCU104 (coming soon)
* ZCU102 (coming soon)

## Hardware setup

1. Connect the target board:
   * DisplayPort monitor
   * Ethernet port to a network router
   * RPi Camera FMC to:
      - ZCU106: HPC0
      - ZCU102: HPC0 (coming soon)
      - ZCU104: LPC (coming soon)
   * Raspberry Pi camera v2 to CAM1 connector of RPi Camera FMC
1. Prepare SD card with [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx)
2. Boot the board, install `xlnx-config` snap and run `xlnx-config.sysinit`:
```
sudo snap install xlnx-config --classic --channel=2.x
sudo xlnx-config.sysinit
```

## Build instructions

This repo contains submodules. To clone this repo, run:
```
git clone --recursive https://github.com/fpgadeveloper/camera-fmc-vitis-platforms.git
```

Source Vivado and PetaLinux tools:

```
source <path-to-petalinux>/2022.1/settings.sh
source <path-to-vivado>/2022.1/settings64.sh
```

Build all:

```
cd camera-fmc-vitis-platforms/zcu106
make pac OVERLAY=smartcam
```

Build the overlay:

```
cd camera-fmc-vitis-platforms/zcu106
make overlay OVERLAY=smartcam
```

Build the platforms:

```
cd camera-fmc-vitis-platforms/zcu106/platforms
make platform
```

To build PetaLinux for the platforms:

```
cd camera-fmc-vitis-platforms/zcu106/platforms/petalinux
make petalinux PFM=zcu106_rpiMipiRx_vcu_DP
```

To build the Platform Asset Container (PAC):

```
cd camera-fmc-vitis-platforms/zcu106
make pac OVERLAY=smartcam
```


