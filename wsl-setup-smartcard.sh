#!/usr/bin/env bash
# setup-smartcard-wsl.sh
# Run each time you re-attach the smartcard to WSL.
# Prerequisite: run configure-smartcard-wsl.sh once on a fresh system first.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; exit 1; }

echo ""
echo "=== Smartcard WSL Setup ==="
echo ""

# --- 1. Kill stale gpg-agent (avoids cached state from previous sessions) ----
info "Resetting gpg-agent..."
gpgconf --kill gpg-agent 2>/dev/null || true
success "gpg-agent reset."

# --- 2. Verify GPG sees the smartcard device ---------------------------------
echo ""
info "Checking GPG card status..."
sleep 1

if gpg --card-status 2>/dev/null; then
    echo ""
    success "Smartcard device is accessible via GPG in WSL."
    echo ""
    echo "  You can now use: gpg, ssh (if card has SSH key), git signing, etc."
else
    echo ""
    echo -e "${RED}[✗]${NC} GPG could not read the card."
    echo ""
    echo "  Troubleshooting steps:"
    echo "    1. Attach the device to WSL first -- run wsl-usb-attach.ps1 on Windows"
    echo "    2. Restart pcscd   : sudo service pcscd restart"
    echo "    3. Kill gpg-agent  : gpgconf --kill gpg-agent"
    echo "    4. Retry           : gpg --card-status"
    echo "    5. Scan for devices: pcsc_scan  (Ctrl+C to stop)"
    exit 1
fi
