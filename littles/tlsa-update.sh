#!/bin/bash

################################################################################
# TLSA/DANE Record Auto-Update Script for Caddy + Stalwart Mail Server
################################################################################
#
# PURPOSE:
#
#   Automatically syncs TLSA (DNS-based Authentication of Named Entities)
#   records in Cloudflare when Caddy renews SSL certificates. Also copies
#   the full certificate chain to Stalwart and restarts the container.
#
# FEATURES:
#
#   - Monitors Caddy's certificate for changes
#   - Queries Cloudflare's authoritative DNS (no cache issues)
#   - Updates only DANE-EE (3 1 1) TLSA records
#   - Copies full certificate chain to Stalwart
#   - Restarts Stalwart Docker container
#   - Uses Cloudflare API (no external dependencies)
#
################################################################################
# INSTALLATION
################################################################################
#
# 1. INSTALL DEPENDENCIES:
#
#    sudo apt update
#    sudo apt install openssl dnsutils curl jq
#
#    Note: Docker is likely already installed for Stalwart itself.
#
# 2. CREATE CLOUDFLARE API TOKEN:
#
#    - Go to: https://dash.cloudflare.com/profile/api-tokens
#    - Click "Create Token"
#    - Set permissions:
#      * Zone → DNS → Edit
#    - Set zone resources:
#      * Include → Specific zone → your-domain.com
#    - Add IP filtering (optional but recommended):
#      * Add your server's IPv4 address
#      * Add your server's IPv6 address (if applicable)
#
# 3. GET YOUR CLOUDFLARE ZONE ID:
#
#    curl -X GET "https://api.cloudflare.com/client/v4/zones" \
#      -H "Authorization: Bearer YOUR_API_TOKEN" \
#      -H "Content-Type: application/json" | jq -r '.result[] | {name, id}'
#
# 4. CONFIGURE THIS SCRIPT:
#
#    Edit the "Configuration" section below:
#
#    - Set DOMAIN, SUBDOMAIN, PORT
#    - Set correct paths for Caddy certificates
#    - Set Stalwart certificate directory and container name
#    - Set your Cloudflare API token and zone ID
#    - Set CLOUDFLARE_NAMESERVER to your domain's authoritative NS
#      (used to read uncached TLSA record values)
#
# 5. INSTALL THE SCRIPT:
#
#    sudo cp tlsa-update.sh /usr/local/bin/
#    sudo chmod +x /usr/local/bin/tlsa-update.sh
#
# 6. TEST IT MANUALLY:
#
#    sudo /usr/local/bin/tlsa-update.sh
#
################################################################################
# SYSTEMD SETUP (Recommended)
################################################################################
#
# CREATE SERVICE FILE: /etc/systemd/system/tlsa-update.service
#
#    [Unit]
#    Description=Update TLSA/DANE record for Stalwart from Caddy cert
#    After=network-online.target
#
#    [Service]
#    Type=oneshot
#    ExecStart=/usr/local/bin/tlsa-update.sh
#
# CREATE TIMER FILE: /etc/systemd/system/tlsa-update.timer
#
#    [Unit]
#    Description=Run TLSA check every 5 minutes
#
#    [Timer]
#    OnBootSec=2min
#    OnUnitActiveSec=5min
#
#    [Install]
#    WantedBy=timers.target
#
# ENABLE AND START:
#
#    sudo systemctl daemon-reload
#    sudo systemctl enable --now tlsa-update.timer
#
# CHECK STATUS:
#
#    sudo systemctl status tlsa-update.timer
#    sudo journalctl -u tlsa-update.service -f
#
################################################################################
# CRON SETUP (Alternative)
################################################################################
#
#    */5 * * * * /usr/local/bin/tlsa-update.sh >> /var/log/tlsa-update.log 2>&1
#
################################################################################
# TROUBLESHOOTING
################################################################################
#
# Check if Caddy certificate has full chain (should show 2):
#
#    grep -c "BEGIN CERTIFICATE" /path/to/caddy/cert.crt
#
# Verify Cloudflare API token:
#
#    curl https://api.cloudflare.com/client/v4/user/tokens/verify \
#      -H "Authorization: Bearer YOUR_TOKEN"
#
# Check current TLSA records:
#
#    dig +short TLSA _25._tcp.mail.example.org
#
# Query Cloudflare's authoritative DNS directly:
#
#    dig +short @nova.ns.cloudflare.com TLSA _25._tcp.mail.example.org
#
# Test which IP version is being used:
#
#    curl -4 https://api.cloudflare.com/cdn-cgi/trace  # IPv4
#    curl -6 https://api.cloudflare.com/cdn-cgi/trace  # IPv6
#
################################################################################

set -euo pipefail

################################################################################
# Configuration
################################################################################

DOMAIN="${DOMAIN:-wintermute.se}"
SUBDOMAIN="${SUBDOMAIN:-mail}"
PORT="${PORT:-25}"
CADDY_CERT_PATH="${CADDY_CERT_PATH:-/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${SUBDOMAIN}.${DOMAIN}/${SUBDOMAIN}.${DOMAIN}.crt}"
STALWART_CERT_DIR="${STALWART_CERT_DIR:-/home/cr0t/stalwart/data/cert}"
STALWART_CONTAINER="${STALWART_CONTAINER:-stalwart}"
CLOUDFLARE_NAMESERVER="${CLOUDFLARE_NAMESERVER:-@anastasia.ns.cloudflare.com}"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-REPLACEME}"
CLOUDFLARE_ZONE_ID="${CLOUDFLARE_ZONE_ID:-REPLACEME}"

