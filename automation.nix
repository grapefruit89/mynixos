{ pkgs, ... }: {
  security.sudo.extraRules = [
    {
      users = [ "moritz" ];
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
