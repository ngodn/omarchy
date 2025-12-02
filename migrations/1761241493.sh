echo "Cleanup extra UKI if needed to prevent errors"
if [[ -f /boot/EFI/linux/omarchy_linux.efi ]] && [[ -f /boot/EFI/linux/$(cat /etc/machine-id)_linux.efi ]]; then
  sudo rm -f /boot/EFI/Linux/$(cat /etc/machine-id)_linux.efi

  # Detect limine.conf location (use sudo test in case /boot requires elevated permissions)
  if sudo test -f /boot/EFI/BOOT/limine.conf; then
    limine_config="/boot/EFI/BOOT/limine.conf"
  elif sudo test -f /boot/EFI/limine/limine.conf; then
    limine_config="/boot/EFI/limine/limine.conf"
  elif sudo test -f /boot/limine.conf; then
    limine_config="/boot/limine.conf"
  elif sudo test -f /boot/limine/limine.conf; then
    limine_config="/boot/limine/limine.conf"
  else
    limine_config="/boot/limine.conf"
  fi

  if sudo grep -q "/boot/EFI/Linux/$(cat /etc/machine-id)_linux.efi" "$limine_config" 2>/dev/null; then
    echo -e "Resetting limine config at $limine_config\n(you may need to re-add other entries via sudo limine-update)"

    sudo mv "$limine_config" "${limine_config}.bak" 2>/dev/null || true
  sudo tee "$limine_config" <<EOF >/dev/null
### Read more at config document: https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md
#timeout: 3
default_entry: 2
interface_branding: Omarchy Bootloader
interface_branding_color: 2
hash_mismatch_panic: no

term_background: 1a1b26
backdrop: 1a1b26

# Terminal colors (Tokyo Night palette)
term_palette: 15161e;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;a9b1d6
term_palette_bright: 414868;f7768e;9ece6a;e0af68;7aa2f7;bb9af7;7dcfff;c0caf5

# Text colors
term_foreground: c0caf5
term_foreground_bright: c0caf5
term_background_bright: 24283b

EOF
    sudo limine-update
    sudo limine-snapper-sync
  fi
fi
