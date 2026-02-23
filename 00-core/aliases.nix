{ ... }:
{
  programs.bash.shellAliases = {
    # Repo shortcuts
    ncfg = "cd /etc/nixos";
    ngit = "cd /etc/nixos && sudo git status -sb";

    # Build shortcuts
    nsw   = "cd /etc/nixos && sudo nixos-rebuild switch";
    ntest = "cd /etc/nixos && sudo nixos-rebuild test";
    ndry  = "cd /etc/nixos && sudo nixos-rebuild dry-run";

    # Quick git commit (asks for message)
    ncommit = ''bash -c "cd /etc/nixos && sudo git add -A && read -p 'Commit: ' msg && sudo git commit -m \"$msg\" && sudo git push"'';
  };

  programs.bash.shellInit = ''
    export PATH="/home/moritz/.npm-global/bin:$PATH"
  '';
}
