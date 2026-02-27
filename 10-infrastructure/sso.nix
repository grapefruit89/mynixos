{ config, lib, ... }: {
  services.traefik.dynamicConfigOptions.http.middlewares.sso-auth.forwardAuth = {
    address = "http://127.0.0.1:8080/api/auth/verify";
    trustForwardHeader = true;
    authResponseHeaders = [ "X-Forwarded-User" ];
  };
}
