{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aider-chat         # Git-Architekt
    open-interpreter   # System-Operator
    uv                 # Motor für nix-mcp
  ];

  programs.bash.shellAliases = {
    ai-arch = "aider --model gemini/gemini-1.5-pro";
    ai-ops = "interpreter --local";
  };
}
