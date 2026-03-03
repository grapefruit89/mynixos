{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-027";
    title = "Storage (SRE Exhausted)";
    description = "mergerfs pool management with SSoT paths and ABC-tiering enforcement.";
    layer = 00;
    nixpkgs.category = "system/storage";
    capabilities = [ "storage/mergerfs" "storage/tiering" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };

  cfg = config.my.profiles.services.storage-pool;
  srePaths = config.my.configs.paths;
  rootMinFree = "20G";
  ssdMinFree = "50G";
in
{
  options.my.meta.storage = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for storage module";
  };

  config = lib.mkIf cfg.enable {
    systemd.mounts = [
      { description = "Fast-Pool (Tier B - SSD)"; where = srePaths.storagePool; what = "/data/storage/b-on-a:/mnt/storage/ssd:/mnt/storage/hdd"; type = "fuse.mergerfs"; options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${rootMinFree},fsname=fast-pool"; wantedBy = [ "multi-user.target" ]; }
      { description = "Media-Pool (Tier C - HDD)"; where = srePaths.mediaLibrary; what = "/mnt/storage/ssd:/mnt/storage/hdd"; type = "fuse.mergerfs"; options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=${ssdMinFree},fsname=media-pool,cache.files=partial"; wantedBy = [ "multi-user.target" ]; }
    ];

    systemd.services.nixhome-path-enforcement = {
      description = "NixHome SRE Path Enforcement";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p ${srePaths.storagePool}/downloads/{torrents,usenet,incomplete}
        mkdir -p ${srePaths.mediaLibrary}/{movies,tv,music,books,podcasts,documents}
        chown -R root:media ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary}
        chmod -R 775 ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary}
        find ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary} -type d -exec chmod g+s {} +
      '';
    };
    environment.systemPackages = with pkgs; [ mergerfs util-linux ];
  };
}
