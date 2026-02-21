# ============================================================================
# NixOS Konfiguration – Fujitsu Q958
# Benutzer: moritz | Hostname: q958
# Prinzip: Diese Datei beschreibt das komplette System.
#          Änderung hier → "sudo nixos-rebuild switch" → fertig.
# ============================================================================

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix   # Auto-generiert, NICHT manuell bearbeiten
  ];

  # ── BOOTLOADER ─────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── NETZWERK ───────────────────────────────────────────────────────────────
  networking.hostName = "q958";
  networking.networkmanager.enable = true;

  # ── SPRACHE & ZEITZONE ─────────────────────────────────────────────────────
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # ── DESKTOP (XFCE – temporär, wird später entfernt) ────────────────────────
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Tastaturlayout Deutsch
  services.xserver.xkb = {
    layout  = "de";
    variant = "";
  };
  console.keyMap = "de";

  # ── SOUND (Pipewire – moderner Standard) ───────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
  };

  # ── BENUTZER ───────────────────────────────────────────────────────────────
  users.users.moritz = {
    isNormalUser = true;
    description  = "Moritz Baumeister";
    extraGroups  = [
      "networkmanager"   # Netzwerk verwalten
      "wheel"            # sudo-Rechte
      "video"            # GPU-Zugriff (später für Jellyfin/QuickSync)
      "render"           # GPU-Zugriff (später für Jellyfin/QuickSync)
    ];
  };

  # ── NIX EINSTELLUNGEN ──────────────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ]; # Flakes aktivieren
    auto-optimise-store   = true;                        # Speicher sparen
  };

  # Alte Systemgenerationen automatisch aufräumen (älter als 7 Tage)
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 7d";
  };

  # ── PAKETE ─────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;  # Proprietäre Software erlauben

  environment.systemPackages = with pkgs; [
    # ── Editoren & Entwicklung ──
    vscodium    # VSCode ohne Microsoft-Telemetrie (NixOS-Syntax-Highlighting!)
    git         # Versionskontrolle (PFLICHT für alles weitere)

    # ── Nützliche Terminal-Tools ──
    htop        # Prozess-Monitor
    wget        # Dateien herunterladen
    curl        # HTTP-Anfragen
    tree        # Verzeichnisstruktur anzeigen
    unzip       # ZIP-Archive entpacken
    file        # Dateityp erkennen

    # ── Nix-Hilfsmittel ──
    nix-output-monitor  # Schönere Ausgabe bei nixos-rebuild (Befehl: "nom")
  ];

  # ── PROGRAMME ──────────────────────────────────────────────────────────────
  programs.firefox.enable = true;

  # ── SSH SERVER ─────────────────────────────────────────────────────────────
  # Aktiviert! Du kannst dich jetzt vom Laptop aus verbinden:
  # ssh moritz@<ip-adresse-des-q958>
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin      = "no";    # Root-Login verboten
      PasswordAuthentication = true;  # Erstmal Passwort erlaubt
                                      # → später auf "false" + SSH-Keys umstellen
    };
  };

  # SSH-Port in der Firewall öffnen
  networking.firewall.allowedTCPPorts = [ 22 ];

  # ── DRUCKER (deaktiviert – braucht kein Server) ────────────────────────────
  services.printing.enable = false;

  # ── SYSTEM VERSION ─────────────────────────────────────────────────────────
  # NIEMALS ändern – bleibt immer auf der Version der Erstinstallation!
  system.stateVersion = "25.11";
}
