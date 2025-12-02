echo "Remove alternative limine.conf files"

if omarchy-cmd-present limine; then
  # Use sudo test in case /boot requires elevated permissions
  if ! sudo test -f /boot/limine.conf; then
    echo "Error: /boot/limine.conf does not exist. Do not reboot without resolving this issue!"
    exit 1
  fi

  sudo rm -f /boot/EFI/limine/limine.conf
  sudo rm -f /boot/EFI/BOOT/limine.conf
  sudo rm -f /boot/limine/limine.conf
fi
