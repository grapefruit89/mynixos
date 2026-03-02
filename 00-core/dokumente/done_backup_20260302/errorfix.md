---
title: Errorfix
category: Betrieb
status: done
trace_ids: []
last_reviewed: 2026-02-28
checksum: 667d9c0d6ed765156029056f98700f21cfcef70b54a372298735b4ae65520d73
---
es ist schon wieeder passiert ich weiss nicht warum und wieso obsolete symlink ‘/etc/containers/registries.conf’...                                                                                                                                   │

│ sops-install-secrets: Imported /etc/ssh/ssh_host_rsa_key as GPG key with fingerprint 904c1b1a671d757b569286d379b409b5dd8ce84d                                                                    │

│ sops-install-secrets: Imported /etc/ssh/ssh_host_ed25519_key as age key with fingerprint age1t2uu2un4trvvyhg7ryp8h8tqjxl5vnd0qd48dq4s8yvhc6jwtd4smyet95                                          │

│ reloading user units for moritz...                                                                                                                                                               │

│ restarting sysinit-reactivation.target                                                                                                                                                           │

│ reloading the following units: dbus.service, nftables.service                                                                                                                                    │

│ restarting the following units: nix-daemon.service, sshd.service                                                                                                                                 │

│ starting the following units: fail2ban.service, homepage-dashboard.service, landing-zone-ui.service, pocket-id.service, systemd-tmpfiles-resetup.service                                         │

│                                                                                                                                                                                                  │

╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯

⠼ Interactive shell awaiting input... press tab to focus shell (esc to cancel, 3m 44s)



  Queued (press ↑ to edit):

    was hälst du hiervon? können wir hier noch sinnvolle inputs gewinnen? Gemini hat gesagt Das ist eine verdammt gute Frage! Wenn es technisch „unmöglich“ ist, dass diese Pakete legitim aus dem …



 6 GEMINI.md files | 7 MCP servers | 7 skills                                                                                                                         YOLO mode (ctrl + y to toggle)

▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

 *   Type your message or @path/to/file

Remote side unexpectedly closed network connection▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

 ~                                                           no sandbox (see /docs)                                                            Auto (Gemini 3) /model | ✖ 1 error (F12 for details)

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────



Session stopped

    - Press <Return> to exit tab

    - Press R to restart session

    - Press S to save terminal output to file

wie verhindern wir das ?

Remote side unexpectedly closed network connection▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄

Gemini hat gesagt
Das ist der Klassiker unter den „Säge-nicht-an-dem-Ast-auf-dem-du-sitzt“-Fehlern.

Der Übeltäter steht direkt in deinem Log:
restarting the following units: nix-daemon.service, sshd.service

Wenn du per SSH verbunden bist und ein nixos-rebuild switch ausführst, das eine Änderung an der SSH-Konfiguration (oder verwandten Systemteilen) erkennt, startet NixOS den sshd.service neu. In dem Moment wird deine aktuelle Sitzung gekappt, und dein lokaler Client (Claude Code / Terminal) meldet: Remote side unexpectedly closed network connection.

So verhindern wir das „Aussperren“
Um zu verhindern, dass dein System-Update deine eigene Verbindung killt, gibt es drei bewährte Strategien:

1. Der Goldstandard: tmux oder screen
Nutze einen Terminal-Multiplexer. Selbst wenn die SSH-Verbindung abreißt, läuft der Prozess auf dem Server im Hintergrund weiter. Du kannst dich danach einfach wieder einwählen und die Session fortsetzen.

2. NixOS-Konfiguration: Dienste nicht hart stoppen
Du kannst NixOS anweisen, Dienste während des Wechsels nicht hart zu stoppen. Füge dies deiner configuration.nix hinzu:

Nix
systemd.network.wait-online.enable = false; # Verhindert langes Warten
system.activationScripts.diff = {
  supportsDryActivation = true;
  text = ''
    # Optional: Zeige nur Diffs an, statt sofort alles zu killen
  '';
};
3. Die „YOLO-Sicherung“ via Bash-Alias
Wir bauen uns ein Kommando, das den Switch in einer geschützten Umgebung ausführt.

