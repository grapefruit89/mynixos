/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: id:
 *   title: "Secret Ingest"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, lib, pkgs, ... }:
let
  python = pkgs.python311;
in {
  systemd.paths.secret-ingest = {
    description = "Wächter für Secret Landing Zone";
    wantedBy = [ "multi-user.target" ];
    pathConfig = { DirectoryNotEmpty = "/etc/nixos/secret-landing-zone"; MakeDirectory = true; };
  };

  systemd.services.secret-ingest = {
    description = "Secret Ingest Agent";
    path = with pkgs; [ sops coreutils ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "ingest-run" ''
#!${python}/bin/python
import os, re, subprocess, glob

INGEST_DIR = "/etc/nixos/secret-landing-zone"
LIVE_CONFIG = "/etc/nixos/10-infrastructure/vpn-live-config.nix"

os.chdir(INGEST_DIR)
for f_name in glob.glob("*.conf"):
    try:
        with open(f_name, 'r') as f: content = f.read()
        priv = re.search(r"PrivateKey\s*=\s*(.*)", content)
        pub = re.search(r"PublicKey\s*=\s*(.*)", content)
        addr = re.search(r"Address\s*=\s*(.*)", content)
        dns = re.search(r"DNS\s*=\s*(.*)", content)
        endp = re.search(r"Endpoint\s*=\s*(.*)", content)

        if priv:
            print(f"WARNUNG: Private Key in {f_name} gefunden. Bitte manuell in sops secrets.yaml eintragen!")

        if any([pub, addr, dns, endp]):
            dns_list = dns.group(1).strip().split(",") if dns else []
            dns_nix = "[" + " ".join(f'"{d.strip()}"' for d in dns_list) + "]"
            nix_content = f"""{{ lib, ... }}:
{{
  my.configs.vpn.privado = {{
    publicKey = lib.mkForce "{pub.group(1).strip() if pub else ""}";
    endpoint = lib.mkForce "{endp.group(1).strip() if endp else ""}";
    address = lib.mkForce "{addr.group(1).strip() if addr else ""}";
    dns = lib.mkForce {dns_nix};
  }};
}}
"""
            with open(LIVE_CONFIG, "w") as out: out.write(nix_content)
        
        subprocess.run(["shred", "-u", f_name], check=True)
    except Exception as e: print(f"Error: {e}")
'';
      User = "root";
    };
  };
}


/**
 * ---
 * technical_integrity:
 *   checksum: sha256:3e36ef628953f8c1930dc9b6bc6742f4accdb57f62f005012e38455cd787f56e
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
