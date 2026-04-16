#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	at-spi2-core    \
	libnotify       \
	libsecret       \
	libxss          \
	libxtst         \
	nss             \
	util-linux-libs \
	xdg-utils

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here

echo "Getting app..."
echo "---------------------------------------------------------------"
case "$ARCH" in # they use AMD64 and ARM64 for the deb links
	x86_64)  deb_arch=amd64;;
	# Upstream does not provide aarch64 debs, but lets leave the code just in case it happens in the future
	aarch64) deb_arch=arm64;;
esac
DEB_LINK=$(wget https://api.github.com/repos/obsidianmd/obsidian-releases/releases -O - \
      | sed 's/[()",{} ]/\n/g' | grep -o -m 1 "https.*$deb_arch.deb")
wget --retry-connrefused --tries=30 "$DEB_LINK" -O /tmp/app.deb
mkdir -p ./AppDir/bin
ar xvf /tmp/app.deb
tar -xvf ./data.tar.xz
mv -v ./opt/Obsidian/* ./AppDir/bin
cp -v ./usr/share/applications/obsidian.desktop           ./AppDir
cp -v ./usr/share/icons/hicolor/256x256/apps/obsidian.png ./AppDir
cp -v ./usr/share/icons/hicolor/256x256/apps/obsidian.png ./AppDir/.DirIcon
rm -rf ./data.tar.xz ./control.tar.gz ./usr ./opt

echo "$DEB_LINK" | awk -F'/' '{print $(NF-1)}' > ~/version
