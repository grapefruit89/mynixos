{ ... }:
{
  # TEMPORARY: remove this module before exposing the host to less-trusted networks.
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
