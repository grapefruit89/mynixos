---
title: NixOS Bibliothek Master Index
project: NMS v2.3
last_updated: 2026-03-02
status: Consolidated (Full Knowledge & Metadata Standard Complete)
author: Gemini Architect
---

# 📑 NIXOS BIBLIOTHEK MASTER INDEX

Dieser Index bündelt alle Informationen aus der "NixOs Bibliothek" (Unraid). Er dient als zentrale Anlaufstelle für die Architektur, Sicherheit und Weiterentwicklung des Homelabs.

## 🗂️ Gruppe 1: Architektur & Grundlagen (01-10)

1. **[01_ARCHITECTURE_AUDIT_ROADMAP.md](./01_ARCHITECTURE_AUDIT_ROADMAP.md)**
   - Umfassendes Audit des Gesamtsystems (Layer 00, 10, 20) und Projektplan.

2. **[02_HARDENING_SECURITY_POLICY.md](./02_HARDENING_SECURITY_POLICY.md)**
   - Zero-Trust Strategie, Cloudflare-Integration und System-Härtung.

3. **[03_SERVICE_PLANS_MIGRATIONS.md](./03_SERVICE_PLANS_MIGRATIONS.md)**
   - Pläne für Paperless-ngx, arr-Stack und Flake-Migration.

4. **[04_PROMPTS_DEVELOPMENT_RESOURCES.md](./04_PROMPTS_DEVELOPMENT_RESOURCES.md)**
   - Strukturelle Prompts und architektonische Logik-Patterns.

5. **[05_TECHNICAL_REFERENCE_SNIPPETS.md](./05_TECHNICAL_REFERENCE_SNIPPETS.md)**
   - Code-Tresor für "Exhaustion" Implementierungen und Q958 Spezifika.

6. **[06_STORAGE_PHILOSOPHY_ABC_MOVER.md](./06_STORAGE_PHILOSOPHY_ABC_MOVER.md)**
   - Fundamental Design: ABC-Tiering, MergerFS und Smart-Mover.

7. **[07_REVERSE_PROXY_CADDY_STRATEGY.md](./07_REVERSE_PROXY_CADDY_STRATEGY.md)**
   - Strategie für die Migration zu Caddy und Snippet-Architektur.

8. **[08_OMNITRACEABILITY_ID_SYSTEM.md](./08_OMNITRACEABILITY_ID_SYSTEM.md)**
   - Das Source-ID / Sink Traceability System und ID-Nomenklatur.

9. **[09_METADATA_STANDARDS_INTEGRITY.md](./09_METADATA_STANDARDS_INTEGRITY.md)**
   - Standards für YAML Frontmatter, Header und Integritäts-Footer.

10. **[10_PORTABILITY_HARDWARE_SYMBIOSIS.md](./10_PORTABILITY_HARDWARE_SYMBIOSIS.md)**
    - Strategie für Multi-Device Einsatz und Hardware-Abstraktion.

## 🛠️ Gruppe 2: Betrieb & Wartung (20-29)

20. **[20_OPERATIONS_WORKFLOW_RUNBOOK.md](./20_OPERATIONS_WORKFLOW_RUNBOOK.md)**
    - Standard-Deployment, Health-Checks und Git-Hygiene.

21. **[21_SSH_RECOVERY_ACCESS_POLICY.md](./21_SSH_RECOVERY_ACCESS_POLICY.md)**
    - SSH-Sicherheit, 5-Minuten Recovery Fenster und Key-aware Fallbacks.

22. **[22_ARR_STACK_API_WIRING.md](./22_ARR_STACK_API_WIRING.md)**
    - Automatisierte Vernetzung der Media-Services via `arr-wire.service`.

23. **[23_CODEBASE_HEALTH_TASKS.md](./23_CODEBASE_HEALTH_TASKS.md)**
    - Aktuelles Backlog für Fehlerkorrekturen und technisches Cleanup.

24. **[24_TRACEABILITY_RULES_SSOT.md](./24_TRACEABILITY_RULES_SSOT.md)**
    - Verfeinerte Regeln für die Zentralisierung in `configs.nix`.

## 📚 Gruppe 3: Deep-Dives & Referenz (30-39)

30. **[30_ARCHITECTURE_RECOVERY_DEEP_DIVE.md](./30_ARCHITECTURE_RECOVERY_DEEP_DIVE.md)**
    - Hardware-Tweaks, Q958-QuickSync und der "Daily Driver" Zyklus.

31. **[31_SECURITY_SOPS_SPECIFICS.md](./31_SECURITY_SOPS_SPECIFICS.md)**
    - Port-Registry (10k/20k), SOPS-Nix (TPM+Age) und VPN Killswitch.

32. **[32_HOME_MANAGER_USER_ENV.md](./32_HOME_MANAGER_USER_ENV.md)**
    - Home-Manager Guide, Dotfiles und Portabilitäts-Konzept für User-Profile.

33. **[33_EXTERNAL_INSPIRATION_IDEAS.md](./33_EXTERNAL_INSPIRATION_IDEAS.md)**
    - Best-Practices aus der Community (Nixarr, IronicBadger, Ryan4yin).

34. **[34_ROADMAP_AI_CONTEXT.md](./34_ROADMAP_AI_CONTEXT.md)**
    - Strategischer Ausblick (Phase 3+) und verbindliche Regeln für KI-Interaktionen.

35. **[35_REPO_HUNT_NIXARR_NIXFLIX.md](./35_REPO_HUNT_NIXARR_NIXFLIX.md)**
    - Goldnuggets aus Nixarr (API Extraction) und Nixflix (API Provisioning).