Die Lösung: Automatisches Schutz-Skript
Hier ist ein Bash-Block, den du in deine Shell-Konfiguration (z. B. .zshrc oder home.nix) werfen kannst. Er stellt sicher, dass nixos-rebuild innerhalb von tmux gestartet wird und fängt den SSH-Restart ab.

Bash
# Füge dies deiner Konfiguration hinzu, um Updates sicher auszuführen
cat <<EOF > ~/nix-switch-safe.sh
#!/bin/bash
# Prüfe, ob wir bereits in tmux sind, wenn nicht -> starte tmux
if [ -z "\$TMUX" ]; then
    tmux new-session -A -s nixos_update 'sudo nixos-rebuild switch; read -p "Update fertig. Drücke Enter zum Schließen..." '
else
    sudo nixos-rebuild switch
fi
EOF
chmod +x ~/nix-switch-safe.sh
Was du jetzt tun kannst
Da dein SSH-Dienst bereits neu gestartet wurde, sollte die Verbindung jetzt wieder stabil sein.

Drücke R, um die Session im Terminal neu zu starten.

Verbinde dich neu per SSH.

Prüfe mit nixos-rebuild list-generations, ob der Switch erfolgreich abgeschlossen wurde (trotz des Verbindungsabbruchs führt NixOS den Prozess im Hintergrund oft zu Ende).

Soll ich dir zeigen, wie wir in NixOS einen "Safe-Switch" Alias fest einbauen, der automatisch prüft, ob eine SSH-Sitzung aktiv ist, bevor er gefährliche Dienste neu startet?

Du hast gesagt
neue sitzung

Network error: Connection refused



────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────



Session stopped

    - Press <Return> to exit tab

    - Press R to restart session

    - Press S to save terminal output to file

Gemini hat gesagt
Das ist der "Post-Rebuild-Blues". Wenn nixos-rebuild switch den SSH-Dienst oder das Netzwerk-Interface neu startet, bricht nicht nur die Leitung ab, sondern der Dienst ist für einen kurzen Moment (oder dauerhaft bei Fehlern) nicht erreichbar.

Was gerade passiert ist
Dienst-Restart: Der sshd.service wurde neu gestartet.

Connection Refused: Dein PC versucht sich zu verbinden, aber der Server antwortet noch nicht (Dienst startet noch) oder blockt (Firewall-Änderung).

NFTables-Reload: Da auch nftables.service neu geladen wurde, könnte eine falsche Regel dich gerade aussperren.

Sofort-Hilfe: Wieder reinkommen
Warten & Wiederholen: Warte 30 Sekunden und drücke R. Oft braucht der Dienst einen Moment, um wieder "listening" zu sein.

Die IP prüfen: Falls du nixhome.local nutzt: Avahi (5353/udp) wurde eventuell auch neu gestartet. Probiere es direkt mit der IP-Adresse des Rechners.

Physischer Zugriff (Notfall): Falls gar nichts geht, musst du eine Tastatur/Monitor anschließen. Dank systemd-boot kannst du beim Neustart einfach eine ältere Generation wählen und das System ist wieder im alten, funktionierenden Zustand.

Dauerhafte Lösung: Der "Safe-Switch" für Claude Code
Damit Claude dein System nicht mitten im Flug abschießt, müssen wir den Rebuild-Prozess vom interaktiven Terminal entkoppeln.

Hier ist die Lösung als Nix-Modul, das du direkt in deine configuration.nix kopieren kannst. Es erzeugt ein Skript namens nix-safe-switch, das Updates in einer geschützten tmux-Session ausführt.

