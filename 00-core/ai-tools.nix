{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat         # Der Architekt (Git + KI)
    open-interpreter   # Der Operator (Systemzugriff)
    uv                 # Motor für die nix-mcp Erweiterung
    python3      # Benötigt für uv / nix-mcp auf NixOS
  ];

  programs.bash.shellAliases = {
    ai-arch = "aider --model gemini/gemini-1.5-pro";
    ai-ops = "interpreter --local";
  };
}
