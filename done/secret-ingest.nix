# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: Secret Ingest Landing Zone (Level 99 SRE-Work)
#   description: Automatische Verarbeitung von VPN-Configs via Kernel inotify.

{ config, lib, pkgs, ... }:

let
  ingestDir = "/etc/nixos/secret-landing-zone";
  sopsFile = "/etc/nixos/secrets.yaml";
  liveConfig = "/etc/nixos/10-infrastructure/vpn-live-config.nix";

  # Das Herz des Ingest: Ein robustes Python-Skript
  ingestScript = pkgs.writers.writePython3Bin "secret-ingest-agent" {
    libraries = [ ];
  } ''
import os
import re
import subprocess
import glob


print("--- SECRET INGEST AGENT ACTIVATED ---")

INGEST_DIR = "${ingestDir}"
SOPS_FILE = "${sopsFile}"
LIVE_CONFIG = "${liveConfig}"


def process_file(file_path):
    if not os.path.isfile(file_path):
        return

    print(f"Scanning {file_path} for WireGuard patterns...")
    with open(file_path, "r") as f:
        content = f.read()

    # Regex patterns for WireGuard config
    priv_key = re.search(r"PrivateKey\s*=\s*(.*)", content)
    pub_key = re.search(r"PublicKey\s*=\s*(.*)", content)
    address = re.search(r"Address\s*=\s*(.*)", content)
    dns = re.search(r"DNS\s*=\s*(.*)", content)
    endpoint = re.search(r"Endpoint\s*=\s*(.*)", content)

    if priv_key:
        key = priv_key.group(1).strip()
        print("🔑 PrivateKey gefunden. Update SOPS Safe...")
        # sops path is injected via PATH
        cmd = [
            "sops",
            "set",
            SOPS_FILE,
            '["wg_privado_private_key"]',
            f'"{key}"'
        ]
        subprocess.run(cmd, check=True)

    if any([pub_key, address, dns, endpoint]):
        print("🛠️ Öffentliche Daten gefunden. Update vpn-live-config.nix...")
        dns_list = dns.group(1).strip().split(",") if dns else []
        dns_nix = "[" + " ".join(f'"{d.strip()}"' for d in dns_list) + "]"

        nix_content = f"""{{ lib, ... }}:
{{
  my.configs.vpn.privado = {{
    publicKey = lib.mkForce "{pub_key.group(1).strip() if pub_key else ""}";
    endpoint = lib.mkForce "{endpoint.group(1).strip() if endpoint else ""}";
    address = lib.mkForce "{address.group(1).strip() if address else ""}";
    dns = lib.mkForce {dns_nix};
  }};
}}
"""
        with open(LIVE_CONFIG, "w") as f:
            f.write(nix_content)

    print(f"🗑️ Sicheres Löschen von {file_path}...")
    # shred path is injected via PATH
    shred_cmd = ["shred", "-u", file_path]
    subprocess.run(shred_cmd, check=True)
    print("✅ Verarbeitung abgeschlossen.")


if __name__ == "__main__":
    files = glob.glob(os.path.join(INGEST_DIR, "*"))
    for f in files:
        process_file(f)
  '';
in
{
  # 1. PATH UNIT (Der inotify-Wächter)
  systemd.paths.secret-ingest = {
    description = "Wächter für Secret Landing Zone";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      DirectoryNotEmpty = ingestDir;
      MakeDirectory = true;
    };
  };

  # 2. SERVICE UNIT (Der Verarbeiter)
  systemd.services.secret-ingest = {
    description = "Secret Ingest Agent";
    path = with pkgs; [ sops coreutils ]; # Inject tools into PATH
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${ingestScript}/bin/secret-ingest-agent";
      User = "root";
    };
    environment = {
      SOPS_AGE_KEY_FILE = "/var/lib/sops-nix/key.txt";
    };
  };

  # 3. SHELL HELPER
  environment.systemPackages = [ ingestScript ];

  programs.bash.shellAliases = {
    ingest-check = "sudo journalctl -u secret-ingest -f";
  };
}
