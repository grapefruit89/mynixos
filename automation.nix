{ config, pkgs, ... }: {
  security.sudo.extraRules = [
    {
      users = [ config.my.identity.user ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.nix}/bin/nix";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
