# Autoinstall

## Building a bootable USB

1. Download [Ubuntu Server 24.04 LTS](https://ubuntu.com/download/server)
2. Flash the ISO to a USB drive (e.g. with `dd` or balenaEtcher)
3. Mount the USB and copy these files to the root of the USB:
   - `user-data`
   - `meta-data`
4. Boot the ThinkCentre from the USB — the install runs unattended

## What the autoinstall does

- LVM storage layout using the full disk
- Creates a `deploy` user with SSH-only auth (password login disabled)
- Grants `deploy` passwordless sudo
- Installs OpenSSH server

## After install

Ensure your SSH public key is set in `user-data` before building the USB.
