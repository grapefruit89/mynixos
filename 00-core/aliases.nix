# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: aliases Modul

{ config, ... }:
{ config, pkgs, ... }:
let
  sshPort = toString config.my.ports.ssh;
  passwordAuth = toString (config.services.openssh.settings.PasswordAuthentication or false);
  kbdAuth = toString (config.services.openssh.settings.KbdInteractiveAuthentication or false);
  permitTTY = toString (config.services.openssh.settings.PermitTTY or false);
  fallbackUnitEnabled = toString ((config.systemd.services ? ssh-password-fallback-warning));
in
{
  environment.systemPackages = [ (pkgs.writeShellScriptBin "nix-deploy" (builtins.readFile ./scripts/nix-deploy.sh)) ];
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
      nix-git = ''bash -c "cd /etc/nixos && git add -A && read -p 'Commit: ' msg && git commit -m "$msg" && git push"'';
      nix-dry = "cd /etc/nixos && sudo nixos-rebuild dry-run -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";
      nix-test = "cd /etc/nixos && sudo nixos-rebuild test -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";
      nix-switch = "cd /etc/nixos && sudo nixos-rebuild switch -I nixos-config=/etc/nixos/configuration.nix 2>&1 | nom";
      nix-deploy = "nix-deploy";

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
      echo "  nix-deploy -> test, optional switch, optional commit+push"
      echo ""
      echo "  Security Snapshot"
      echo "  - SSH Port: ${sshPort}"
      echo "  - PermitTTY: ${permitTTY}"
      echo "  - PasswordAuthentication: ${passwordAuth}"
      echo "  - KbdInteractiveAuthentication: ${kbdAuth}"
      echo "  - ssh-password-fallback-warning unit present: ${fallbackUnitEnabled}"
      if [ "${passwordAuth}" = "true" ]; then
        echo "  [WARN] Passwort-SSH-Fallback ist aktiv (kein Key hinterlegt)."
        echo "         Prüfe: journalctl -t ssh-fallback -n 20 --no-pager"
      fi
      echo ""
      echo "  Security Snapshot"
      echo "  - SSH Port: ${sshPort}"
      echo "  - PermitTTY: ${permitTTY}"
      echo "  - PasswordAuthentication: ${passwordAuth}"
      echo "  - KbdInteractiveAuthentication: ${kbdAuth}"
      echo "  - ssh-password-fallback-warning unit present: ${fallbackUnitEnabled}"
      if [ "${passwordAuth}" = "true" ]; then
        echo "  [WARN] Passwort-SSH-Fallback ist aktiv (kein Key hinterlegt)."
        echo "         Prüfe: journalctl -t ssh-fallback -n 20 --no-pager"
      fi
      echo ""
      echo "  Tip: first nix-test, then nix-switch"
      echo ""
    '';
  };
}
