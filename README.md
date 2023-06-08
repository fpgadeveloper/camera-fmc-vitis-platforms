# Opsero Camera FMC Vitis Platforms

## Introduction
This repository contains vitis platforms and overlays for Opsero Camera FMC accelerated applications.

## Requirements

* Linux development PC with tools installed:
  - Vitis Core Dev Kit 2022.1 (Vivado, Vitis HLS)
  - PetaLinux 2022.1
* One of the supported dev boards (see below)
* [RPi Camera FMC](https://camerafmc.com)
* At least one Raspberry Pi v2 camera
* DisplayPort monitor and cable
* Ethernet cable to a network router (for network and internet access)

## Supported dev boards

* ZCU106
* ZCU104 (coming soon)
* ZCU102 (coming soon)

## Instructions

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
./build-petalinux
```

To build the Platform Asset Container (PAC):

```
cd camera-fmc-vitis-platforms/zcu106
make pac OVERLAY=smartcam
```


