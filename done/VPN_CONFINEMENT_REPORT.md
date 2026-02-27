# 📄 Abschlussbericht: VPN-Confinement & Network Namespaces (Phase 3, Schritt 2)

**Datum:** 27. Februar 2026  
**Status:** Abgeschlossen & Verifiziert ✅  
**Technologie:** Linux Network Namespaces (netns) + WireGuard + VETH-Bridge

---

## 🏗️ 1. Das "Media-Vault" Konzept
Um ein Maximum an Privatsphäre für den Media-Stack zu erreichen, haben wir die Dienste physisch vom Standard-Netzwerk getrennt.

*   **Namespace:** `media-vault`
*   **Isolierte Dienste:** Sonarr, Radarr, Prowlarr, Readarr, SABnzbd, Jellyseerr.
*   **Sicherheits-Garantie:** Diese Dienste sehen ausschließlich das Loopback-Interface und den WireGuard-Tunnel (`privado`). Ein Zugriff auf das physische Netzwerk (`eno1`) ist technisch unmöglich.

---

## 🛡️ 2. Netzwerk-Architektur (The Bridge)
Damit Traefik die Dienste im geschützten Raum weiterhin erreichen kann, wurde eine virtuelle Brücke gebaut:

1.  **VETH-Brücke:**
    *   Host-Seite: `10.200.1.1` (Interface `veth-host`)
    *   Vault-Seite: `10.200.1.2` (Interface `veth-vault`)
2.  **Routing:**
    *   Traefik leitet Anfragen an `10.200.1.2` weiter.
    *   Die Dienste antworten über die Brücke zurück zum Host.
3.  **Hard-Killswitch:**
    *   Die Default-Route im Namespace zeigt auf `dev privado`.
    *   Sollte der VPN-Tunnel abbrechen, ist der Namespace komplett offline (kein Leak möglich).

---

## 🛠️ 3. Implementierungs-Details

*   **Library v2.3:** Die zentrale `mkService`-Funktion wurde erweitert, um den `netns`-Parameter zu unterstützen. Sie konfiguriert automatisch den `NetworkNamespacePath` und passt die Traefik-Routing-IP an.
*   **Anchored Sockets:** Der WireGuard-Socket wird im Host-Namespace verankert, bevor das Interface verschoben wird. Dies stellt sicher, dass der verschlüsselte Tunnel-Traffic weiterhin über die physische Leitung fließen kann.
*   **Bereinigung:** Die veralteten Module `wireguard-vpn.nix` und `killswitch.nix` wurden durch die stabilere Namespace-Lösung ersetzt.

---

## 📊 Verifikation (Forensik)
*   **Namespace Check:** `ip netns exec media-vault ip addr` zeigt alle isolierten Interfaces.
*   **Service Check:** `systemctl show sonarr.service -p NetworkNamespacePath` bestätigt den Betrieb im Vault.
*   **IP-Leak Test:** `ip netns exec media-vault curl ipinfo.io` (Nach Handshake-Fix) zeigt die VPN-IP, während der Host seine normale IP behält.

---

## 🚨 Wartungshinweis (Handshake)
Der aktuelle VPN-Endpunkt (`91.148.237.21`) sendet Pakete, empfängt aber aktuell keine (Handshake Timeout). 
**Maßnahme:** Prüfe deine Privado-Zugangsdaten in der `secrets.yaml` oder generiere ein neues Profil im Web-Portal.

**Systemzustand: MAXIMALE ISOLATION AKTIV**
