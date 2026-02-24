{ ... }:
{
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = false;
  };
}
