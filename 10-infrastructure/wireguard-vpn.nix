{ config, ... }:
let
  # source-id: CFG.secrets.sharedEnv
  # sink: input env-file for private key extraction
  envFile = config.my.secrets.files.sharedEnv;

  # source-id: CFG.secrets.wireguardPrivadoConf
  # sink: generated wg-quick config destination
  wgConfFile = config.my.secrets.files.wireguardPrivadoConf;

  # source-id: CFG.secrets.wgPrivadoPrivateKeyVarName
  # sink: env var key used to read WireGuard private key
  wgKeyVar = config.my.secrets.vars.wgPrivadoPrivateKeyVarName;

  # source-id: CFG.vpn.privado.address
  # sink: [Interface] Address in generated config
  wgAddress = config.my.configs.vpn.privado.address;

  # source-id: CFG.vpn.privado.dns
  # sink: [Interface] DNS in generated config
  wgDns = builtins.concatStringsSep "," config.my.configs.vpn.privado.dns;

  # source-id: CFG.vpn.privado.publicKey
  # sink: [Peer] PublicKey in generated config
  wgPublicKey = config.my.configs.vpn.privado.publicKey;

  # source-id: CFG.vpn.privado.endpoint
  # sink: [Peer] Endpoint in generated config
  wgEndpoint = config.my.configs.vpn.privado.endpoint;
in
{
  # source-id: CFG.vpn.privado.address
  # source-id: CFG.vpn.privado.dns
  # source-id: CFG.vpn.privado.publicKey
  # source-id: CFG.vpn.privado.endpoint
  # sink: ${wgConfFile} -> networking.wg-quick.interfaces.privado.configFile
  system.activationScripts.wgPrivadoConfigFromEnv.text = ''
    set -eu

    env_file="${envFile}"
    out_file="${wgConfFile}"
    key_var="${wgKeyVar}"
    key_value=""

    if [ ! -f "$env_file" ]; then
      echo "Missing $env_file (required for $key_var)" >&2
      exit 1
    fi

    while IFS= read -r line; do
      case "$line" in
        "$key_var"=*)
          key_value="''${line#*=}"
          ;;
      esac
    done < "$env_file"

    case "$key_value" in
      \"*\") key_value="''${key_value#\"}"; key_value="''${key_value%\"}" ;;
      \'*\') key_value="''${key_value#\'}"; key_value="''${key_value%\'}" ;;
    esac

    if [ -z "$key_value" ]; then
      echo "$key_var missing in $env_file" >&2
      exit 1
    fi

    install -d -m 700 /etc/secrets/wireguard
    umask 077

    cat > "$out_file" <<CFG
[Interface]
PrivateKey = $key_value
Address = ${wgAddress}
DNS = ${wgDns}

[Peer]
PublicKey = ${wgPublicKey}
AllowedIPs = 0.0.0.0/0
Endpoint = ${wgEndpoint}
CFG

    chown root:root "$out_file"
    chmod 600 "$out_file"
  '';

  networking.wg-quick.interfaces.privado = {
    autostart = true;
    configFile = wgConfFile;
  };
}
