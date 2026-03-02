---
title: HARDWARE_SPECIFICATION_Q958
identity:
  id: NIXH-10-HARDWARE-Q958
  layer: 10
category: Hardware
status: active
last_reviewed: 2026-03-02
---

# 🛰️ Hardware Specification: Fujitsu Q958 (SRE Profile)

This document serves as the machine-readable source of truth for all hardware-dependent optimizations.

## 🧩 Core Components
- **CPU**: Intel(R) Core(TM) i3-9100 CPU @ 3.60GHz (4 Cores / 4 Threads)
- **GPU**: Intel Corporation CoffeeLake-S GT2 [UHD Graphics 630]
- **RAM**: 16GB DDR4 (Optimized for shared_buffers=1GB, max_wal_size=4GB)
- **BIOS**: V5.0.0.13 R1.39.0 (Fujitsu D3613-A1x)

## 🗄️ Storage Layout (ABC-Tiering)
- **Disk /dev/sda (SSD)**: 476.9G (Crucial/Samsung SATA)
  - `/boot`: 1000MB (systemd-boot, configurationLimit = 15)
  - `/`: Root filesystem (ext4/xfs)
- **ZRAM**: 4GB Active Swap (Optimized for 16GB physical RAM)

## 🌐 Network
- **Primary NIC**: Intel Ethernet (enp...)
- **Zigbee**: SLZB-06 Ethernet Coordinator (IP: 192.168.2.200)

## 🛠️ Driver Status
- **GPU**: `i915` with `enable_guc=3` (GuC/HuC enabled for UHD 630)
- **Media**: `intel-media-driver` + `vpl-gpu-rt`
- **CPU**: `intel-ucode` (Microcode updates active)
