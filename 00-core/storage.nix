/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-027
 *   title: "Storage (SRE Exhausted)"
 *   layer: 00
 * summary: mergerfs pool management with SSoT paths and ABC-tiering enforcement.
 * ---
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.services.storage-pool;
  srePaths = config.my.configs.paths;
  
  rootMinFree = "20G";
  ssdMinFree = "50G";
in
{
  config = lib.mkIf cfg.enable {
    
    # ── POOL DEFINITION (ABC-Tiering) ───────────────────────────────────────
    systemd.mounts = [
      {
        description = "Fast-Pool (Tier B - SSD)";
        where = srePaths.storagePool;
        what = "/data/storage/b-on-a:/mnt/storage/ssd:/mnt/storage/hdd";
        type = "fuse.mergerfs";
        options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${rootMinFree},fsname=fast-pool";
        wantedBy = [ "multi-user.target" ];
      }
      {
        description = "Media-Pool (Tier C - HDD)";
        where = srePaths.mediaLibrary;
        what = "/mnt/storage/ssd:/mnt/storage/hdd";
        type = "fuse.mergerfs";
        options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${ssdMinFree},fsname=media-pool,cache.files=partial";
        wantedBy = [ "multi-user.target" ];
      }
    ];

    # ── NIXARR PATH ENFORCEMENT ───────────────────────────────────────────
    systemd.services.nixhome-path-enforcement = {
      description = "NixHome SRE Path Enforcement";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        # SSoT Pfade aus configs.nix erzwingen
        mkdir -p ${srePaths.storagePool}/downloads/{torrents,usenet,incomplete}
        mkdir -p ${srePaths.mediaLibrary}/{movies,tv,music,books,podcasts,documents}
        
        # 🔒 PERMISSIONS (GID 169)
        chown -R root:media ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary}
        chmod -R 775 ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary}
        find ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary} -type d -exec chmod g+s {} +
      '';
    };

    environment.systemPackages = with pkgs; [ mergerfs util-linux ];
  };
}
/**
 * technical_integrity:
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-03-02
 * ---
 */
