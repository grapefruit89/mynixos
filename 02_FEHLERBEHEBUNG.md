# meta:
#   owner: core
#   status: active
#   scope: shared
#   summary: Notfallpfade und Fehlerbehebung (Recovery)
#   specIds: [REC-001, SEC-SSH-001]

# 🆘 Fehlerbehebung (Recovery)

Wenn etwas schiefgeht, findest du hier die Notfall-Checklisten.

## 🔐 SSH-Login geht nicht mehr
1.  **Lokal einloggen:** Melde dich direkt am Host via Monitor/Tastatur an.
2.  **Status prüfen:**
    ```bash
    sudo systemctl status sshd
    ```
3.  **Key-Fallback:** Wenn kein SSH-Key hinterlegt ist, erlaubt das System (mit Warnung im Log) einen Passwort-Login als Notnagel.
4.  **Firewall prüfen:**
    ```bash
    sudo nft list ruleset | grep ssh
    ```

## 💾 System bootet nicht (Rollback)
NixOS erlaubt es dir, beim Booten im Menü eine ältere Version auszuwählen.
- Wenn ein `nsw` (switch) das System instabil macht: Neustart -> Ältere Generation wählen.
- Um das dauerhaft zu machen (nach dem Booten in die alte Version):
  ```bash
  sudo nixos-rebuild switch
  ```

## 🧱 Firewall blockiert alles
Wenn du dich ausgesperrt hast:
1.  In `00-core/firewall.nix` prüfen, ob dein Interface/IP in der Whitelist ist.
2.  Notfalls Firewall temporär stoppen (nur lokal möglich!):
    ```bash
    sudo systemctl stop nftables
    ```

## 🧩 Git-Konflikte (Stau)
Wenn `git push` oder `pull` Fehler meldet (z.B. "non-fast-forward"):
1.  Zuerst ziehen: `git pull --ff-only`
2.  Wenn das nicht geht (Merge-Konflikte): Keine Panik. Nutze `git status`, um zu sehen, welche Dateien Probleme machen.
3.  Im Zweifel: `git log` schauen, was der letzte gute Stand war.
