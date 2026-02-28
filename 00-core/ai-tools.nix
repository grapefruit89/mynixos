/**
 * ---
 * nms_version: 2.2
 * identity:
 *   id: NIXH-00-SYS-CORE-001
 *   title: "Ai Tools"
 *   layer: 00
 * architecture:
 *   req_refs: [REQ-CORE]
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
 *   checksum: sha256:8aa05db1c0c0f5fe60c7d7acc2f862f6ddc22f135967acb3d52728c7cc2da6c0
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 * ---
 */
