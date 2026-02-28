/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-00-CORE-001
 *   title: "Ai Tools"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    aider-chat uv python3 blesh inshellisense fzf jq curl
  ];

  programs.bash.interactiveShellInit = ''
    if [[ -f ${pkgs.blesh}/share/blesh/ble.sh ]]; then
      source ${pkgs.blesh}/share/blesh/ble.sh
      bleopt edit_multi_line=0 2>/dev/null || true
    fi

    if command -v inshellisense > /dev/null; then
       alias gemini-hint='inshellisense bind gemini -- gemini'
      alias p-graph='python3 /etc/nixos/scripts/generate-mermaid.py'
    fi
  '';
}




/**
 * ---
 * technical_integrity:
 *   checksum: sha256:f8eb0df693a92f9115db3039cc0cf2aecd6d5ff80868f94a6f1a603193e4cc5f
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
