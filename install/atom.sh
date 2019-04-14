#!/bin/bash

URL="https://atom.io/download/deb"
TEMP_FILE="/tmp/atom-install.deb"

sudo wget -O "$TEMP_FILE" "$URL" &&
sudo dpkg -i --skip-same-version "$TEMP_FILE" &&
sudo rm "$TEMP_FILE"

PACKAGES=(
  # Rust language support
  "ide-rust"
  # Themes & Syntax themes
  "github-atom-light-syntax"
  "spacegray-light-neue-ui"
)

echo -e "\npackage installation..."
for PACKAGE in ${PACKAGES[*]}; do
  apm install $PACKAGE
done
