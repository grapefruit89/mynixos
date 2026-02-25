# SSH Recovery Policy

## Verhalten
- **Wenn SSH-Key vorhanden ist** (`users.users.moritz.openssh.authorizedKeys.keys != []`):
  - `PasswordAuthentication = false`
  - `KbdInteractiveAuthentication = false`
- **Wenn kein SSH-Key vorhanden ist**:
  - Passwort-Login wird als Notfall-Fallback erlaubt
  - zusätzlich wird eine **Warnung in den Logs** geschrieben (`ssh-password-fallback-warning.service`).

## Warum "Keyboard-Auth"?
"Keyboard-Auth" (`KbdInteractiveAuthentication`) ist ein zusätzlicher SSH-Login-Mechanismus
(z. B. PAM/challenge-basiert). In diesem Repo wird er synchron zum Passwort-Fallback geschaltet,
damit es keine inkonsistenten Login-Pfade gibt.

## TTY-Notnagel
`PermitTTY = true` ist erzwungen und bleibt immer aktiv.
