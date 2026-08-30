#!/usr/bin/env bash
# Fedora package layer for the rice. Needs sudo; opt-in, exactly like
# macos/defaults.sh. install.sh never calls this.
#
#   ~/.dotfiles/linux/packages.sh
#
# Everything below is in Fedora's own repos. Ghostty is not, and is built from
# source by linux/ghostty.sh — see the note at the bottom.
set -euo pipefail

echo "==> compositor + bar"
sudo dnf install -y \
  niri waybar swaybg fuzzel nwg-drawer \
  wl-clipboard brightnessctl wireplumber \
  xdg-desktop-portal-gnome xdg-desktop-portal-gtk

echo "==> shell"
sudo dnf install -y zsh zsh-autosuggestions zsh-syntax-highlighting

echo "==> cli layer"
sudo dnf install -y \
  eza bat fd-find fzf zoxide atuin git-delta ripgrep fastfetch btop tmux jq \
  python3-pillow

echo "==> Framework 13 / power"
# Do NOT install power-profiles-daemon here. Fedora 44 ships tuned-ppd, which
# provides the same `ppd-service` and the same net.hadess.PowerProfiles D-Bus
# interface GNOME talks to — the two packages actively conflict, and pulling
# in power-profiles-daemon would mean erasing tuned-ppd for no gain.
# The only thing lost is the `powerprofilesctl` CLI; `tuned-adm` is the
# equivalent, and it is already installed.
if rpm -q tuned-ppd >/dev/null 2>&1; then
  sudo systemctl enable --now tuned tuned-ppd
  echo "  tuned-ppd active · $(tuned-adm active 2>/dev/null)"
elif rpm -q power-profiles-daemon >/dev/null 2>&1; then
  sudo systemctl enable --now power-profiles-daemon.service
  echo "  power-profiles-daemon active"
else
  sudo dnf install -y tuned-ppd
  sudo systemctl enable --now tuned tuned-ppd
fi

echo "==> fingerprint (Framework's Goodix sensor)"
# Both are usually already in a Fedora Workstation install; this is for the
# minimal ones. Enrolling is the user's own step — `fprintd-enroll` needs a
# finger on the reader — and `with-fingerprint` is what puts pam_fprintd in
# system-auth, which is what swaylock and sudo inherit.
sudo dnf install -y fprintd fprintd-pam
if authselect current 2>/dev/null | grep -q "with-fingerprint"; then
  echo "  with-fingerprint already enabled"
else
  sudo authselect enable-feature with-fingerprint \
    && echo "  with-fingerprint enabled — now run: fprintd-enroll"
fi

echo "==> firmware"
# Framework ships BIOS over LVFS, so fwupd is the whole update path.
# fwupd is in Fedora's default install; only add it if it somehow is not.
rpm -q fwupd >/dev/null 2>&1 || sudo dnf install -y fwupd
sudo fwupdmgr refresh --force || true
sudo fwupdmgr get-updates || echo "  no updates pending"

cat <<'NOTE'

==> not installed automatically

  powerlevel10k   Not packaged by Fedora. The shell prompt this rice recolours.
                  git clone --depth=1 https://github.com/romkatv/powerlevel10k \
                    ~/.local/share/powerlevel10k
                  then add to the TOP of ~/.zshrc:
                    source ~/.local/share/powerlevel10k/powerlevel10k.zsh-theme

  Ghostty         Not in Fedora's repos and not on Fedora's filtered Flathub,
                  and the only prebuilt binaries are third-party COPRs — this
                  script will not choose an unofficial build for you. Build it
                  from upstream's signed source tarball instead:
                    ~/.dotfiles/linux/ghostty.sh
                  It installs into ~/.local, so it leaves nothing root-owned.
                  Until you run it the rice works fine in any terminal; only
                  ghostty/config and the quick-terminal bind go unused.

  Nerd Font       JetBrainsMono Nerd Font is not packaged. Fetch the release
                  zip into ~/.local/share/fonts and run `fc-cache -f`.

  The HUD's panes netwatch / syswatch / diskwatch are cargo installs:
                    cargo install netwatch-tui syswatch diskwatch
                  soundwatch is the fourth, and the one not on crates.io:
                    cargo install --git https://github.com/matthart1983/soundwatch
                  It needs no CoreAudio and no permission here — devices,
                  streams, latency and xruns come out of /proc/asound. Only the
                  meters want a library, and libpulse is dlopened at first use,
                  so a box with no sound server still runs the tool and says
                  which part is missing. On a Fedora desktop pipewire-pulseaudio
                  already provides it; `rice-doctor` says so either way.

NOTE
