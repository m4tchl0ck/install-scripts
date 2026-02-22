#!/usr/bin/env bash
# configure-smartcard-wsl.sh
# One-time install and configuration for PCSC smartcard visibility in WSL 2.
# Run this once on a fresh system, before running setup-smartcard-wsl.sh.

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

info()    { echo -e "${CYAN}[*]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; exit 1; }

echo ""
echo "=== Smartcard WSL Configuration ==="
echo ""

# --- 1. apt required ----------------------------------------------------------
if ! command -v apt-get &>/dev/null; then
    error "This script requires apt-get. Adjust for your distro."
fi

# --- 2. systemd in /etc/wsl.conf ----------------------------------------------
echo ""
info "Checking systemd..."
if [ "$(ps -p 1 -o comm= 2>/dev/null)" != "systemd" ]; then
    warn "systemd is not running. pcscd requires polkit which requires systemd."
    echo ""
    if ! grep -qs "systemd=true" /etc/wsl.conf 2>/dev/null; then
        read -rp "  Enable systemd in /etc/wsl.conf now? [Y/n] " resp
        if [[ "${resp:-Y}" =~ ^[Yy]$ ]]; then
            if grep -qs "^\[boot\]" /etc/wsl.conf 2>/dev/null; then
                sudo sed -i '/^\[boot\]/a systemd=true' /etc/wsl.conf
            else
                printf '\n[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf > /dev/null
            fi
            success "Updated /etc/wsl.conf."
        fi
    fi
    echo ""
    warn "Run 'wsl --shutdown' in Windows PowerShell, reopen WSL, and re-run this script."
    exit 1
fi
success "systemd is active."

# --- 3. Install PCSC packages -------------------------------------------------
echo ""
info "Checking required packages..."
PACKAGES=(pcscd pcsc-tools libccid pinentry-tty)
MISSING=()
for pkg in "${PACKAGES[@]}"; do
    dpkg -s "$pkg" &>/dev/null || MISSING+=("$pkg")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    warn "Installing: ${MISSING[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y "${MISSING[@]}"
    success "Packages installed."
else
    success "All packages already installed."
fi

# --- 4. plugdev group membership ----------------------------------------------
echo ""
info "Checking plugdev group..."
if id -nG "$USER" | grep -qw plugdev; then
    success "$USER is already in the plugdev group."
else
    warn "Adding $USER to plugdev..."
    sudo usermod -aG plugdev "$USER"
    success "Added. Re-login or run 'wsl --shutdown' for the group to take effect."
fi

# --- 5. Polkit rule -----------------------------------------------------------
echo ""
info "Checking polkit rule for pcscd..."
POLKIT_RULE=/etc/polkit-1/rules.d/99-pcscd.rules
if [ ! -f "$POLKIT_RULE" ]; then
    warn "Adding polkit rule..."
    sudo tee "$POLKIT_RULE" > /dev/null << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id === "org.debian.pcsc-lite.access_pcsc" ||
        action.id === "org.debian.pcsc-lite.access_card") {
        return polkit.Result.YES;
    }
});
EOF
    success "Polkit rule added: $POLKIT_RULE"
else
    success "Polkit rule already present."
fi

# --- 6. pcscd.socket ----------------------------------------------------------
echo ""
info "Enabling pcscd.socket..."
sudo systemctl enable --now pcscd.socket
if systemctl is-active --quiet pcscd.socket; then
    success "pcscd.socket is listening."
else
    error "pcscd.socket failed to start. Check: sudo journalctl -u pcscd.socket --no-pager -n 20"
fi

# --- 7. GPG pinentry configuration --------------------------------------------
echo ""
info "Configuring GPG pinentry for YubiKey..."
GNUPG_DIR="$HOME/.gnupg"
AGENT_CONF="$GNUPG_DIR/gpg-agent.conf"

mkdir -p "$GNUPG_DIR"
chmod 700 "$GNUPG_DIR"

# Set pinentry-program
if grep -qs "^pinentry-program" "$AGENT_CONF" 2>/dev/null; then
    sed -i 's|^pinentry-program .*|pinentry-program /usr/bin/pinentry-tty|' "$AGENT_CONF"
    success "Updated pinentry-program in $AGENT_CONF"
else
    echo "pinentry-program /usr/bin/pinentry-tty" >> "$AGENT_CONF"
    success "Set pinentry-program /usr/bin/pinentry-tty in $AGENT_CONF"
fi

# Ensure allow-loopback-pinentry is present
if ! grep -qs "^allow-loopback-pinentry" "$AGENT_CONF" 2>/dev/null; then
    echo "allow-loopback-pinentry" >> "$AGENT_CONF"
fi

# Add GPG_TTY export to shell rc files
for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$RC" ] && ! grep -qs "GPG_TTY" "$RC"; then
        printf '\nexport GPG_TTY=$(tty)\n' >> "$RC"
        success "Added GPG_TTY export to $RC"
    elif [ -f "$RC" ]; then
        success "GPG_TTY already set in $RC"
    fi
done

# Reload gpg-agent to pick up new config
gpgconf --kill gpg-agent 2>/dev/null || true
success "GPG pinentry configured (pinentry-tty). Restart your shell or run: export GPG_TTY=\$(tty)"

# --- 8. Summary ---------------------------------------------------------------
echo ""
echo "============================================"
success "Configuration complete."
echo ""
echo "  Now run:  ./setup-smartcard-wsl.sh"
echo "  (attach the USB device to WSL first with wsl-usb-attach.ps1)"
echo "============================================"
echo ""
