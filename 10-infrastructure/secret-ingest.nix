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
KEY_SINK = "/etc/nixos/secret-ingest-agent-key.txt"

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
            with open(KEY_SINK, "w") as kf:
                kf.write(priv.group(1).strip())
            os.chmod(KEY_SINK, 0o600)

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
