/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-027
 *   title: "Storage (SRE Tiering)"
 *   layer: 00
 * summary: mergerfs pool management and smart tiered mover logic.
 * source_nixpkgs: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/mergerfs.nix
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.storage-pool;
  user = config.my.configs.identity.user;
  
  rootMinFree = "20G";
  ssdMinFree = "50G";
in
{
  config = lib.mkIf cfg.enable {
    
    # ── POOL DEFINITION ─────────────────────────────────────────────────────
    systemd.mounts = [
      {
        description = "Fast-Pool (B-Daten)";
        where = "/mnt/fast-pool";
        what = "/data/storage/b-on-a:/mnt/storage/ssd:/mnt/storage/hdd";
        type = "fuse.mergerfs";
        # SRE Optimierung: cache.readdir und dropcacheonclose für Spindown-Support
        options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${rootMinFree},fsname=fast-pool";
        wantedBy = [ "multi-user.target" ];
      }
      {
        description = "Media-Pool (C-Daten)";
        where = "/mnt/media";
        what = "/mnt/storage/ssd:/mnt/storage/hdd";
        type = "fuse.mergerfs";
        options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${ssdMinFree},fsname=media-pool,cache.files=partial";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    # ── SMART DISK DISCOVERY ───────────────────────────────────────────────
    # Dynamische Einbindung von Hardware-Komponenten (Bescheidene Gehversuche)
    systemd.services.nixhome-disk-discovery = {
      description = "NixHome Smart Disk Discovery";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      path = with pkgs; [ util-linux coreutils gawk ];
      script = ''
        mkdir -p /mnt/storage/ssd /mnt/storage/hdd /data/storage/b-on-a /mnt/fast-pool /mnt/media
        
        SYSTEM_DISK=$(lsblk -no PKNAME $(findmnt -nvo SOURCE /) | head -n1)
        [ -z "$SYSTEM_DISK" ] && SYSTEM_DISK="sda"

        lsblk -nbo NAME,ROTA,SIZE,MOUNTPOINT,TYPE,PKNAME | grep 'part\|disk' | while read -r name rota size mount type pkname; do
          [ "$name" = "$SYSTEM_DISK" ] && continue
          [ "$pkname" = "$SYSTEM_DISK" ] && continue
          [ "$mount" = "/" ] && continue
          if [ "$size" -lt 64000000000 ]; then continue; fi

          if [ "$rota" = "0" ]; then
            target="/mnt/storage/ssd/$name"
          else
            target="/mnt/storage/hdd/$name"
          fi

          mkdir -p "$target"
          mount "/dev/$name" "$target" 2>/dev/null || true
          chown -R ${user}:users "$target"
        done
      '';
    };

    # ── STORAGE HYGIENE ─────────────────────────────────────────────────────
    systemd.timers.nixhome-mover = {
      description = "Run NixHome Mover Daily";
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "daily";
    };

    environment.systemPackages = with pkgs; [ mergerfs util-linux ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 */
