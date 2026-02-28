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
 *   checksum: sha256:cb967cdba957b553b398c0609265e9bd45273561224578d9507ff1b954a4662b
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
