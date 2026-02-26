# Role: Senior Site Reliability Engineer & NixOS Expert
# Task: Critical Configuration Refinement & Legacy-to-Modular Transition

## Context & Strategy (IMPORTANT)
I am building a NixOS homeserver on a Fujitsu Q958 (i3-9100, UHD 630). 
- I am explicitly NOT using Flakes at this stage to avoid unnecessary complexity. 
- However, the system should be "Flake-ready" by using a clean, modular directory structure (imports).
- Use the provided files in 'Context7' (Architecture Review, Roadmap, Best Practice Guide, shell.nix) as the primary knowledge base.

## Objectives
1. **Critical Audit Fixes:** Review the 'NIXOS_ARCHITEKTUR_REVIEW.md' and 'BEST_PRACTICE_GUIDE.md'. Implement the high-priority hardware and security fixes (Microcode, Intel GuC/HuC, SSH Hardening) using standard NixOS modules (NOT Flakes).
2. **Workflow Update:** Provide an updated version of `modules/00-system/shell.nix`. 
    - Adjust Aliases: Ensure `nsw` and `ntest` use standard `nixos-rebuild` commands without the `--flake` flag.
    - MOTD: Keep the professional login screen.
3. **Hardware Optimization:** Ensure Intel QuickSync (UHD 630) is correctly configured for Jellyfin using native NixOS options.
4. **Stability over Complexity:** If a recommendation from the previous review strictly requires a Flake, skip it or find a standard `configuration.nix` equivalent.

## Output Requirements (Artifacts)
Please provide the response in **GERMAN** and split the output into the following distinct artifacts/files:

1. **[Artifact: Status]** `AKTUELLER_PROJEKTSTATUS.md`: A summary of what is being changed now and what remains on the TODO list (without Flakes).
2. **[Artifact: MainConfig]** `configuration.nix`: A clean entry point that imports the necessary modules.
3. **[Artifact: ShellModule]** `shell.nix`: The updated workflow module with non-flake aliases.
4. **[Artifact: Guide]** `UMSETZUNGS_HILFE.md`: Simple, step-by-step instructions in German on how to apply these changes to the current system.

## Constraint Checklist
- NO `flake.nix` or `flake.lock`.
- Use standard `nix-channel` logic.
- Language: German.
- 
