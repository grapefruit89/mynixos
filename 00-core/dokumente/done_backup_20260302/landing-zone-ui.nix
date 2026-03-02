# meta:
#   owner: infrastructure
#   status: active
#   scope: shared
#   summary: Secret Landing Zone UI (Web-Drop-Zone)
#   description: Minimalistisches Web-Interface zum Hochladen von Secrets.

{ config, lib, pkgs, ... }:

let
  cfg = config.my.profiles.infrastructure.landingZoneUI;
  port = config.my.ports.landingZoneUI or 10022;
  ingestDir = "/etc/nixos/secret-landing-zone";

  # Python 3.11 for cgi module support
  python = pkgs.python311;

  landingZoneScript = pkgs.writeScriptBin "landing-zone-ui-server" ''
#!${python}/bin/python
import http.server
import socketserver
import os
import cgi
import html

PORT = ${toString port}
DIRECTORY = "${ingestDir}"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="de" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secret Landing Zone</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0b0e14; color: #c9d1d9; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .card { background-color: #161b22; border: 1px solid #30363d; border-radius: 12px; }
        .btn-primary { background-color: #238636; border: none; }
        .btn-primary:hover { background-color: #2ea043; }
        .drop-zone { border: 2px dashed #30363d; padding: 40px; text-align: center; border-radius: 12px; transition: 0.3s; cursor: pointer; }
        .drop-zone:hover { border-color: #238636; background-color: #0d1117; }
    </style>
</head>
<body class="d-flex align-items-center justify-content-center vh-100">
    <div class="container" style="max-width: 600px;">
        <div class="card shadow-lg p-4">
            <h2 class="text-center mb-4">🔐 Secret Landing Zone</h2>
            <p class="text-center text-secondary small">Laden Sie Ihre WireGuard-Konfiguration (.conf) hier hoch. <br> Sie wird automatisch verarbeitet und sicher gelöscht.</p>
            
            <form action="/" method="POST" enctype="multipart/form-data">
                <div class="mb-4">
                    <label for="file" class="drop-zone w-100" id="dropZone">
                        <span id="fileName">Datei auswählen oder hierher ziehen</span>
                        <input type="file" name="file" id="file" class="d-none" required onchange="updateFileName()">
                    </label>
                </div>
                <button type="submit" class="btn btn-primary w-100 py-2 fw-bold">🚀 Hochladen & Verarbeiten</button>
            </form>
            
            <div id="status" class="mt-4">
                {status_msg}
            </div>
        </div>
    </div>

    <script>
        function updateFileName() {
            const input = document.getElementById('file');
            const label = document.getElementById('fileName');
            if (input.files.length > 0) {
                label.textContent = input.files[0].name;
                label.classList.add('text-success');
            }
        }
        
        const dropZone = document.getElementById('dropZone');
        dropZone.addEventListener('dragover', (e) => { e.preventDefault(); dropZone.style.borderColor = '#238636'; });
        dropZone.addEventListener('dragleave', () => { dropZone.style.borderColor = '#30363d'; });
        dropZone.addEventListener('drop', (e) => {
            e.preventDefault();
            const fileInput = document.getElementById('file');
            fileInput.files = e.dataTransfer.files;
            updateFileName();
        });
    </script>
</body>
</html>
"""

class LandingZoneHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(HTML_TEMPLATE.format(status_msg="").encode())

    def do_POST(self):
        try:
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={'REQUEST_METHOD': 'POST',
                         'CONTENT_TYPE': self.headers['Content-Type'],
                         }
            )

            if "file" in form:
                file_item = form["file"]
                if file_item.filename:
                    filename = os.path.basename(file_item.filename)
                    if not filename.endswith(('.conf', '.txt')):
                         self.render_result(f'<div class="alert alert-danger">❌ Fehler: Ungültiger Dateityp ({filename}). Nur .conf erlaubt.</div>')
                         return
                    
                    filepath = os.path.join(DIRECTORY, filename)
                    with open(filepath, "wb") as f:
                        f.write(file_item.file.read())
                    
                    self.render_result(f'<div class="alert alert-success">✅ <b>{html.escape(filename)}</b> erfolgreich hochgeladen!<br>Der Ingest-Agent verarbeitet die Datei in Kürze.</div>')
                    return

            self.render_result('<div class="alert alert-warning">⚠️ Keine Datei ausgewählt.</div>')
        except Exception as e:
            self.render_result(f'<div class="alert alert-danger">💥 Systemfehler: {str(e)}</div>')

    def render_result(self, msg):
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()
        self.wfile.write(HTML_TEMPLATE.format(status_msg=msg).encode())

    def log_message(self, format, *args):
        pass

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY):
        os.makedirs(DIRECTORY, mode=0o700, exist_ok=True)
    
    with socketserver.TCPServer(("", PORT), LandingZoneHandler) as httpd:
        httpd.serve_forever()
  '';

in
{
  options.my.profiles.infrastructure.landingZoneUI.enable = lib.mkEnableOption "Landing Zone UI";

  config = lib.mkIf cfg.enable {
    systemd.services.landing-zone-ui = {
      description = "Secret Landing Zone Web UI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${landingZoneScript}/bin/landing-zone-ui-server";
        Restart = "always";
        User = "root";
        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "full";
        ProtectHome = true;
      };
    };

    networking.firewall.allowedTCPPorts = [ port ];
  };
}
