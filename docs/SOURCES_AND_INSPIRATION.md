# Sources & Inspiration (kuratiert)

Diese Datei sammelt externe Referenzen für langlebigen Betrieb, Security und Selfhosting-Architektur.

## 1) API-Key / Credential Portale
- Cloudflare API Tokens: https://dash.cloudflare.com/profile/api-tokens
- Tailscale Keys: https://login.tailscale.com/admin/settings/keys
- GitHub Personal Access Tokens: https://github.com/settings/tokens
- GitHub SSH Keys: https://github.com/settings/keys

## 2) Repo-Inspirationen (Owner-Liste)
- nixflix: https://github.com/kiriwalawren/nixflix
- nixarr: https://github.com/nix-media-server/nixarr
- awesome-selfhosted: https://github.com/awesome-selfhosted/awesome-selfhosted
- pms-wiki: https://github.com/IronicBadger/pms-wiki
- ironicbadger/nix-config: https://github.com/ironicbadger/nix-config
- ironicbadger/nix-install-kickoff: https://github.com/ironicbadger/nix-install-kickoff
- ironicbadger/nixpkgs: https://github.com/ironicbadger/nixpkgs
- ironicbadger/infra: https://github.com/ironicbadger/infra

## 3) Bewertungsraster für spätere Vergleiche
Bei Übernahme von Ideen immer entlang dieser Kriterien prüfen:
1. Security-Mehrwert für bestehende Guardrails?
2. Passt es in die bestehende Struktur (`00-core`, `10-infrastructure`, `20-services`, `90-policy`)?
3. Erhöht es Wartbarkeit oder nur Komplexität?
4. Ist es mit `my.ports.*` / zentralen Contracts konsistent?
5. Kann es mit Assertions/Speс-IDs abgesichert werden?

## 4) Nächster Schritt
Wenn gewünscht, kann als Follow-up ein `docs/INSPIRATION_DIFF.md` erstellt werden (pro Repo: "übernehmen", "später", "nicht relevant" + Begründung).
