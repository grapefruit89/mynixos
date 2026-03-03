{ config, pkgs, lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-CORE-032";
    title = "User Moritz Home";
    description = "Personalized user environment configuration via Home-Manager for user 'moritz'.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = [ "user/dotfiles" "home-manager/config" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
in
{
  options.my.meta.user_moritz_home = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for user-moritz-home module";
  };

  config = {
    home.stateVersion = "24.11";
    home.packages = with pkgs; [ micro neofetch htop ncdu btop dust ];
    programs.bash = { enable = true; historySize = 50000; historyFileSize = 100000; historyControl = [ "ignoredups" "ignorespace" ]; };
    programs.htop = { enable = true; settings = { color_scheme = 0; delay = 15; highlight_base_name = 1; highlight_megabytes = 1; highlight_threads = 1; show_program_path = 0; }; };
    programs.micro = { enable = true; settings = { colorscheme = "simple"; tabsize = 2; mouse = true; }; };
    programs.bat = { enable = true; config = { theme = "base16"; italic-text = "always"; }; };
    programs.git = { enable = true; settings = { user.name = "Moritz Baumeister"; user.email = "moritzbaumeister@gmail.com"; pull.rebase = false; init.defaultBranch = "main"; }; };
  };
}
