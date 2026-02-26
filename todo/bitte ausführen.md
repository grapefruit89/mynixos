# Role: Senior Technical Writer & NixOS Architect
# Task: Repository Documentation Consolidation & Refactoring

## Context & Objectives
I have uploaded my entire NixOS project workspace. Currently, there are multiple markdown (`.md`) files scattered across the repository, including old logs, prompt histories, and architecture drafts. 
My goal is to clean up this repository. I want to extract ALL useful information from these scattered `.md` files and consolidate them into a highly structured, professional "Handbook" located strictly in a `docs/` directory.

## Strict Directives
1. Use ONLY the uploaded context. Do not invent missing information.
2. Read all `.md` files present in the uploaded workspace.
3. Consolidate redundancies. If three files talk about Wireguard, merge the facts into one cohesive section.
4. Output the results in GERMAN language.

## Required Output Structure (The "Docs" Library)
Generate the content for the following files. Each file must begin with a YAML Frontmatter block containing `title`, `author` (Moritz), `last_updated`, `status`, `source_id`, and `description`.

Generate these specific artifacts:

### Artifact 1: `docs/README.md` (The Table of Contents)
A clean index linking to all subsequent chapters.

### Artifact 2: `docs/01-ARCHITECTURE.md`
Consolidate all information about the hardware (Fujitsu Q958, i3-9100), the "Modular Layer Architecture" (00-core, 10-infrastructure, 20-services), and the specific storage strategy (direct mounts, hd-idle).

### Artifact 3: `docs/02-OPERATIONS.md`
Extract all workflows, aliases (`nsw`, `ntest`, `nclean`), and update procedures. This is the daily driver manual. Include the instructions on how to use the central registry (`configs.nix`).

### Artifact 4: `docs/03-SERVICES-AND-SECURITY.md`
List all configured services (Jellyfin, Arr-Stack, Traefik, etc.), their routing concepts, and the security policies (e.g., the Vanilla nftables VPN Killswitch).

### Artifact 5: `AI_CONTEXT.md` (To be placed in the repository root)
Create a specific "System Prompt" file designed to be read by future LLMs. It must explain the repository structure (Nix code in `nix/`, docs in `docs/`), the strict rules (no flakes, use layers), and refer the AI to the `docs/` directory via `source_id`s for deep-dives.

Please provide the complete Markdown content for each of these 5 files.

--- END PROMPT FÜR GEMINI ---
