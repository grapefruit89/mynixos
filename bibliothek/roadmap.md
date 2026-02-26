https://github.com/pocket-id/pocket-id
https://github.com/nix-media-server/nixarr
https://github.com/NixOS/nixpkgs/tree/nixos-25.11/nixos/modules/services/backup
https://github.com/NixOS/nixpkgs/tree/nixos-25.11/nixos/modules/services/games   
https://github.com/NixOS/nixpkgs/tree/nixos-25.11/nixos/modules/services/hardware          > einmal nach optimierungen durchsuchen 
https://github.com/NixOS/nixpkgs/tree/nixos-25.11/nixos/modules/services/home-automation   > Homeassistant 
https://github.com/NixOS/nixos-hardware
https://github.com/kiriwalawren/nixflix  > komplett durchleuchten 
https://github.com/mitchellh/nixos-config
https://github.com/Mic92/sops-nix
https://github.com/ryan4yin/nix-config



Weg A: Der "NixOS Way" (Home Assistant Core)
Du aktivierst es einfach in NixOS über services.home-assistant.enable = true;.
Vorteil: Es ist zu 100 % in deinem NixOS-Code deklariert. Du kannst alle Integrationen direkt in deiner .nix-Datei konfigurieren.
Nachteil: Kein Supervisor, kein Add-on Store.
Die NixOS-Philosophie dazu: "Add-ons" in HAOS sind unter der Haube eigentlich nichts anderes als Docker-Container, die HAOS für dich verwaltet. Auf NixOS macht man das anders: Du installierst Dinge wie Mosquitto (MQTT) oder Zigbee2MQTT einfach als eigene, vollwertige NixOS-Dienste (in deinem Layer 20-services) und verbindest dein Home Assistant damit. Das ist weitaus mächtiger als der HAOS-Supervisor, erfordert aber, dass du die Dienste selbst verwaltest.
