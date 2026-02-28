# 🛰️ NIXHOME TRACEABILITY MATRIX [00-CORE]
**Standard:** NMS-2026-STD
**Last Update:** 28.02.2026

Diese Matrix verknüpft die Anforderungen aus dem Stage-1 Audit mit der technischen Umsetzung im Core-Layer.

| Requirement-ID | Bezeichnung | Ziel-Datei | Status | Trace-ID |
|:---|:---|:---|:---:|:---|
| STORAGE_SAFE | nofail-mounts & Timeouts | 00-core/storage.nix | [x] | NIXH-CORE-007 |
| BOOT_SAFEGUARD | /boot Space Check & Limits | 00-core/boot-safeguard.nix | [x] | NIXH-CORE-008 |
| SECURITY_DEFAULTS | bastelmodus = false & Alarm | 00-core/configs.nix | [x] | NIXH-CORE-006 |
| RECOVERY_WINDOW | SSH Password Auth (15min) | 00-core/ssh-rescue.nix | [x] | NIXH-CORE-004 |
| NIX_TUNING | Smart Fallback & Resources | 00-core/nix-tuning.nix | [x] | NIXH-CORE-002 |
| SYMBIOSIS_FIX | Flache Module & HW-Warnings | 00-core/symbiosis.nix | [x] | NIXH-CORE-005 |
| SECRET_HYGIENE | SOPS-only & Repo Cleanup | 00-core/secrets.nix | [x] | NIXH-CORE-022 |
| FIREWALL_TRUST | Tailscale Interface Trust | 00-core/firewall.nix | [x] | NIXH-CORE-009 |
| PORT_REGISTRY | 10k/20k Port Schema | 00-core/ports.nix | [x] | NIXH-CORE-015 |
| SHELL_PREMIUM | SRE Productivity Tools | 00-core/shell-premium.nix | [x] | NIXH-CORE-001 |
| SYSTEM_STABILITY | OOM Protection & Hardening | 00-core/system-stability.nix | [x] | NIXH-CORE-016 |
| KERNEL_SLIM | Aggressive Module Blacklist | 00-core/kernel-slim.nix | [x] | NIXH-CORE-003 |

---
*Matrix generiert via scripts/generate-health-report.sh*