36. **[36_HOME_ASSISTANT_SLZB06_STRATEGY.md](./36_HOME_ASSISTANT_SLZB06_STRATEGY.md)**
    - Strategie für Ethernet Zigbee (SLZB-06), MQTT und Zigbee2MQTT.

37. **[37_MEDIA_STORAGE_NIXARR_ABC.md](./37_MEDIA_STORAGE_NIXARR_ABC.md)**
    - Spezifikation der standardisierten Nixarr-Ordnerstruktur gemappt auf ABC-Tiering.

38. **[38_NIXARR_LOGIC_NON_FLAKE.md](./38_NIXARR_LOGIC_NON_FLAKE.md)**
    - Anleitung zum Nachbau der Nixarr-Logik (VPN-Namespaces, API-Wiring) ohne Flakes.

## 🌟 Gruppe 4: Best Practices & Patterns (40-49)

40. **[40_NIXOS_PKGS_BEST_PRACTICES.md](./40_NIXOS_PKGS_BEST_PRACTICES.md)**
    - Professionelle Module-Patterns, High-Level Sandboxing und deklarative Config-Injection.

41. **[41_REALITY_CHECK_NIXPKGS_VS_LOCAL.md](./41_REALITY_CHECK_NIXPKGS_VS_LOCAL.md)**
    - Detaillierter Abgleich zwischen deinem lokalen Code und dem nixpkgs-Standard.

## 📜 Gruppe 5: Implementation & History (50-59)

50. **[50_SRE_UPGRADE_MARCH_2026.md](./50_SRE_UPGRADE_MARCH_2026.md)**
    - Dokumentation des massiven SRE-Upgrades (RAM-Logging, 1GB ESP, SRE-Standards).

51. **[51_INFRA_HARDENING_TUNING_MARCH_2026.md](./51_INFRA_HARDENING_TUNING_MARCH_2026.md)**
    - Analyse und Optimierung des Infrastructure-Layers (10) nach SRE-Standards.

52. **[52_APPS_UPGRADE_STORAGE_ZIGBEE_MARCH_2026.md](./52_APPS_UPGRADE_STORAGE_ZIGBEE_MARCH_2026.md)**
    - Change Log für den Umbau der App-Speicherpfade und den neuen Zigbee-Stack.

53. **[53_NIXARR_FLAKE_UPGRADE_MARCH_2026.md](./53_NIXARR_FLAKE_UPGRADE_MARCH_2026.md)**
    - Integration der Nixarr-Logik (VPN-Confinement, API-Sync) und Flake-Foundation.

## 🚀 Gruppe 6: Rollout & Reconstruction (60-69)

60. **[60_MARCH_2026_ROLLOUT_SUMMARY.md](./60_MARCH_2026_ROLLOUT_SUMMARY.md)**
    - Zusammenfassung der chirurgischen System-Rekonstruktion und Fehlerbehebung.

61. **[61_SSOT_CENTRALIZATION_STANDARDS.md](./61_SSOT_CENTRALIZATION_STANDARDS.md)**
    - Spezifikation des neuen Defaults-Systems und der Port-Registry.

62. **[62_RECOVERY_TTY_UX_REFORM.md](./62_RECOVERY_TTY_UX_REFORM.md)**
    - Dokumentation des passiven SSH-Rescue Modells ohne blockierenden TTY-Countdown.

63. **[63_SERVARR_FACTORY_HARDENING.md](./63_SERVARR_FACTORY_HARDENING.md)**
    - Vorstellung des Factory-Patterns für einheitliches Media-Hardening.

64. **[64_IOT_ZIGBEE_PROVISIONING.md](./64_IOT_ZIGBEE_PROVISIONING.md)**
    - Netzwerk-Discovery, IP-Korrektur und Migration auf den Zigbee-`ember` Treiber.

65. **[65_DYNAMICUSER_SOPS_TROUBLESHOOTING.md](./65_DYNAMICUSER_SOPS_TROUBLESHOOTING.md)**
    - Lösungen für Berechtigungsprobleme bei n8n und sops-nix unter DynamicUser.

66. **[66_UNIVERSAL_MIGRATION_GUIDE.md](./66_UNIVERSAL_MIGRATION_GUIDE.md)**
    - Umfassender Leitfaden für die Migration von Unraid/Docker zu nativem NixOS.

67. **[67_CLOUDFLARE_INGRESS_GUIDE.md](./67_CLOUDFLARE_INGRESS_GUIDE.md)**
    - Best-Practices für Cloudflare Tunnel, WAF-Regeln und Zero-Trust Ingress.

## 🔗 Gruppe 9: Externe Quellen & Links (99)

99. **[99_LINK_REGISTRY_SOURCES.md](./99_LINK_REGISTRY_SOURCES.md)**
    - Zentrales Verzeichnis aller Community-Repos, Cloud-Portale und technischen Wikis.

---

## 🏗️ System-Status (NMS v2.3)

| Ebene | Status | Fokus |
|---|---|---|
| **00-CORE** | 🟢 Flake-Ready | Boot-Safeguards (1GB), Portabilität, SRE-SSH. |
| **10-INFRA** | 🟢 Optimiert | PostgreSQL Tuning, AdGuard Rewrites, ClamAV Caps. |
| **20-SERVICES** | 🟢 Aviation Grade | VPN-Confinement, API-Key Sync, Zigbee Stack. |
| **90-POLICY** | 🟡 Draft | Übergang zu `security-assertions.nix`. |

---

## 📌 Archiv-Hinweis
Die Originaldateien befinden sich zur sicheren Aufbewahrung im Verzeichnis `./old_files/`. Alle relevanten Informationen wurden in die obigen Metadokumente extrahiert.
