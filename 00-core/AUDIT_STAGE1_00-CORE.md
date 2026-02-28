# 00-CORE: Anatomie eines Systemfehlers
> **Audit-Stufe 1 von 3** | Ebene: Fundament (Bootloader, Hardware, State-Management)  
> **Prüfer:** Senior NixOS Architect & SRE | **Datum:** 28.02.2026  

## 🔴 BEFUND 1: STORAGE_SAFE
**Requirement:** Defensive Mount-Optionen für alle Tiers. nofail und Timeout verhindern Emergency Mode.
**Status:** KRITISCH (Fehlendes nofail bei tier-b)

## 🔴 BEFUND 2: BOOT_SAFEGUARD
**Requirement:** Preflight Check vor Rebuild. Schutz der /boot Partition.
**Status:** KRITISCH (96MB Partition ohne Überwachung)

## 🔴 BEFUND 3: SECURITY_DEFAULTS
**Requirement:** bastelmodus auf default = false. Firewall standardmäßig AN.
**Status:** KRITISCH (Firewall standardmäßig AUS)

## 🟠 BEFUND 4: RECOVERY_WINDOW
**Requirement:** SSH Password Recovery Window (15min nach Boot) auf sicherem Port.
**Status:** HOCH (Gefährliche sed-Manipulation an sshd_config)

## 🟡 BEFUND 5: NIX_TUNING
**Requirement:** isLowRam-Logik reparieren. Cachix Platzhalter entfernen.
**Status:** MITTEL (|| true Hack macht Optimierung immer an)

## 🟡 BEFUND 6: SYMBIOSIS_CLEANUP
**Requirement:** Trennung Bauzeit vs. Laufzeit. Flache Strukturen.
**Status:** MITTEL (config-in-config Fehler)

## 🔴 BEFUND 7: SECRET_HYGIENE
**Requirement:** Keine Klartext-Keys im Repo. Rotation kompromittierter Keys.
**Status:** KRITISCH (WireGuard Key in Git)
