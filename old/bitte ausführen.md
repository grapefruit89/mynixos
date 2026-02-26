# Role: Senior Technical Writer & NixOS Architect
# Task: Repository Documentation Consolidation & Refactoring

## Context & Objectives
I have uploaded my entire NixOS project workspace. Currently, there are multiple markdown (`.md`) files scattered across the repository, including old logs, prompt histories, and architecture drafts. 
My goal is to clean up this repository. I want to extract ALL useful information from these scattered `.md` files and consolidate them into a highly structured, professional, and beautifully readable "Handbook" located strictly in a `docs/` directory.

## Strict Directives
1. **Zero Knowledge Loss:** You must extract ALL valid technical configurations, workflows, and concepts from the uploaded files. Do not drop important details.
2. **Fill the Gaps:** You are allowed to add context or NixOS best practices if it helps to explain a concept better or bridges a gap between two files. 
3. **Human Readability First:** Structure the markdown beautifully. Use tables for port lists, code blocks for commands, and blockquotes for important warnings. It must read like a premium technical manual.
4. **Language:** Output all results strictly in GERMAN.

## Required Output Structure (The "Docs" Library)
Generate the content for the following files. Each file must begin with a YAML Frontmatter block containing `title`, `author` (Moritz), `last_updated`, `status`, `source_id`, and `description`.

Generate these specific artifacts:

### Artifact 1: `docs/README.md` (The Table of Contents)
A beautiful index linking to all subsequent chapters. Include a short welcome message and the general purpose of the Fujitsu Q958 Homeserver.

### Artifact 2: `docs/01-ARCHITECTURE.md`
Consolidate all information about the hardware (Fujitsu Q958, i3-9100), the "Modular Layer Architecture" (00-core, 10-infrastructure, 20-services), and the specific storage strategy (direct mounts without mergerfs, hd-idle).

### Artifact 3: `docs/02-OPERATIONS.md`
Extract all workflows, aliases (`nsw`, `ntest`, `nclean`), and update procedures. This is the daily driver manual. Include the instructions on how to use the central registry (`configs.nix`) and how the vanilla Bash-MOTD works.

### Artifact 4: `docs/03-SERVICES-AND-SECURITY.md`
List all configured services (Jellyfin, Arr-Stack, Traefik, etc.), their routing concepts, and the security policies (e.g., the Vanilla nftables VPN Killswitch). Use a table to show which service runs on which port.

### Artifact 5: `docs/04-BACKLOG-AND-IDEAS.md`
Create a document for future improvements. Explicitly add the idea to replace the vanilla Bash MOTD with `fastfetch` later to display custom ASCII art, mount capacities, and service status. Add any other good ideas found in the old notes.

### Artifact 6: `AI_CONTEXT.md` (To be placed in the repository root)
Create a specific "System Prompt" file designed to be read by future LLMs. It must explain the repository structure (Nix code in `nix/`, docs in `docs/`), the strict rules (no flakes, use layers, vanilla over abstraction), and refer the AI to the `docs/` directory via `source_id`s for deep-dives.

Please provide the complete, beautifully formatted Markdown content for each of these 6 files.
