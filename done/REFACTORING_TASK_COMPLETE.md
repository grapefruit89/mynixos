---
title: REFACTORING_TASK_COMPLETE
category: Betrieb
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: 68390710df1b3c93907c453b91ad0c98a0d5a0d63207c36a04e6fe63d218b266
---
# Role: Senior NixOS Architect & Security Engineer (SRE)
# Task: High-Priority System Hardening & Optimization based on "Quick Wins" and "Review"

## 1. STRATEGIC BASELINE & CONTEXT
- **Source of Truth:** Use Context 7 (uploaded workspace) and the newly provided architectural documents (`MASTER_STATUS.md`, `NIXOS_ARCHITEKTUR_REVIEW.md`).
- **Objective:** Implement the "Quick Wins" and advanced performance modules while maintaining the established "Modular Layer Architecture" (00-core, 10-infrastructure, 20-services).
- **Core Principle:** Treat the provided `.nix` and `.md` snippets as high-quality templates. If you find even better, more secure, or more efficient ways to implement these features within the NixOS ecosystem, you are ENCOURAGED to do so.

## 2. REQUIRED IMPLEMENTATION STEPS

### A. Critical Safeguards (Priority: P0)
- **Boot-Partition Protection:** Implement the logic from `boot-safeguard.nix` to prevent the 96MB `/boot` partition from overflowing. Ensure aggressive garbage collection and a strict generation limit (max 5).
- **SSH Rescue Window:** Integrate `ssh-rescue.nix` to provide a 5-minute password login window after boot to prevent permanent lockout.

### B. Security & Identity (Priority: P1)
- **SSO Integration:** Implement the "Pocket-ID + Traefik ForwardAuth" stack as described in `sso.nix`. Protect the following services behind the SSO gate: Sonarr, Radarr, Prowlarr, Traefik Dashboard, and Netdata.
- **SSH Hardening:** Cross-reference `ssh.nix` and `NIXOS_ARCHITEKTUR_REVIEW.md` to enforce Ed25519-only authentication and disable legacy protocols.

### C. Performance & Workflow (Priority: P2)
- **Kernel Slimming:** Apply the Q958-specific kernel optimizations from `kernel-slim.nix` to save RAM (~300MB) and improve boot times.
- **Premium Shell:** Enhance the shell environment using `shell-premium.nix`. This includes `fastfetch` for the TUI dashboard, Git workflow aliases, and advanced monitoring tools (ncdu, btop).

### D. Documentation & Traceability
- **Handbook Update:** Refactor the consolidated documentation (Handbook) to include these new modules.
- **Source-ID System:** Ensure every new module follows the `source-id` / `sink` traceability system.
- **AI_CONTEXT:** Update the root `AI_CONTEXT.md` to reflect the newly implemented security and storage features.

## 3. TECHNICAL CONSTRAINTS
- **Modular Integration:** Place the files in their correct folders (`00-core/`, `10-infrastructure/`).
- **Idempotency:** All scripts (e.g., boot-check, ssh-recovery-status) must be idempotent.
- **Language:** All code comments and documentation must be in GERMAN.
- **No Guessing:** If the link between a service and the SSO gateway is unclear, flag it as a "GAP".

## 4. OUTPUT EXPECTATION
Provide the refined Nix code for each module and the updated documentation files. Explain any architectural improvements you made over the provided templates.

