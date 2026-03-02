#!/usr/bin/env bash
# Token-Status Report: Quick check for API health.
# source: /etc/nixos/scripts/p-tokens.sh

SECRETS="/etc/nixos/.local-secrets.nix"
echo -e "
🔑 TOKEN & API STATUS REPORT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_cf() {
    T=$(grep "cloudflare =" "$SECRETS" | cut -d """ -f 2)
    R=$(curl -s -o /dev/null -w "%{http_code}" -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" -H "Authorization: Bearer $T")
    if [ "$R" == "200" ]; then
        echo -e "✅ Cloudflare : Valid"
    else
        echo -e "❌ Cloudflare : Error ($R)"
    fi
}

check_gh() {
    T=$(grep "github =" "$SECRETS" | cut -d """ -f 2)
    # Check simple auth (no scope validation, just reachability)
    R=$(curl -s -o /dev/null -w "%{http_code}" -X GET "https://api.github.com/user" -H "Authorization: token $T")
    if [ "$R" == "200" ]; then
        echo -e "✅ GitHub : Valid"
    else
        echo -e "❌ GitHub : Error ($R)"
    fi
}

check_ts() {
    T=$(grep "tailscale =" "$SECRETS" | cut -d """ -f 2)
    # Simple length check for Tailscale keys (no API check)
    if [[ $T == tskey-auth-* ]]; then
        echo -e "✅ Tailscale : Format OK"
    else
        echo -e "❌ Tailscale : Invalid Format"
    fi
}

# Run checks
check_cf
check_gh
check_ts
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
