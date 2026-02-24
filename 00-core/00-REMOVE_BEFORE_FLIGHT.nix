{ ... }:
{
  # TEMPORARY TEST MODULE
  # REMOVE BEFORE FLIGHT:
  # 1) Delete file: /etc/nixos/00-core/00-REMOVE_BEFORE_FLIGHT.nix
  # 2) Remove import line from /etc/nixos/configuration.nix:
  #    ./00-core/00-REMOVE_BEFORE_FLIGHT.nix
  # 3) Run: sudo nixos-rebuild switch

  security.sudo.extraRules = [
    {
      users = [ "moritz" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
