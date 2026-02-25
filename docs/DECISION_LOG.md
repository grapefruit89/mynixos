# Decision Log

Stand: 2026-02-24

## Vorlage für neue Einträge
- Datum:
- Kontext:
- Entscheidung:
- Alternativen (kurz):
- Konsequenzen:
- Referenzen (Dateien/Commits):

## Einträge

### 2026-02-24: Source-of-Truth auf GitHub + sicherer Deploy-Ablauf
- Kontext: Lokale Drift und unterbrochene Sessions führten zu inkonsistenten Ständen.
- Entscheidung: GitHub `main` ist führend; Deploy nur via `git pull --ff-only` -> `nixos-rebuild test` -> `nixos-rebuild switch`.
- Alternativen (kurz): direkte ad-hoc Änderungen ohne Pull/Test.
- Konsequenzen: reproduzierbarer Betrieb, weniger Überraschungen.
- Referenzen: `docs/GITHUB_SOURCE_OF_TRUTH_MIGRATION.md`, `docs/OPERATIONS_GITHUB_PUSH.md`.

### 2026-02-24: Firewall wieder aktivieren
- Kontext: Firewall war temporär deaktiviert für Recovery/Heimnetz.
- Entscheidung: `networking.firewall.enable = true` als Normalzustand.
- Alternativen (kurz): Firewall dauerhaft aus.
- Konsequenzen: bessere Basissicherheit; fail2ban wieder sinnvoll.
- Referenzen: `00-core/firewall.nix`, `90-policy/security-assertions.nix`, Commit `364fa14`.

### 2026-02-24: SSH-Lockout-Schutz über openFirewall
- Kontext: expliziter Wunsch, Lockout-Risiko beim SSH-Zugang zu minimieren.
- Entscheidung: `services.openssh.openFirewall = true`.
- Alternativen (kurz): `openFirewall=false` mit rein interface-spezifischen Regeln.
- Konsequenzen: geringeres Lockout-Risiko, dafür bewusst mehr Offenheit auf SSH-Port.
- Referenzen: `00-core/ssh.nix`, `00-core/server-rules.nix`, `90-policy/security-assertions.nix`, Commit `364fa14`.

### 2026-02-24: Archiv-Konsolidierung mit aktiver/ historischer Trennung
- Kontext: Alte Dokumente enthalten wertvolle Ideen, aber auch widersprüchliche Stände.
- Entscheidung: aktive Doku ist maßgeblich, Archiv bleibt Ideenspeicher.
- Alternativen (kurz): Archiv als gleichwertige Truth-Source.
- Konsequenzen: weniger Fehlentscheidungen durch veraltete Snippets.
- Referenzen: `docs/archive/CONSOLIDATION_NOTES.md`, `docs/META_DECISIONS_AND_GOLDNUGGETS.md`.
