
#!/bin/bash
set -e

echo "🐦 Building BudgieOS Professional Edition"

# Install and configure the Debian live system
mkdir -p auto
mkdir -p config/package-lists
mkdir -p config/hooks/live
mkdir -p config/includes.chroot/usr/share/backgrounds/budgieos
mkdir -p config/includes.chroot/usr/share/applications
mkdir -p config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml

# Live build configuration
cat > auto/config <<'EOF'
#!/bin/sh
set -e
lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --debian-installer live \
  --archive-areas "main contrib non-free non-free-firmware" \
  --bootappend-live "boot=live components quiet splash"
EOF

chmod +x auto/config

# Operating system packages
cat > config/package-lists/budgieos.list.chroot <<'EOF'
xfce4
xfce4-goodies
lightdm
lightdm-gtk-greeter
network-manager
network-manager-gnome
pipewire
wireplumber
pavucontrol
firefox-esr
chromium
sudo
curl
wget
nano
vim
htop
neofetch
thunar
file-roller
gvfs
udisks2
fonts-noto
fonts-noto-color-emoji
fonts-dejavu
papirus-icon-theme
arc-theme
libreoffice
libreoffice-gtk3
vlc
gparted
gnome-disk-utility
flatpak
EOF

# BudgieOS wallpaper
cat > config/includes.chroot/usr/share/backgrounds/budgieos/wallpaper.svg <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg"
width="1920" height="1080" viewBox="0 0 1920 1080">
<defs>
 <linearGradient id="bg" x2="1" y2="1">
  <stop stop-color="#a8dff0"/>
  <stop offset="1" stop-color="#fff0b5"/>
 </linearGradient>
</defs>
<rect width="1920" height="1080" fill="url(#bg)"/>
<circle cx="1550" cy="260" r="230" fill="#fff9db" opacity=".6"/>
<path d="M0 850 Q500 650 1000 850 T1920 800 V1080 H0Z"
fill="#9bd7c4" opacity=".65"/>
<g transform="translate(1450 420)">
 <ellipse cx="0" cy="150" rx="150" ry="180" fill="#f3d66b"/>
 <circle cx="0" cy="0" r="120" fill="#f5df83"/>
 <path d="M-110 -40 Q-40 -145 30 -90 Q-40 -75 -65 -5Z"
 fill="#9ad7e8"/>
 <circle cx="45" cy="-15" r="12" fill="#253e4a"/>
 <path d="M105 15 L150 35 L105 55Z" fill="#eea05b"/>
 <path d="M-40 315 L-65 365 M35 315 L20 365"
 stroke="#d08b4d" stroke-width="12" stroke-linecap="round"/>
</g>
<text x="110" y="180" font-size="90" font-family="sans-serif"
font-weight="bold" fill="#315c68">BudgieOS</text>
<text x="115" y="240" font-size="30" font-family="sans-serif"
letter-spacing="5" fill="#477783">PROFESSIONAL EDITION</text>
</svg>
EOF

# Set a default XFCE wallpaper
cat > config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
 <property name="backdrop" type="empty">
  <property name="screen0" type="empty">
   <property name="monitor0" type="empty">
    <property name="workspace0" type="empty">
     <property name="last-image" type="string"
      value="/usr/share/backgrounds/budgieos/wallpaper.svg"/>
     <property name="image-style" type="int" value="5"/>
    </property>
   </property>
  </property>
 </property>
</channel>
EOF

# Microsoft Office web application launchers
make_app() {
  NAME="$1"
  URL="$2"
  FILE="$3"
  cat > "config/includes.chroot/usr/share/applications/$FILE.desktop" <<EOF
[Desktop Entry]
Name=$NAME
Comment=BudgieOS web application
Exec=xdg-open $URL
Terminal=false
Type=Application
Categories=Office;
EOF
}

make_app "Word Online" "https://www.office.com/launch/word" word-online
make_app "Excel Online" "https://www.office.com/launch/excel" excel-online
make_app "PowerPoint Online" "https://www.office.com/launch/powerpoint" powerpoint-online
make_app "OneNote Online" "https://www.onenote.com/" onenote-online

# Build the actual bootable system
lb config
lb build

echo "BudgieOS build completed!"
