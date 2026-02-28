/**
 * ---
 * nms_version: 2.3
 * identity:
 *   id: NIXH-10-INF-010
 *   title: "Landing Zone Ui"
 *   layer: 10
 * architecture:
 *   req_refs: [REQ-INF]
 *   upstream: [NIXH-00-SYS-ROOT-001]
 *   downstream: []
 *   status: audited
 * ---
 */
{ config, pkgs, lib, ... }:

let
  domain = config.my.configs.identity.domain;
  lanIP = config.my.configs.server.lanIP;
  
  rescueHtml = pkgs.writeTextDir "index.html" ''
    <!DOCTYPE html>
    <html lang="de">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>nixhome | Rettungsweg</title>
        <style>
            body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #0f172a; color: #f1f5f9; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
            .card { background: #1e293b; padding: 2.5rem; border-radius: 1rem; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); max-width: 600px; width: 90%; border: 1px solid #334155; }
            h1 { color: #38bdf8; margin-top: 0; display: flex; align-items: center; gap: 0.5rem; }
            p { line-height: 1.6; color: #94a3b8; }
            .status { background: #064e3b; color: #4ade80; padding: 0.75rem 1rem; border-radius: 0.5rem; font-weight: bold; margin: 1.5rem 0; border-left: 4px solid #22c55e; }
            .action-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 2rem; }
            .btn { background: #334155; color: white; text-decoration: none; padding: 1rem; border-radius: 0.5rem; text-align: center; font-weight: 500; transition: all 0.2s; border: 1px solid #475569; }
            .btn:hover { background: #475569; transform: translateY(-2px); border-color: #38bdf8; }
            .btn-primary { background: #0284c7; border-color: #0ea5e9; }
            .btn-primary:hover { background: #0ea5e9; }
            .badge { background: #38bdf820; color: #38bdf8; padding: 0.2rem 0.5rem; border-radius: 0.25rem; font-size: 0.8rem; font-family: monospace; }
            .footer { margin-top: 2rem; font-size: 0.8rem; color: #475569; text-align: center; border-top: 1px solid #334155; pt: 1rem; }
        </style>
    </head>
    <body>
        <div class="card">
            <h1>🛡️ nixhome Rettungsweg</h1>
            <p>Du bist über <strong>Tailscale</strong> oder das <strong>lokale Netz</strong> verbunden. Der normale SSO-Login (Pocket-ID) wurde automatisch übersprungen.</p>
            
            <div class="status">
                ✅ Verbindung gesichert & autorisiert.
            </div>

            <div class="action-grid">
                <a href="https://${domain}" class="btn btn-primary">🏠 Zum Dashboard</a>
                <a href="https://auth.${domain}" class="btn">🔑 Pocket-ID (SSO)</a>
                <a href="https://netdata.${domain}" class="btn">📊 System Monitor</a>
            </div>

            <p style="margin-top: 2rem; font-size: 0.9rem;">
                <strong>Diagnose-Info:</strong><br>
                Host: <span class="badge">nixhome</span><br>
                Lokale IP: <span class="badge">${lanIP}</span><br>
                Zertifikat: <span class="badge">sslip.io (Auto-Fallback)</span>
            </p>

            <div class="footer">
                NixOS 25.11 | Fujitsu Q958 Homelab
            </div>
        </div>
    </body>
    </html>
  '';
in
{
  systemd.tmpfiles.rules = [
    "d /var/www/landing-zone 0755 caddy caddy -"
    "L+ /var/www/landing-zone/index.html - - - - ${rescueHtml}/index.html"
  ];
}








/**
 * ---
 * technical_integrity:
 *   checksum: sha256:d52af2420ece271a46a02e04358b8ffe3fabb3eac6bcaa8060fcc7696045c174
 *   eof_marker: NIXHOME_VALID_EOF
 * audit_trail:
 *   last_reviewed: 2026-02-28
 *   complexity_score: 2
 * ---
 */
