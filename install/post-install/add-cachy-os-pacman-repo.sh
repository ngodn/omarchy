#!/bin/bash

echo "Adding CachyOS pacman repositories..."

# Detect CPU architecture level
detect_arch() {
  local arch_support=$(/lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep supported)
  local march=$(gcc -march=native -Q --help=target 2>&1 | grep -Po "^\s+-march=\s+\K(\w+)$")

  if [[ "$march" == "znver4" ]] || [[ "$march" == "znver5" ]]; then
    echo "znver4"
  elif echo "$arch_support" | grep -q "x86-64-v4 (supported"; then
    echo "v4"
  elif echo "$arch_support" | grep -q "x86-64-v3 (supported"; then
    echo "v3"
  else
    echo "generic"
  fi
}

ARCH_LEVEL=$(detect_arch)
echo "Detected CPU architecture level: $ARCH_LEVEL"

# Import and sign the CachyOS key
echo "Importing CachyOS repository key..."
sudo pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key F3B607488DB35A47

# Install keyring and mirrorlist packages
echo "Installing CachyOS keyring and mirrorlists..."
sudo pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-22-1-any.pkg.tar.zst'

# Backup pacman.conf
sudo cp /etc/pacman.conf /etc/pacman.conf.bak.cachyos

# Build repository entries based on architecture
case "$ARCH_LEVEL" in
  znver4)
    CACHYOS_REPOS="# CachyOS repositories (znver4)
[cachyos-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos-core-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos-extra-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist"
    ;;
  v4)
    CACHYOS_REPOS="# CachyOS repositories (x86-64-v4)
[cachyos-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos-core-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos-extra-v4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist"
    ;;
  v3)
    CACHYOS_REPOS="# CachyOS repositories (x86-64-v3)
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist"
    ;;
  *)
    CACHYOS_REPOS="# CachyOS repositories (generic x86-64)
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist"
    ;;
esac

# Add CachyOS repos above [core] section (they must be before Arch repos)
if ! grep -q "\[cachyos\]" /etc/pacman.conf; then
  echo "Adding CachyOS repositories to pacman.conf..."
  sudo sed -i "/^\[core\]/i $CACHYOS_REPOS\n" /etc/pacman.conf
else
  echo "CachyOS repositories already present in pacman.conf"
fi

# Sync package databases
echo "Synchronizing package databases..."
sudo pacman -Sy

echo "CachyOS repositories added successfully!"
echo "Run 'sudo pacman -Syu' to update your system with CachyOS packages."
