# Opsero Camera FMC Vitis Platforms

## Introduction

This repository contains Vitis platforms and overlays for two accelerated vision AI applications for the ZCU10x 
development boards and the [RPi Camera FMC](https://camerafmc.com/docs/rpi-camera-fmc/overview/). 
These platforms and applications were ported to the ZCU10x boards from the 
[Kria Vitis Platforms and Overlays project](https://github.com/Xilinx/kria-vitis-platforms).
Detailed information on these applications can be found in the documentation for the 
[Kria KV260 Vision AI Starter Kit applications](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/index.html).
These are intended to be run on [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx).

## Quick Start Tutorials

The following tutorials have been written to help you to build and run these applications:

* [Develop smart vision apps for ZCU106 and RPi Camera FMC](https://www.fpgadeveloper.com/develop-smart-vision-apps-for-zcu106-and-rpi-camera-fmc/)

## Requirements

* Linux development PC with tools installed:
  - Vitis Core Dev Kit 2022.1 (Vivado, Vitis HLS)
  - PetaLinux 2022.1
* One of the supported dev boards (see below)
* [RPi Camera FMC](https://camerafmc.com)
* 1x [Raspberry Pi v2 camera](https://www.raspberrypi.com/products/camera-module-v2/)
* DisplayPort monitor and cable
* Ethernet cable to a network router (for network and internet access)

## Supported dev boards

* AMD Xilinx [ZCU106](https://www.xilinx.com/zcu106) Zynq UltraScale+ Development board
* AMD Xilinx [ZCU104](https://www.xilinx.com/zcu104) Zynq UltraScale+ Development board
* AMD Xilinx [ZCU102](https://www.xilinx.com/zcu102) Zynq UltraScale+ Development board

## Vision AI applications

* [Smartcam](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/docs/smartcamera/smartcamera_landing.html):
  - Runs on ZCU104 and ZCU106 boards
* [NLP-Smartvision](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/docs/nlp-smartvision/nlp_smartvision_landing.html):
  - Runs on ZCU104, ZCU106 and ZCU102 boards

## Hardware setup

1. Connect the target board:
   * DisplayPort monitor
   * Ethernet port to a network router
   * RPi Camera FMC to:
      - ZCU106: HPC0
      - ZCU102: HPC0
      - ZCU104: LPC
   * Raspberry Pi camera v2 to CAM1 connector of RPi Camera FMC
   * Optional: Raspberry Pi camera v2 to CAM2 connector of RPi Camera FMC
2. Prepare SD card with [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx)
3. Boot the board, install `xlnx-config` snap and run `xlnx-config.sysinit`:
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

Cd into the directory of the board that you want to use. For this example, we will use the ZCU106:

```
cd camera-fmc-vitis-platforms/zcu106
```

Build all (Smartcam application):

```
make pac OVERLAY=smartcam
```

Build all (NLP-SmartVision application):

```
make pac OVERLAY=nlp-smartvision
```

