# Opsero Camera FMC Vitis Platforms

## Introduction

This repository contains Vitis platforms and overlays for two accelerated vision AI applications for the ZCU10x 
development boards and the [RPi Camera FMC](https://camerafmc.com/docs/rpi-camera-fmc/overview/). 
These platforms and applications were ported to the ZCU10x boards from the 
[Kria Vitis Platforms and Overlays project](https://github.com/Xilinx/kria-vitis-platforms).
Detailed information on these applications can be found in the documentation for the 
[Kria KV260 Vision AI Starter Kit applications](https://xilinx.github.io/kria-apps-docs/kv260/2022.1/build/html/index.html).
These designs can be run on [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx) or
PetaLinux 2022.1.

## Quick Start Tutorials

The following tutorials have been written to help you to build and run these applications:

* [Develop smart vision apps for ZCU106 and RPi Camera FMC](https://www.fpgadeveloper.com/develop-smart-vision-apps-for-zcu106-and-rpi-camera-fmc/)
* [NLP-SmartVision in PetaLinux on ZCU104 Using Raspberry Pi cameras](https://www.fpgadeveloper.com/nlp-smartvision-in-petalinux-on-zcu104/)
* [Benchmarking an FPGA-based AI Vision application](https://www.fpgadeveloper.com/benchmarking-an-fpga-based-ai-vision-application/)

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

*Coming soon* for PetaLinux flow:
* TUL [PYNQ-ZU](https://www.tulembedded.com/FPGA/ProductsPYNQ-ZU.html)
* Digilent [Genesys-ZU](https://digilent.com/shop/genesys-zu-zynq-ultrascale-mpsoc-development-board/)
* Avnet [UltraZed EV carrier](https://www.xilinx.com/products/boards-and-kits/1-y3n9v1.html)

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
   
### Ubuntu flow

2. Prepare SD card with [Certified Ubuntu 22.04 LTS for ZCU10x](https://ubuntu.com/download/amd-xilinx)
3. Boot the board, install `xlnx-config` snap and run `xlnx-config.sysinit`:
```
sudo snap install xlnx-config --classic --channel=2.x
sudo xlnx-config.sysinit
```

More complete instructions for Ubuntu flow found 
[here](https://www.fpgadeveloper.com/develop-smart-vision-apps-for-zcu106-and-rpi-camera-fmc/).

### PetaLinux flow

2. Prepare SD card with PetaLinux image (build instructions below)
3. Boot the board, build applications and run

More complete instructions for PetaLinux flow found 
[here](https://www.fpgadeveloper.com/nlp-smartvision-in-petalinux-on-zcu104/).

## Build instructions

### Clone and source tools

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

Run the make command for the flow you wish to use (Ubuntu or PetaLinux).

### Ubuntu flow

The Ubuntu flow will generate a PAC which you can install and activate on your ZCU10x board.

Build all (Smartcam application):

```
make pac OVERLAY=smartcam
```

Build all (NLP-SmartVision application):

```
make pac OVERLAY=nlp-smartvision
```

The PAC will be a compressed zip file found in this directory:

```
camera-fmc-vitis-platforms/<target-board>/pac
```

### PetaLinux flow

The PetaLinux flow will generate a PetaLinux project with boot files and a root filesystem that you can 
copy to an SD card. The root filesystem is stored and retained on the SD card.

Build all (Smartcam application):

```
make petalinux OVERLAY=smartcam
```

Build all (NLP-SmartVision application):

```
make petalinux OVERLAY=nlp-smartvision
```

The PetaLinux image files will be found in this directory:

```
camera-fmc-vitis-platforms/<target-board>/petalinux/<platform-name>/images/linux
```

