# Spec Registry (Security & Operations)

Diese IDs sind die verbindliche Referenz zwischen Doku, Code und Assertions.

## SSH / Access
- **[SEC-SSH-PORT-001]** SSH läuft auf `my.ports.ssh` (kein Hardcode).
- **[SEC-SSH-TTY-001]** `PermitTTY` muss immer `true` bleiben.
- **[SEC-SSH-AUTH-001]** Key vorhanden => Passwort/Kbd-Auth aus.
- **[SEC-SSH-AUTH-002]** Kein Key => Passwort/Kbd-Fallback erlaubt + Warnung.
- **[SEC-SSH-SVC-001]** `services.openssh.enable = true`.
- **[SEC-SSH-SVC-002]** `sshd` muss `Restart=always` haben.
- **[SEC-SSH-SVC-003]** `sshd` muss via `multi-user.target` gestartet werden.

## Firewall / Network
- **[SEC-NET-SSH-001]** SSH niemals global ins Internet öffnen.
- **[SEC-NET-SSH-002]** SSH nur aus privaten Netzen + Tailnet erlauben.
- **[SEC-NET-EDGE-001]** Global inbound TCP nur notwendige Edge-Ports (derzeit HTTPS).

## Secrets
- **[SEC-SECRET-CF-001]** Cloudflare DNS var bleibt `CLOUDFLARE_DNS_API_TOKEN`.

## Traceability-Konvention
- In Code-Kommentaren IDs als `[SEC-...-NNN]` einfügen.
- In Assertions IDs im `message`-Text voranstellen.
- Querprüfung z. B. mit:
  - `rg -n "\[SEC-" 00-core 10-infrastructure 20-services 90-policy docs`
