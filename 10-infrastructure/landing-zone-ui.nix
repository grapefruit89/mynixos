{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.infrastructure.landingZoneUI;
  port = 10023;
  ingestDir = "/etc/nixos/secret-landing-zone";
  pythonPkg = pkgs.python311;

  landingZoneScript = pkgs.writeScriptBin "landing-zone-ui-server" ''
#!${pythonPkg}/bin/python
import http.server, socketserver, os, cgi, html, sys, socket

PORT = ${toString port}
DIRECTORY = "${ingestDir}"

def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

SERVER_IP = get_ip()

HTML = """<!DOCTYPE html>
<html lang="de" data-bs-theme="dark">
<head>
    <meta charset="UTF-8"><title>Secret Landing Zone</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background:#0b0e14; color:#c9d1d9; font-family: sans-serif; }
        .card { background:#161b22; border:1px solid #30363d; border-radius: 12px; margin-top: 50px; }
        .drop-zone { border:2px dashed #30363d; padding:40px; text-align:center; cursor:pointer; border-radius: 8px; }
    </style>
</head>
<body class="d-flex justify-content-center">
    <div class="container" style="max-width:500px">
        <div class="card p-4 shadow-lg">
            <h3 class="text-center mb-2">🔐 Secret Landing Zone</h3>
            <p class="text-center text-muted small mb-4">IP: <span class="badge bg-secondary">{ip}</span></p>
            <form action="/" method="POST" enctype="multipart/form-data">
                <label class="drop-zone w-100" id="dz">
                    <span id="fn">Datei (.conf) auswählen</span>
                    <input type="file" name="file" id="file" class="d-none" required onchange="document.getElementById('fn').innerText=this.files[0].name">
                </label>
                <button type="submit" class="btn btn-success w-100 mt-4 fw-bold">🚀 Hochladen</button>
            </form>
            <div class="mt-3">{msg}</div>
        </div>
    </div>
</body>
</html>"""

class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200); self.send_header("Content-type","text/html"); self.end_headers()
        self.wfile.write(HTML.format(msg="", ip=SERVER_IP).encode('utf-8'))
    def do_POST(self):
        try:
            f = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={'REQUEST_METHOD':'POST','CONTENT_TYPE':self.headers['Content-Type']})
            if "file" in f and f["file"].filename:
                fname = os.path.basename(f["file"].filename)
                with open(os.path.join(DIRECTORY, fname),"wb") as out: out.write(f["file"].file.read())
                m = f'<div class="alert alert-success">✅ {html.escape(fname)} geladen!</div>'
            else: m = '<div class="alert alert-warning">⚠️ Keine Datei.</div>'
        except Exception as e: m = f'<div class="alert alert-danger">💥 {e}</div>'
        self.send_response(200); self.send_header("Content-type","text/html"); self.end_headers()
        self.wfile.write(HTML.format(msg=m, ip=SERVER_IP).encode('utf-8'))

if __name__ == "__main__":
    if not os.path.exists(DIRECTORY): os.makedirs(DIRECTORY, 0o700, True)
    socketserver.TCPServer.allow_reuse_address = True
    socketserver.TCPServer(("", int(PORT)), H).serve_forever()
  '';
in {
  options.my.profiles.infrastructure.landingZoneUI.enable = lib.mkEnableOption "Landing Zone UI";
  config = lib.mkIf cfg.enable {
    systemd.services.landing-zone-ui = {
      description = "Landing Zone UI";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = { ExecStart = "${landingZoneScript}/bin/landing-zone-ui-server"; User = "root"; Restart = "always"; };
    };
    
    # Caddy-Routing für Setup
    services.caddy.virtualHosts."nixhome.local" = {
      extraConfig = ''
        # Fallback auf IP (Henne-Ei)
        @by_ip host ${config.my.configs.server.lanIP}
        handle @by_ip {
          reverse_proxy 127.0.0.1:10023
        }
        
        # Standard .local
        reverse_proxy 127.0.0.1:10023
      '';
    };
    
    networking.firewall.allowedTCPPorts = [ 10023 ];
  };
}
