---
title: KI Kontext & Direktiven
author: Moritz
last_updated: 2026-02-26
status: active
source_id: AI-CTX-001
description: Grundlegende Regeln für Large Language Models (LLMs) bei der Arbeit an diesem Repo.
---

# 🤖 AI_CONTEXT.md

Dieses Dokument dient als Einstiegspunkt für jede KI, die an dieser Konfiguration arbeitet.

## 1. Repository-Struktur

*   **Nix-Code:** Befindet sich modular unter `/etc/nixos/`.
*   **Dokumentation:** Liegt strikt unter `docs/`. Nutze die `source_id`s in den Dateien für Deep-Dives.
*   **Backlog & Ideen:** Siehe `docs/04-BACKLOG-AND-IDEAS.md`.

## 2. Strikte Regeln (The Golden Rules)

1.  **Keine Flakes (aktuell):** Nutze Standard `nix-channel` Logik. Die Struktur muss aber "Flake-ready" sein.
2.  **Schichten-Architektur:** Beachte die Layer (00-system, 10-infrastructure, 20-services).
3.  **Vanilla vor Abstraktion:** Bevorzuge Standard-NixOS Optionen gegenüber komplexen Wrappern (KISS-Prinzip).
4.  **Single Source of Truth:** Alle IPs, Ports und Hardware-Toggles müssen über `00-core/configs.nix` oder `00-core/ports.nix` laufen. Keine harten Werte in den Modulen!
5.  **Security First:** Nutze systemd-Härtung für jeden neuen Dienst und beachte den NFTables-Killswitch.
6.  **Sprache:** Erklärungen und Kommentare immer auf **DEUTSCH**.

## 3. Wissens-IDs (Traceability)

Dieses Repository nutzt `source-id` und `sink` Kommentare. Wenn du Code änderst, stelle sicher, dass die Verbindung zwischen Definition (`source-id`) und Verwendung (`sink`) erhalten bleibt.

## 4. Architekt-Direktiven (Phase 3)

*   **System Scan:** Wann immer ein "System Scan" angefordert wird oder der Prozess via CI (GitHub Actions) läuft, analysiere die Dateistruktur auf strukturelle Isomorphie.
*   **Visualisierung:** Erstelle ein Mermaid.js Diagramm (graph TB), das die aktuelle 00/10/20 Layer-Hierarchie widerspiegelt.
*   **Dependency Hell:** Suche explizit nach zirkulären Imports oder Layer-Verletzungen (z.B. 00-core importiert 20-services) und markiere diese Knoten im Diagramm ROT.
*   **Stil:** Nutze klare Gruppierungen (subgraphs) und professionelle Mermaid-Syntax.
--- Hardware Audit (28.02.2026) ---
### 🧠 CPU

### 🎮 GPU / PCI
00:02.0 VGA compatible controller: Intel Corporation CoffeeLake-S GT2 [UHD Graphics 630]

### 🐏 Memory (RAM)
              gesamt       benutzt     frei      gemns.  Puffer/Cache verfügbar
Speicher:       15Gi       3,6Gi       6,3Gi       199Mi       6,0Gi        11Gi
Swap:          4,0Gi       931Mi       3,1Gi

### 💽 Storage (Disk)
NAME     SIZE TYPE MOUNTPOINTS
sda    476,9G disk 
├─sda1   100M part /boot
├─sda2    16M part 
├─sda3 201,6G part 
├─sda4   937M part 
└─sda5 274,3G part /var/lib/containers/storage/overlay
                   /nix/store
                   /
sdb     14,3G disk 
└─sdb1  14,3G part 
zram0      0B disk 

Detailed Disk Info:
Dateisystem    Größe Benutzt Verf. Verw% Eingehängt auf
devtmpfs        787M       0  787M    0% /dev
tmpfs           7,7G    1,2M  7,7G    1% /dev/shm
tmpfs           3,9G    5,2M  3,9G    1% /run
/dev/sda5       269G     35G  221G   14% /
efivarfs        192K     52K  136K   28% /sys/firmware/efi/efivars
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-journald.service
mergerfs-pool   269G     35G  221G   14% /mnt/storage
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-resolved.service
tmpfs           7,7G    1,1M  7,7G    1% /run/wrappers
tmpfs           1,0M       0  1,0M    0% /run/credentials/getty@tty1.service
tmpfs           1,6G     32K  1,6G    1% /run/user/1000
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-networkd.service
/dev/sda1        96M     66M   31M   68% /boot

### 🌐 Network
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP group default qlen 1000
    link/ether 68:84:7e:71:19:a1 brd ff:ff:ff:ff:ff:ff
    altname enp0s31f6
    altname enx68847e7119a1
    inet 192.168.2.73/24 metric 1024 brd 192.168.2.255 scope global dynamic eno1
       valid_lft 79280sec preferred_lft 79280sec
    inet6 2003:dc:7f39:ee64:d02f:45dd:e98:510c/64 scope global temporary dynamic 
       valid_lft 172793sec preferred_lft 35538sec
    inet6 2003:dc:7f39:ee64:6a84:7eff:fe71:19a1/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 172793sec preferred_lft 86393sec
    inet6 fe80::6a84:7eff:fe71:19a1/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: wlp1s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:b2:7d:c9:5b:ad brd ff:ff:ff:ff:ff:ff
    altname wlx7cb27dc95bad
4: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc fq state UNKNOWN group default qlen 500
    link/none 
    inet 100.113.29.82/32 scope global tailscale0
       valid_lft forever preferred_lft forever
    inet6 fd7a:115c:a1e0::8937:1d52/128 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::7dfd:c50d:54fc:38f/64 scope link stable-privacy proto kernel_ll 
       valid_lft forever preferred_lft forever
