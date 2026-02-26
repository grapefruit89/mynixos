# 📝 Implementierungs-Bericht & System-Refactoring (V2)
**Datum:** 26. Februar 2026
**Status:** Erfolgreich abgeschlossen & Aktiviert

## 🎯 Zusammenfassung der durchgeführten Arbeiten

Basierend auf dem Architektur-Review und den Best-Practice-Vorgaben wurde das System grundlegend restrukturiert, um Modularität, Portabilität und Sicherheit zu maximieren.

---

## 🛠️ 1. Struktur & Architektur

### 🎮 Feature-Registry (`00-core/registry.nix`)
- Einführung eines zentralen Toggle-Systems via `lib.mkEnableOption`.
- Erlaubt das globale Aktivieren/Deaktivieren von Hardware-Profilen und Netzwerk-Features in der `configs.nix`.

### 🏎️ Hardware-Profil (`hosts/q958/hardware-profile.nix`)
- Konsolidierung aller Intel-spezifischen Optimierungen (GuC/HuC, UHD 630 Performance, Microcode).
- **GPU:** Kernel-Parameter `i915.enable_guc=2` und `i915.enable_fbc=1` aktiviert.
- **Treiber:** `intel-media-driver`, `intel-compute-runtime` und `vpl-gpu-rt` für perfektes Transcoding.
- **Tools:** `libva-utils` und `intel-gpu-tools` vorinstalliert.

### 🏠 Home-Manager Integration (`00-core/home-manager.nix`)
- Native Einbindung als NixOS-Modul (Channel-basiert).
- Vorbereitet für userspezifische Konfigurationen des Users `moritz`.

---

## 🌐 2. Netzwerk & Konnektivität

### 🚀 Migration auf systemd-networkd
- Ablösung des NetworkManagers durch den schlankeren `systemd-networkd` (Server-Standard).
- DHCP-Konfiguration pro Interface.

### 📢 Avahi / mDNS (nixhome.local)
- Aktivierung von Avahi (`nssmdns4`).
- Der Server ist nun im LAN unter **`nixhome.local`** erreichbar (kein IP-Merken mehr nötig).

---

## 🛡️ 3. Sicherheit (Hardening)

### 🧱 VPN Killswitch (`00-core/killswitch.nix`)
- Implementierung eines nativen **NFTables-Killswitch**.
- Traffic der Gruppen `sabnzbd`, `sonarr`, `radarr` und `prowlarr` wird hart blockiert, wenn er nicht über den VPN-Tunnel (`privado`) oder das lokale LAN fliesst.

### 🧊 Binary-Only Policy (`00-core/system.nix`)
- **WICHTIG:** Um extreme CPU-Last zu verhindern, wurde das System angewiesen, Binärpakete strikt zu bevorzugen (`builders-use-substitutes = true`). Lokales Bauen aus dem Quellcode findet nur noch im absoluten Notfall statt.

---

## 🔍 4. Erklärungen & Status-Checks

### 💡 Der "Emby Modus" Mythos
- In den Jellyfin-Logs auftauchende Meldungen wie "Emby.Server" sind **kein Fehler**. Jellyfin ist ein Fork von Emby und nutzt intern noch viele dieser Bezeichnungen. Das System ist korrekt konfiguriert.

### 💾 Speicherplatz (`/boot`)
- Nach dem Rebuild wurde ein gründlicher Cleanup durchgeführt.
- **Status:** 32MB (32%) frei. Regelmäßiges `nclean` (Alias) wird empfohlen.

### ⚙️ HD-Idle
- Der Dienst ist im Hardware-Profil vorbereitet, aber aktuell auskommentiert, da das NixOS-Modul im gewählten Channel fehlte. Ein manueller Systemd-Service kann bei Bedarf nachgerüstet werden.

---

## 🚀 Nächste Schritte
- Überprüfung der Erreichbarkeit via `ssh moritz@nixhome.local`.
- Test des Transcodings in Jellyfin (via `intel_gpu_top`).
- Monitoring-Integration (Netdata/Scrutiny).
