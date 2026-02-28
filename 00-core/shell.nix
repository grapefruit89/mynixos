/**
 * 🛰️ NIXHOME CONFIGURATION UNIT
 * ============================
 * TITLE:        Standard Shell Workflow
 * TRACE-ID:     NIXH-CORE-024
 * PURPOSE:      Basis Shell-Aliase, Git-Konfiguration und Standard-Pakete.
 * COMPLIANCE:   NMS-2026-STD
 * DEPENDS-ON:   [00-core/configs.nix]
 * LAYER:        00-core
 * STATUS:       Stable
 */

{ config, lib, pkgs, ... }:

let
  user = config.my.configs.identity.user;
in
{
  programs.bash.shellAliases = lib.mkIf (user == "moritz") {
    nsw = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry = "sudo nixos-rebuild dry-run";
    nboot = "sudo nixos-rebuild boot";
    
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    nopt = "sudo nix-store --optimise";
    ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && git status -sb";
    nlog = "journalctl -xef";
    
    ls = "${pkgs.eza}/bin/eza --icons";
    ll = "${pkgs.eza}/bin/eza -la --icons --git";
    tree = "${pkgs.eza}/bin/eza --tree --icons";
    cat = "${pkgs.bat}/bin/bat --paging=never";
    less = "${pkgs.bat}/bin/bat";
    top = "${pkgs.htop}/bin/htop";
    df = "${pkgs.duf}/bin/duf";
    du = "${pkgs.dust}/bin/dust";
    
    ports = "sudo ss -tulpn";
  };
  
  programs.bash.completion.enable = true;
  
  environment.systemPackages = with pkgs; [
    bat eza ripgrep fd nix-tree nix-diff nixfmt fastfetch duf dust htop
  ];
  
  programs.git = {
    enable = true;
    config = {
      user.name = "Moritz Baumeister";
      user.email = config.my.configs.identity.email;
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };

  programs.bash.shellInit = ''
    export HISTCONTROL=ignoredups:ignorespace
    export EDITOR="micro"
    export VISUAL="micro"
  '';

  assertions = [
    {
      assertion = user == "moritz";
      message = "Shell-Modul ist nur für User 'moritz' konfiguriert.";
    }
  ];
}