6: podman0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 16:b0:ea:93:93:75 brd ff:ff:ff:ff:ff:ff
    inet 10.88.0.1/16 brd 10.88.255.255 scope global podman0
       valid_lft forever preferred_lft forever
    inet6 fe80::14b0:eaff:fe93:9375/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
7: veth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master podman0 state UP group default qlen 1000
    link/ether 82:62:9b:b3:95:c1 brd ff:ff:ff:ff:ff:ff link-netns netns-9e665b84-f3bb-310f-9557-87903cd77799
    inet6 fe80::1cd7:72ff:fe14:a02c/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
30: veth-host@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 4a:88:5d:bf:fe:60 brd ff:ff:ff:ff:ff:ff link-netns media-vault
    inet 10.200.1.1/24 scope global veth-host
       valid_lft forever preferred_lft forever
    inet6 fe80::4888:5dff:febf:fe60/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever

### 🔐 SSH Status
● sshd.service - SSH Daemon
     Loaded: loaded (/etc/systemd/system/sshd.service; enabled; preset: ignored)
     Active: active (running) since Fri 2026-02-27 14:46:01 CET; 18h ago
 Invocation: 514e1867aa3540c6b884d9bfa38ae12f
   Main PID: 4855 (sshd)
--- Hardware Audit (28.02.2026) ---
### 🧠 CPU

### 🎮 GPU / PCI
00:02.0 VGA compatible controller: Intel Corporation CoffeeLake-S GT2 [UHD Graphics 630]

### 🐏 Memory (RAM)
              gesamt       benutzt     frei      gemns.  Puffer/Cache verfügbar
Speicher:       15Gi       3,6Gi       6,3Gi       199Mi       6,0Gi        11Gi
Swap:          4,0Gi       931Mi       3,1Gi

### 💽 Storage (Disk)
NAME     SIZE TYPE MOUNTPOINTS
sda    476,9G disk 
├─sda1   100M part /boot
├─sda2    16M part 
├─sda3 201,6G part 
├─sda4   937M part 
└─sda5 274,3G part /var/lib/containers/storage/overlay
                   /nix/store
                   /
sdb     14,3G disk 
└─sdb1  14,3G part 
zram0      0B disk 

Detailed Disk Info:
Dateisystem    Größe Benutzt Verf. Verw% Eingehängt auf
devtmpfs        787M       0  787M    0% /dev
tmpfs           7,7G    1,2M  7,7G    1% /dev/shm
tmpfs           3,9G    5,2M  3,9G    1% /run
/dev/sda5       269G     35G  221G   14% /
efivarfs        192K     52K  136K   28% /sys/firmware/efi/efivars
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-journald.service
mergerfs-pool   269G     35G  221G   14% /mnt/storage
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-resolved.service
tmpfs           7,7G    1,1M  7,7G    1% /run/wrappers
tmpfs           1,0M       0  1,0M    0% /run/credentials/getty@tty1.service
tmpfs           1,6G     32K  1,6G    1% /run/user/1000
tmpfs           1,0M       0  1,0M    0% /run/credentials/systemd-networkd.service
/dev/sda1        96M     66M   31M   68% /boot

### 🌐 Network
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP group default qlen 1000
    link/ether 68:84:7e:71:19:a1 brd ff:ff:ff:ff:ff:ff
    altname enp0s31f6
    altname enx68847e7119a1
    inet 192.168.2.73/24 metric 1024 brd 192.168.2.255 scope global dynamic eno1
       valid_lft 79280sec preferred_lft 79280sec
    inet6 2003:dc:7f39:ee64:d02f:45dd:e98:510c/64 scope global temporary dynamic 
       valid_lft 172793sec preferred_lft 35538sec
    inet6 2003:dc:7f39:ee64:6a84:7eff:fe71:19a1/64 scope global dynamic mngtmpaddr noprefixroute 
       valid_lft 172793sec preferred_lft 86393sec
    inet6 fe80::6a84:7eff:fe71:19a1/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: wlp1s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 7c:b2:7d:c9:5b:ad brd ff:ff:ff:ff:ff:ff
    altname wlx7cb27dc95bad
4: tailscale0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1280 qdisc fq state UNKNOWN group default qlen 500
    link/none 
    inet 100.113.29.82/32 scope global tailscale0
       valid_lft forever preferred_lft forever
    inet6 fd7a:115c:a1e0::8937:1d52/128 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::7dfd:c50d:54fc:38f/64 scope link stable-privacy proto kernel_ll 
       valid_lft forever preferred_lft forever
6: podman0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 16:b0:ea:93:93:75 brd ff:ff:ff:ff:ff:ff
    inet 10.88.0.1/16 brd 10.88.255.255 scope global podman0
       valid_lft forever preferred_lft forever
    inet6 fe80::14b0:eaff:fe93:9375/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
7: veth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master podman0 state UP group default qlen 1000
    link/ether 82:62:9b:b3:95:c1 brd ff:ff:ff:ff:ff:ff link-netns netns-9e665b84-f3bb-310f-9557-87903cd77799
    inet6 fe80::1cd7:72ff:fe14:a02c/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
30: veth-host@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 4a:88:5d:bf:fe:60 brd ff:ff:ff:ff:ff:ff link-netns media-vault
    inet 10.200.1.1/24 scope global veth-host
       valid_lft forever preferred_lft forever
    inet6 fe80::4888:5dff:febf:fe60/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever

### 🔐 SSH Status
● sshd.service - SSH Daemon
     Loaded: loaded (/etc/systemd/system/sshd.service; enabled; preset: ignored)
     Active: active (running) since Fri 2026-02-27 14:46:01 CET; 18h ago
 Invocation: 514e1867aa3540c6b884d9bfa38ae12f
   Main PID: 4855 (sshd)