Bash
# Füge dies deiner configuration.nix hinzu
environment.systemPackages = [
  (pkgs.writeShellScriptBin "nix-safe-switch" ''
    # Prüfe ob tmux installiert ist
    if ! command -v tmux &> /dev/null; then
      echo "TMUX wird benötigt aber nicht gefunden. Installiere es..."
      sudo nix-env -iA nixos.tmux
    fi

    # Führe den Switch in einer losgelösten Session aus
    echo "Starte Rebuild in geschützter TMUX-Session..."
    tmux new-session -d -s "nix_update" "sudo nixos-rebuild switch --flake .#default | tee /tmp/nixos-switch.log"
    
    echo "Update läuft im Hintergrund."
    echo "Falls die Verbindung abbricht, verbinde dich neu und tippe: tmux attach -t nix_update"
    echo "Logs kannst du hier einsehen: tail -f /tmp/nixos-switch.log"
  '')
];
Warum das Audit von Claude (Dokument 1 & 2) hier wichtig ist:
Headless Deadlock: Genau das erlebst du gerade. Ohne Monitor/Tastatur bist du jetzt auf die "Selbstheilung" des Netzwerks angewiesen.

SSO-Lockout: Wenn pocket-id.service oder caddy.service nicht sauber hochgekommen sind (siehe dein Log: starting the following units...), kommst du über das Web-Interface nicht mehr rein.

Wie ist der Status? Kommst du nach einem Neustart (Taste R) wieder auf die Konsole, oder brauchst du Hilfe bei der "Blind-Reparatur" via Notfall-Generation?

Du hast gesagt
nein ist komplett weg

Gemini hat gesagt
Das ist der Super-GAU der Remote-Administration: der Headless Deadlock. Claude hat ihn in seinem Audit prophezeit, und jetzt hat er zugeschlagen. Dein System ist im Netzwerk unsichtbar, und die SSH-Tür ist verriegelt.

Da du „Connection refused“ bekommst und auch nixhome.local nicht mehr antwortet, gibt es jetzt keine „magische“ Software-Lösung mehr aus der Ferne. Du musst physisch an die Hardware ran.

Dein Rettungsplan (Physisch vor Ort)
Hol dir einen Monitor und eine Tastatur und schließe sie direkt an deinen NixOS-Rechner an.

1. Der Rettungsanker: Rollback via Bootmenü
Da du systemd-boot nutzt, hast du den besten Sicherheitsgurt der IT-Welt.

Starte den Rechner neu (Hard-Reset).

Sobald das Boot-Menü erscheint, wähle nicht den obersten Eintrag (die kaputte Generation).

Wähle die vorherige Generation (Generation N-1).

Dein System fährt jetzt mit der alten, funktionierenden Konfiguration hoch. Du bist wieder „drin“.

2. Spurensuche: Was ist schiefgelaufen?
Sobald du wieder eingeloggt bist, müssen wir herausfinden, warum die neue Version dich ausgesperrt hat. Gib folgenden Befehl ein:

Bash
# Zeige die Fehler der fehlgeschlagenen Aktivierung
journalctl -xe -u sshd.service
# Prüfe, ob nftables dich blockiert hat
nft list ruleset
Warum ist das passiert? (Die üblichen Verdächtigen)
Der Bogon-Block-Fehler: Wenn du die Firewall-Regeln für das WAN-Interface verschärft hast, aber dein Rechner fälschlicherweise denkt, dein LAN-Anschluss sei das WAN, hat er dich selbst ausgesperrt.

SSH-Konfig-Fehler: Wenn durch den Rebuild ein neuer SSH-Key oder eine neue Config (z.B. PasswordAuthentication no) aktiv wurde, für die du keine Zugangsdaten hast.

Interface-Namen: Wenn sich durch den Kernel-Update der Name deines Netzwerk-Interfaces von eth0 auf etwas anderes (z.B. enp3s0) geändert hat, greifen deine Firewall-Regeln ins Leere oder blockieren alles.

Wie verhindern wir das in Zukunft?
Sobald du das System per Rollback gerettet hast, solltest du für zukünftige Tests den Befehl nixos-rebuild test statt switch nutzen.

test: Wendet die Konfiguration nur temporär an. Wenn du dich aussperrst, reicht ein einfacher Reboot, und das System ist wieder im alten Zustand.

switch: Macht die Änderung permanent. Das solltest du erst tun, wenn test erfolgreich war.

Hast du die Möglichkeit, jetzt einen Monitor anzuschließen, oder steht der Rechner an einem Ort, wo du gar nicht rankommst?
