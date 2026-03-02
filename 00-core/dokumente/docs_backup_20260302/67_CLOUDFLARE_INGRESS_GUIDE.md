---
title: Cloudflare Complete Setup Guide
author: Moritz Baumeister
project: mynixos
last_updated: 2026-02-26
version: 2.0
---

# ☁️ CLOUDFLARE COMPLETE GUIDE

Dieser Guide erklärt **alles** rund um Cloudflare-Integration in mynixos.

---

## 🎯 **Übersicht: Cloudflare-Komponenten**

| Komponente | Zweck | Erforderlich |
|------------|-------|--------------|
| **DNS Edit Token** | Traefik ACME (LetsEncrypt) | ✅ JA |
| **Cloudflare Tunnel** | Öffentlicher Zugriff ohne Port-Forwarding | 🟡 Optional |
| **Cloudflare Access** | SSO für öffentliche Services | 🟡 Optional |
| **Proxy (Orange Cloud)** | DDoS-Schutz + Cache | ⚠️ **NUR FÜR MANCHE SERVICES!** |

---

## 🚨 **KRITISCH: Cloudflare Proxy Rules**

### ❌ **Diese Services NIEMALS proxied (Orange Cloud = OFF)**

| Service | Grund | Konsequenz bei Proxy |
|---------|-------|----------------------|
| **Jellyfin** | Video-Streaming | Bandbreiten-Limit → Account-Suspension |
| **Plex** | Video-Streaming | ToS-Verstoß |
| **Audiobookshelf** | Audio-Streaming | Rate-Limits |
| **Navidrome** | Musik-Streaming | Cloudflare blockiert nach ~200GB/Tag |
| **Immich** | Foto-Upload/-Download | Timeouts bei großen Dateien |
| **Nextcloud** | WebDAV (große Dateien) | Max. 100MB Upload-Limit |
| **SABnzbd** | NZB-Downloads | Bandwidth-Throttling |
| **Transmission** | Torrent-Traffic | Cloudflare blockt |

**Regel:** Alles mit **Streaming oder großen Datei-Transfers = Proxy AUS**

---

### ✅ **Diese Services SOLLTEN proxied werden (Orange Cloud = ON)**

| Service | Grund |
|---------|-------|
| **Homepage** | DDoS-Schutz + Cache |
| **Traefik-Dashboard** | IP-Verschleierung |
| **Vaultwarden** | Extra Sicherheits-Layer |
| **Miniflux/Readeck** | RSS-Content-Proxying |
| **Pocket-ID** | SSO-Provider schützen |
| **AdGuard Home** (falls öffentlich) | DDoS-Schutz |

---

## 📝 **Teil 1: Token-Management**

### 1.1 **DNS Edit Token erstellen**

**Zweck:** Traefik kann automatisch DNS-01 Challenges für LetsEncrypt lösen.

**Schritt-für-Schritt:**

