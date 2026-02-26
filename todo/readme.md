# Role: Lead NixOS Architect & Systems Reliability Engineer
# Task: Comprehensive System Refactoring based on Context 7 and External Repository Analysis

## 1. CRITICAL DIRECTIVES & WORKFLOW
- **Primary Source of Truth:** You MUST strictly use the provided 'Context 7' (my exported NixOS workspace/files) as the absolute baseline. Do not guess my current configuration. If 'Context 7' is inaccessible or unclear, STOP and ask for clarification.
- **External Repository Analysis:** I require you to actively study the reference repositories. Clone or download the following repositories into `/home/moritz/Documents/nixos-research/` (or use your available local execution/search tools to thoroughly parse them):
  1. https://github.com/ironicbadger/infra (Focus: Direct disk mounts, Intel UHD 630 QuickSync)
  2. https://github.com/ironicbadger/nix-config (Focus: Best practices, architecture)
  3. https://github.com/nix-media-server/nixarr (Focus: VPN confinement concepts)
  4. https://github.com/kiriwalawren/nixflix (Focus: Media stack structuring)
- **Validation:** Cross-reference your findings from these repositories with 'Context 7' and validate current best practices using Brave Search.
- **Language Constraints:** Read instructions in English, but all explanations, documentation, and comments in the generated output MUST be in GERMAN. Output raw Nix code without any Bash wrappers.

## 2. PROJECT ARCHITECTURE & CONSTRAINTS
- **Hardware:** Fujitsu Q958, Intel i3-9100 (9th Gen), UHD 630 Graphics, 16GB RAM.
- **Framework:** Modular Layer Architecture (00-system, 10-infrastructure, 20-services).
- **Paradigm:** Classic NixOS (NO active Flakes). Use standard `configuration.nix` with `imports`. However, the directory structure must remain "Flake-ready" (e.g., `hosts/q958/`, `modules/`).
- **KISS Principle:** Keep It Stupid Simple. Avoid over-engineering, complex namespaces, or unnecessary wrappers.

## 3. SPECIFIC IMPLEMENTATION REQUIREMENTS (Contextual Learnings)

### A. Central Registry (`modules/registry.nix`)
- Implement a central toggle system using `lib.mkEnableOption` to enable/disable hardware profiles and services globally.

### B. Hardware Profile (`hosts/q958/hardware-profile.nix`)
- **QuickSync & Intel GPU:** Based on IronicBadger's configuration, you must include:
  - `hardware.firmware = [ pkgs.linux-firmware ];`
  - Kernel parameters: `i915.enable_guc=2` (specific to 9th Gen) and `i915.enable_fbc=1`.
  - Packages: `intel-media-driver`, `intel-compute-runtime`, `libva-utils`, `intel-gpu-tools`.
  - Environment variable: `LIBVA_DRIVER_NAME = "iHD"`.
  - User groups: User `moritz` must be added to `video` and `render` groups.
- **Storage:** Implement `services.hd-idle` for HDD spindown (no `mergerfs`).

### C. Networking & VPN (`00-system` & `10-infrastructure`)
- **Networkd & Avahi:** Do NOT configure a static IP. Use `systemd-networkd` set to DHCP (IP is managed by the router). Enable Avahi (`nssmdns4 = true`, `publish.workstation = true`) so the server is reachable at `nixhome.local`.
- **Vanilla Killswitch:** Implement a native `nftables` ruleset for Wireguard (`wg0`). Traffic from a specific user/group (e.g., the download stack) must be dropped if it attempts to route through any interface other than `wg0` or the local LAN. Remove all iptables legacy code.

### D. User Management & Workflow (`00-system/home-manager.nix`)
- Integrate `home-manager` natively as a NixOS module (not standalone).
- Configure the environment for user `moritz` including:
  - Aliases: `nsw` (rebuild switch without flakes), `ntest`, `nclean` (store optimization).
  - An informative MOTD (Message of the Day) on SSH login displaying these aliases.

## 4. OUTPUT FORMAT
Deliver the solution as distinct, well-structured Nix configuration files. Use Markdown blocks for each file. Ensure the code perfectly aligns with the required layer structure and relies exclusively on the validated context.
