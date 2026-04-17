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
TARBALL_LINK=$(wget https://api.github.com/repos/obsidianmd/obsidian-releases/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -o "https.*$farch.tar.gz")

# for aarch64 they use arm64, but x86_64 has no arch in its name
case "$ARCH" in
	x86_64)  TARBALL_LINK=$(echo "$TARBALL_LINK" | grep -v arm64 | head -1);;
	aarch64) TARBALL_LINK=$(echo "$TARBALL_LINK" | grep arm64 | head -1);;
esac

wget --retry-connrefused --tries=30 "$TARBALL_LINK" -O /tmp/temp.tar.gz
tar -xvf /tmp/temp.tar.gz

mkdir -p ./AppDir/bin
mv -v ./obsidian-*/* ./AppDir/bin
cp -v ./AppDir/bin/resources/icon.png ./AppDir
cp -v ./AppDir/bin/resources/icon.png ./AppDir/.DirIcon
rm -rf ./obsidian-*/

echo "$TARBALL_LINK" | awk -F'/' '{print $(NF-1)}' > ~/version
