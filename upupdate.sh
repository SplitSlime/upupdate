#!/bin/bash
CONFIRM=false
if [ "$1" = "-c" ]; then
    CONFIRM=true
fi
confirm() {
    if [ "$CONFIRM" = true ]; then
        read -rp "$1 [y/N]: " answer
        [[ "$answer" =~ ^[Yy]$ ]]
    else
        return 0
    fi
}
if [ "$CONFIRM" = true ]; then
    PARU_FLAGS=""
    FLATPAK_FLAGS=""
    NPM_FLAGS=""
    RUSTUP_FLAGS=""
else
    PARU_FLAGS="--noconfirm"
    FLATPAK_FLAGS="-y"
    NPM_FLAGS="--yes"
    RUSTUP_FLAGS="--no-confirm"
fi
if command -v rate-mirrors &>/dev/null; then
    if confirm "Rate mirrors?"; then
        echo "Rating Mirrors"
        rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist || true
    fi
fi
if confirm "System update?"; then
    echo "System Update"
    paru -Syu $PARU_FLAGS --skipreview || true
fi
if command -v flatpak &>/dev/null; then
    if confirm "Flatpak update?"; then
        echo "Flatpak Update"
        flatpak update $FLATPAK_FLAGS || true
    fi
fi
if command -v snap &>/dev/null; then
    if confirm "Snap update?"; then
        echo "Snap Update"
        sudo snap refresh || true
    fi
fi
if command -v fish &>/dev/null; then
    if confirm "Fish extension update?"; then
        echo "Fish Extension Update"
        fish -c "fisher update" || true
    fi
fi
if command -v rustup &>/dev/null; then
    if confirm "Rust update?"; then
        echo "Rust Update"
        rustup update $RUSTUP_FLAGS || true
    fi
fi
if command -v pip &>/dev/null; then
    if confirm "pip update?"; then
        echo "pip Update"
        pip install --upgrade pip || true
    fi
fi
if command -v npm &>/dev/null; then
    if confirm "npm update?"; then
        echo "npm Update"
        npm update -g $NPM_FLAGS || true
    fi
fi
if command -v cargo &>/dev/null; then
    if confirm "Cargo update?"; then
        echo "Cargo Update"
        cargo install-update -a || true
    fi
fi
if command -v fwupdmgr &>/dev/null; then
    if confirm "Firmware update?"; then
        echo "Firmware Update"
        fwupdmgr refresh || true
        fwupdmgr update --no-reboot-check || true
    fi
fi
if confirm "Clean cache?"; then
    echo "Cleaning Cache"
    sudo paccache -rk2 || true
    sudo paccache -ruk0 || true
    rm -rf ~/.cache/paru/clone
    rm -rf ~/.cache/yay
fi
if [ -n "$(paru -Qdtq)" ]; then
    if confirm "Remove orphans?"; then
        echo "Orphan Removal"
        paru -Rns $(paru -Qdtq) $PARU_FLAGS || true
    fi
fi
if confirm "Clean journal?"; then
    echo "Journal Cleanup"
    sudo journalctl --vacuum-time=2weeks || true
fi
