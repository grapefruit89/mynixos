# Secrets/ENV Bootstrap (einfacher Start ohne sops)

Wenn du erstmal nur bauen willst, nutze die feste Template-Datei:
- `/etc/secrets/homelab-runtime-secrets.env.example`

## Schritt 1: echte Runtime-Datei anlegen
```bash
sudo install -d -m 700 /etc/secrets
sudo cp /etc/secrets/homelab-runtime-secrets.env.example /etc/secrets/homelab-runtime-secrets.env
sudo chmod 600 /etc/secrets/homelab-runtime-secrets.env
```

## Schritt 2: nur Werte eintragen
Nur rechts von `=` ausfüllen, Key-Namen nicht ändern.
Wichtige Pflichtfelder:
- `CLOUDFLARE_DNS_API_TOKEN`
- `WG_PRIVADO_PRIVATE_KEY`

Optional für ARR-Helper:
- `SONARR_API_KEY`, `RADARR_API_KEY`, `PROWLARR_API_KEY`, `SABNZBD_API_KEY`

## Schritt 3: prüfen
```bash
sudo systemctl restart traefik
sudo systemctl start arr-wire.service
sudo journalctl -u traefik -n 100 --no-pager
sudo journalctl -u arr-wire -n 100 --no-pager
```
