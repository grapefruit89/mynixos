# readme.nix
# Maschinenlesbare Projektbeschreibung (ergänzt README/docs, enthält KEINE Secrets)
{
  project = {
    name = "mynixos";
    type = "NixOS homelab (single-host, security-first, declarative)";
    status = "active";

    goals = [
      "Sicherheitsorientierte, nachvollziehbare Infrastruktur via NixOS"
      "Isomorphe Modulstruktur (10-core, 20-infrastructure, 30-services, 90-policy)"
      "Reproduzierbare Betriebsabläufe mit klaren Guardrails"
      "Einfacher Start ohne frühe Secret-Komplexität (sops später)"
    ];

    architecture = {
      core = "Ports/SSH/Firewall/Secrets/Systemgrundlagen";
      infrastructure = "Traefik, Tailscale, WireGuard, Cloudflare-Tunnel, Monitoring-Bausteine";
      services = "Media- und App-Module hinter Reverse-Proxy";
      policy = "Sicherheitsassertions als Regression-Schutz";
    };

    securityPrinciples = [
      "SSH niemals global ins Internet öffnen"
      "SSH bevorzugt Key-Login; Passwort nur als kontrollierter Fallback"
      "TTY als letzter Recovery-Kanal immer aktiv"
      "Sensitive Verträge durch Assertions absichern"
      "Zentrale Port-Registry statt verteilter Magic Numbers"
    ];

    operations = {
      sourceOfTruth = "GitHub (PR-first), Host zieht per git pull + nixos-rebuild";
      secretBootstrap = "/etc/secrets/homelab-runtime-secrets.env(.example)";
      arrWiring = "manual/oneshot helper (arr-wire.service)";
    };
  };
}
