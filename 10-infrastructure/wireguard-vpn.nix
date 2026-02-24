{ config, ... }:
let
  envFile = config.my.secrets.files.sharedEnv;
  wgConfFile = config.my.secrets.files.wireguardPrivadoConf;
  wgKeyVar = config.my.secrets.vars.wgPrivadoPrivateKeyVarName;
in
{
  # Traceability:
  # source: ${envFile}:${wgKeyVar}
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

    # Accept both quoted and unquoted env values.
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
Address = 100.64.4.147/32
DNS = 198.18.0.1,198.18.0.2

[Peer]
PublicKey = KgTUh3KLijVluDvNpzDCJJfrJ7EyLzYLmdHCksG4sRg=
AllowedIPs = 0.0.0.0/0
Endpoint = 91.148.237.21:51820
CFG

    chown root:root "$out_file"
    chmod 600 "$out_file"
  '';

  networking.wg-quick.interfaces.privado = {
    autostart = true;
    configFile = wgConfFile;
  };
}