1. **Login:** [dash.cloudflare.com](https://dash.cloudflare.com)
   
2. **Navigieren:**
   ```
   My Profile → API Tokens → Create Token
   ```

3. **Template auswählen:**
   ```
   "Edit zone DNS" → Use template
   ```

4. **Permissions konfigurieren:**
   ```yaml
   Zone:
     - DNS: Edit
   
   Zone Resources:
     - Include: Specific zone
     - m7c5.de (deine Domain auswählen)
   ```

5. **Token erstellen:**
   ```
   Continue to summary → Create Token
   ```

6. **Token kopieren:**
   ```
   ⚠️ WICHTIG: Nur EINMAL angezeigt!
   Beispiel: xYz123AbC456...
   ```

7. **Im System hinterlegen:**
   ```bash
   sudo micro /etc/secrets/homelab-runtime-secrets.env
   
   # Zeile hinzufügen:
   CLOUDFLARE_DNS_API_TOKEN=xYz123AbC456...
   ```

8. **Permissions setzen:**
   ```bash
   sudo chmod 600 /etc/secrets/homelab-runtime-secrets.env
   sudo chown root:root /etc/secrets/homelab-runtime-secrets.env
   ```

9. **Traefik neu starten:**
   ```bash
   sudo systemctl restart traefik
   
   # Logs prüfen:
   journalctl -u traefik -f
   # Sollte zeigen: "Obtaining certificate for *.m7c5.de"
   ```

---

### 1.2 **Token validieren (Test-Script)**

```bash
#!/bin/bash
# Test: Ist der Token gültig?

TOKEN="DEIN_TOKEN_HIER"

curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  | jq .

# Erwartete Ausgabe:
# {
#   "success": true,
#   "result": {
#     "status": "active"
#   }
# }
```

---

## 🚇 **Teil 2: Cloudflare Tunnel (Optional)**

### 2.1 **Wann brauchst du einen Tunnel?**

**JA, wenn:**
- ✅ Du keinen Public-IP-Port-Forward machen kannst/willst
- ✅ Du hinter CGNAT bist (Mobilfunk, Kabel-Internet)
- ✅ Du extra DDoS-Schutz willst

**NEIN, wenn:**
- ❌ Du bereits Traefik mit Port 443 exposed hast
- ❌ Du nur LAN/Tailscale-Zugriff brauchst
- ❌ Du Streaming-Services (Jellyfin) nutzt (siehe Proxy-Rules!)

---

### 2.2 **Tunnel erstellen**

1. **Cloudflare Zero Trust öffnen:**
   ```
   dash.cloudflare.com → Zero Trust
   ```

2. **Tunnel erstellen:**
   ```
   Networks → Tunnels → Create a tunnel
   
   Name: q958-homelab
   Type: Cloudflared
   ```

3. **Connector installieren:**
   ```
   ⚠️ NICHT den Cloudflare-Befehl nutzen!
   Wir verwenden NixOS-Integration:
   ```

4. **Token kopieren:**
   ```
   Tunnel → Configure → Token anzeigen
   Beispiel: eyJhIjoiZjM4...
   ```

5. **In NixOS hinterlegen:**
   ```bash
   # Erstelle Credentials-File
   sudo mkdir -p /etc/secrets/cloudflared
   sudo nano /etc/secrets/cloudflared/m7c5-tunnel.json
   
   # Inhalt (Tunnel-JSON von Cloudflare):
   {
     "AccountTag": "abc123...",
     "TunnelSecret": "...",
     "TunnelID": "00000000-0000-0000-0000-000000000000"
   }
   
   # Permissions
   sudo chmod 600 /etc/secrets/cloudflared/m7c5-tunnel.json
   ```

6. **Tunnel-ID in configs.nix:**
   ```nix
   # In cloudflared-tunnel.nix bereits vorbereitet!
   my.cloudflare.tunnel = {
     enable = true;
     tunnelId = "00000000-0000-0000-0000-000000000000";  # Deine ID
     domain = "m7c5.de";
     wildcardPrefix = "nix-*";
   };
   ```

7. **Public Hostname konfigurieren (Cloudflare UI):**
   ```
   Tunnel → Public Hostname → Add

   Subdomain: nix-*
   Domain: m7c5.de
   Type: HTTP
   URL: https://localhost:443  (Traefik)
   
   ⚠️ WICHTIG: TLS Verification = OFF
   ```

8. **Rebuild & Test:**
   ```bash
   sudo nixos-rebuild switch
   
   # Test (von extern):
   curl -I https://nix-homepage.m7c5.de
   # Sollte 200 OK zeigen
   ```

---

### 2.3 **Tunnel vs. Direct Port-Forward**

| Feature | Tunnel | Port-Forward |
|---------|--------|--------------|
| Setup-Komplexität | Mittel | Einfach |
| DDoS-Schutz | ✅ Ja | ❌ Nein |
| Latenz | +20-50ms | 0ms |
| Bandbreite | Begrenzt | Unbegrenzt |
| Jellyfin/Streaming | ❌ Nicht empfohlen | ✅ Optimal |

**Empfehlung für mynixos:**
- **Tunnel:** Für Admin-Interfaces (Traefik, Pocket-ID, Homepage)
- **Direct:** Für Jellyfin, Plex, Audiobookshelf

---

## 🔐 **Teil 3: Cloudflare Access (SSO)**

### 3.1 **Cloudflare Access vs. Pocket-ID**

| Feature | Pocket-ID | Cloudflare Access |
|---------|-----------|-------------------|
| Hosting | Lokal (self-hosted) | Cloudflare |
| Kosten | €0 | €0-7/User/Monat |
| Passkeys | ✅ Native | ✅ Via OIDC |
| Latenz | 0ms | 20-50ms |
| Offline-Zugriff | ✅ Ja | ❌ Nein (braucht Internet) |
| Setup | Mittel | Einfach |

**Empfehlung:**
- **Pocket-ID:** Für LAN/Tailscale (intern)
- **Cloudflare Access:** Für Tunnel-Services (extern)

---

### 3.2 **Cloudflare Access einrichten**

1. **Zero Trust → Access → Applications → Add**

2. **Self-hosted Application:**
   ```
   Name: Sonarr
   Subdomain: nix-sonarr
   Domain: m7c5.de
   ```

3. **Identity Provider hinzufügen:**
   ```
   Settings → Authentication → Add
   
   Optionen:
   - Google OAuth (kostenlos)
   - GitHub OAuth
   - One-time PIN (Email)
   - OIDC (z.B. Pocket-ID!)
   ```

4. **Policy erstellen:**
   ```
   Regel: "Admin Access"
   Include: Emails ending in @gmail.com
   Action: Allow
   ```

5. **Testen:**
   ```
   https://nix-sonarr.m7c5.de
   → Cloudflare Access Login
   → Nach Authentifizierung: Zugriff
   ```

---

### 3.3 **Pocket-ID als OIDC-Provider für Cloudflare Access**

**Vorteil:** Lokales Passkey-Login, aber Cloudflare schützt öffentliche Services

```yaml
# Cloudflare Zero Trust Settings:
Identity Provider: Generic OIDC

OIDC Config:
  Name: Pocket-ID
  App ID: (von Pocket-ID)
  Client Secret: (von Pocket-ID)
  Auth URL: https://auth.m7c5.de/oauth/authorize
  Token URL: https://auth.m7c5.de/oauth/token
  Certificate URL: https://auth.m7c5.de/.well-known/jwks.json
```

**Setup in Pocket-ID:**
```nix
# pocket-id.nix erweitern:
services.pocket-id.settings = {
  # ... bestehende Config ...
  
  oauth_clients = [{
    client_id = "cloudflare-access";
    client_secret = "xxx";  # Generiert via: openssl rand -hex 32
    redirect_uris = [
      "https://m7c5.cloudflareaccess.com/cdn-cgi/access/callback"
    ];
  }];
};
```

---

## ⚙️ **Teil 4: DNS-Records Setup**

### 4.1 **Welche DNS-Records brauchst du?**

**Minimum (ohne Tunnel):**
```
A     @           -> DEINE_PUBLIC_IP
A     *           -> DEINE_PUBLIC_IP  (Wildcard)
AAAA  @           -> DEINE_IPv6 (optional)
AAAA  *           -> DEINE_IPv6 (optional)
```

**Mit Tunnel:**
```
CNAME nix-*       -> TUNNEL_ID.cfargotunnel.com
```

---

### 4.2 **Proxy-Status setzen (WICHTIG!)**

**Schritt 1: Alle Records erstellen**
```bash
# Beispiel via Cloudflare API:
curl -X POST "https://api.cloudflare.com/client/v4/zones/ZONE_ID/dns_records" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "jellyfin",
    "content": "DEINE_IP",
    "proxied": false  # ← Proxy AUS für Streaming!
  }'
```

**Schritt 2: Proxy-Status konfigurieren (Cloudflare UI)**

```
DNS → Records

✅ Orange Cloud (Proxied):
  - homepage.m7c5.de
  - traefik.m7c5.de
  - auth.m7c5.de
  - vault.m7c5.de

❌ Grey Cloud (DNS-only):
  - jellyfin.m7c5.de
  - nix-jellyfin.m7c5.de
  - audiobookshelf.m7c5.de
  - navidrome.m7c5.de
```

---

### 4.3 **Automatische Proxy-Konfiguration (Script)**

```bash
#!/bin/bash
# Setzt Proxy-Status basierend auf Service-Typ

# Services die NICHT proxied werden dürfen
NO_PROXY=(
  "jellyfin"
  "plex"
  "audiobookshelf"
  "navidrome"
  "immich"
  "nextcloud"
  "sabnzbd"
  "transmission"
)

# Services die proxied werden sollten
PROXY=(
  "homepage"
  "traefik"
  "auth"
  "vault"
  "miniflux"
  "readeck"
)

# Token & Zone-ID
TOKEN="DEIN_TOKEN"
ZONE_ID="DEINE_ZONE_ID"

# Alle DNS-Records holen
RECORDS=$(curl -s -X GET \
  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $TOKEN")

# Proxy-Status setzen
for service in "${NO_PROXY[@]}"; do
  RECORD_ID=$(echo "$RECORDS" | jq -r ".result[] | select(.name | contains(\"$service\")) | .id")
  
  if [ -n "$RECORD_ID" ]; then
    curl -X PATCH \
      "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      --data '{"proxied": false}'
    
    echo "✅ $service: Proxy deaktiviert"
  fi
done
```

**Speichern als:** `scripts/cloudflare-proxy-config.sh`

---

## 📊 **Teil 5: Monitoring & Troubleshooting**

### 5.1 **Cloudflare Analytics**

```
dash.cloudflare.com → Analytics & Logs

Wichtige Metriken:
- Requests/Day (sollte <1M sein für Free)
- Bandwidth (sollte <200GB/Tag sein)
- Blocked Threats (DDoS-Versuche)
```

**Warnung bei Jellyfin über Proxy:**
```
Bandwidth: 500 GB/Tag ⚠️
Status: Account wird gesperrt in 24h!

Lösung: Proxy für jellyfin.m7c5.de deaktivieren
```

---

### 5.2 **Häufige Fehler & Lösungen**

#### Problem 1: "522 Connection Timed Out"
```
Ursache: Traefik antwortet nicht
Lösung:
  1. systemctl status traefik
  2. Firewall prüfen: Port 443 offen?
  3. Cloudflare Proxy temporär aus (Grey Cloud)
```

#### Problem 2: "525 SSL Handshake Failed"
```
Ursache: TLS-Config-Mismatch
Lösung (Cloudflare UI):
  SSL/TLS → Overview → Full (strict)
```

#### Problem 3: "Video puffert ständig (Jellyfin)"
```
Ursache: Cloudflare Proxy ist AN
Lösung:
  DNS → jellyfin.m7c5.de → Orange Cloud AUS
```

---

## 🎯 **Quick Reference Card**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CLOUDFLARE CHEAT SHEET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TOKEN PRÜFEN:
  curl "https://api.cloudflare.com/client/v4/user/tokens/verify" \
    -H "Authorization: Bearer $TOKEN"

DNS-RECORDS AUFLISTEN:
  curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
    -H "Authorization: Bearer $TOKEN" | jq .

PROXY STATUS ÄNDERN (Grey Cloud):
  curl -X PATCH \
    "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $TOKEN" \
    --data '{"proxied": false}'

TUNNEL-STATUS:
  systemctl status cloudflared
  journalctl -u cloudflared -f

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

**Guide Ende** | Version 2.0 | Stand: 2026-02-26
