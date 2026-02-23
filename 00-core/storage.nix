# modules/00-system/storage.nix
# ══════════════════════════════════════════════════════════════════════════════
# DUMMY – NOCH NICHT AKTIV
# ══════════════════════════════════════════════════════════════════════════════
# Dieser Eintrag wird erst ausgearbeitet wenn alle HDDs per `ls -la /dev/disk/by-id/`
# identifiziert wurden und disko.nix fertig ist.
#
# AUFGABEN (in dieser Reihenfolge):
#   1. Disk-IDs ermitteln:       ls -la /dev/disk/by-id/
#   2. Mountpoints festlegen:
#        /storage/hdd1  → Seagate  298GB  (Filme)
#        /storage/hdd2  → Hitachi  500GB  (Serien)
#        /storage/hdd3  → WD       500GB  (Bücher/Hörbücher)
#        /downloads     → Apacer NVMe 250GB (Download-Cache)
#   3. hd-idle einrichten:       Spindown nach 600 Sekunden
#   4. .staging/ Ordner je HDD:  für Atomic Move durch SABnzbd
#
# DIESES MODUL ERST IMPORTIEREN wenn es vollständig ausgearbeitet ist!
# (Import in hosts/q958/default.nix ergänzen)
# ══════════════════════════════════════════════════════════════════════════════
{ ... }:
{
  # Platzhalter – keine aktiven Einstellungen
}
