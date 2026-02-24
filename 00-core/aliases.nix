{ ... }:
{
  programs.bash = {
    shellAliases = {
      # Repo shortcuts
      ncfg = "cd /etc/nixos";
      ngit = "cd /etc/nixos && git status -sb";

      # Build shortcuts
      nsw = "cd /etc/nixos && sudo nixos-rebuild switch";
      ntest = "cd /etc/nixos && sudo nixos-rebuild test";
      ndry = "cd /etc/nixos && sudo nixos-rebuild dry-run";

      # Orchestrated nix workflow
      nix-git = ''bash -c "cd /etc/nixos && git add -A && read -p 'Commit: ' msg && git commit -m \"$msg\" && git push"'';
      nix-dry = "cd /etc/nixos && sudo nixos-rebuild dry-run -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";
      nix-test = "cd /etc/nixos && sudo nixos-rebuild test -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";
      nix-switch = "cd /etc/nixos && sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";

      # Existing helper
      gemini = "npx @google/gemini-cli";
    };

    loginShellInit = ''
      echo ""
      echo "  +------------------------------------------+"
      echo "  |          Fujitsu Q958 · NixOS            |"
      echo "  +------------------------------------------+"
      echo ""
      echo "  nix-git    -> git add -A, commit (interactive), push"
      echo "  nix-dry    -> simulation, nothing is built"
      echo "  nix-test   -> active until reboot"
      echo "  nix-switch -> persistent rebuild"
      echo ""
      echo "  Tip: first nix-test, then nix-switch"
      echo ""
    '';
  };
}