# Derived variables
readonly FULL_TLSA_RECORD="_${PORT}._tcp.${SUBDOMAIN}.${DOMAIN}"
readonly CADDY_KEY_PATH="${CADDY_CERT_PATH%.crt}.key"
readonly CERT_FILENAME="${SUBDOMAIN}.${DOMAIN}.pem"
readonly KEY_FILENAME="${SUBDOMAIN}.${DOMAIN}.priv.pem"

# Cleanup on exit
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

################################################################################
# Functions
################################################################################

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

error() {
    log "ERROR: $*"
    exit 1
}

check_dependencies() {
    local deps=(openssl dig curl jq docker)
    local missing=()

    for cmd in "${deps[@]}"; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done

    [[ ${#missing[@]} -eq 0 ]] || error "Missing dependencies: ${missing[*]}"
}

get_local_hash() {
    openssl x509 -in "$CADDY_CERT_PATH" -pubkey -noout \
        | openssl pkey -pubin -outform DER \
        | openssl sha256 \
        | awk '{print tolower($2)}'
}

get_upstream_hash() {
    dig +nosplit +short "$CLOUDFLARE_NAMESERVER" TLSA "$FULL_TLSA_RECORD" \
        | awk '$1==3 && $2==1 && $3==1 {print tolower($4); exit}'
}

copy_certificates() {
    mkdir -p "$STALWART_CERT_DIR"

    cp "$CADDY_CERT_PATH" "$STALWART_CERT_DIR/$CERT_FILENAME" \
        || error "Failed to copy certificate"

    if [[ -f "$CADDY_KEY_PATH" ]]; then
        cp "$CADDY_KEY_PATH" "$STALWART_CERT_DIR/$KEY_FILENAME" \
            || error "Failed to copy private key"
    else
        log "WARNING: Private key not found at $CADDY_KEY_PATH"
    fi

    log "Certificates copied to $STALWART_CERT_DIR"
}

restart_stalwart() {
    log "Restarting Stalwart container..."
    docker restart "$STALWART_CONTAINER" &>/dev/null \
        || error "Failed to restart container $STALWART_CONTAINER"
}

cloudflare_api() {
    local method=$1
    local endpoint=$2
    local data=${3:-}

    local args=(
        -4 -s -X "$method"
        "https://api.cloudflare.com/client/v4${endpoint}"
        -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"
        -H "Content-Type: application/json"
    )

    [[ -n "$data" ]] && args+=(-d "$data")

    curl "${args[@]}"
}

get_tlsa_record_id() {
    local response
    response=$(cloudflare_api GET "/zones/${CLOUDFLARE_ZONE_ID}/dns_records?type=TLSA&name=${FULL_TLSA_RECORD}")

    if ! echo "$response" | jq empty 2>/dev/null; then
        log "Invalid API response when fetching TLSA record: $response"
        echo ""
        return
    fi

    echo "$response" \
        | jq -r '(.result // [])[] | select(.data.usage==3 and .data.selector==1 and .data.matching_type==1) | .id' \
        2>/dev/null | head -1 || true
}

update_tlsa_record() {
    local record_id=$1
    local hash=$2

    local payload
    payload=$(jq -n \
        --arg name "$FULL_TLSA_RECORD" \
        --arg cert "$hash" \
        '{
            type: "TLSA",
            name: $name,
            data: {
                usage: 3,
                selector: 1,
                matching_type: 1,
                certificate: $cert
            },
            ttl: 300
        }')

    local response
    if [[ -n "$record_id" && "$record_id" != "null" ]]; then
        log "Updating existing TLSA record (ID: $record_id)"
        response=$(cloudflare_api PUT "/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${record_id}" "$payload")
    else
        log "Creating new TLSA record"
        response=$(cloudflare_api POST "/zones/${CLOUDFLARE_ZONE_ID}/dns_records" "$payload")
    fi

    log "API response: $response"

    local success
    success=$(echo "$response" | jq -r '.success // false' 2>/dev/null) || success="false"
    echo "$success"
}

################################################################################
# Main
################################################################################

main() {
    log "Starting TLSA update process for $DOMAIN"

    check_dependencies

    [[ -f "$CADDY_CERT_PATH" ]] || error "Caddy certificate not found at $CADDY_CERT_PATH"

    # Compare local cert hash against what's published in DNS
    local local_hash upstream_hash
    local_hash=$(get_local_hash)
    upstream_hash=$(get_upstream_hash)

    log "Local hash:    $local_hash"
    log "Upstream hash: ${upstream_hash:-<none>}"

    if [[ -n "$upstream_hash" && "$local_hash" == "$upstream_hash" ]]; then
        log "Hashes match. DNS is up to date."
        exit 0
    fi

    # Update certificates and DNS
    copy_certificates
    restart_stalwart

    log "Updating Cloudflare TLSA record..."
    local record_id success
    record_id=$(get_tlsa_record_id) || true
    success=$(update_tlsa_record "$record_id" "$local_hash") || true

    if [[ "$success" == "true" ]]; then
        log "TLSA update completed successfully."
    else
        error "Failed to update TLSA record (check API response above)"
    fi
}

main "$@"
