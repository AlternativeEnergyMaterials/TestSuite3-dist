#!/bin/bash
set -e

APP_NAME="TestSuite"
APP_DIR="./$APP_NAME"                  # the folder containing the binary
BIN_SRC="$APP_DIR/$APP_NAME"           # actual binary inside folder
INSTALL_DIR="/usr/local/bin/$APP_NAME" # install destination (entire folder)
SERVICE_SRC="./$APP_NAME.service"
SERVICE_DEST="/etc/systemd/system/$APP_NAME.service"

echo "Installing $APP_NAME..."

# Copy entire folder (including _internal etc.)
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    sudo rm -rf "$INSTALL_DIR"
else
    echo "Installing new binary directory..."
fi
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$APP_DIR"/* "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/$APP_NAME"

# Copy systemd service
if [ -f "$SERVICE_DEST" ]; then
    echo "Updating existing systemd service..."
else
    echo "Installing new systemd service..."
fi
sudo cp "$SERVICE_SRC" "$SERVICE_DEST"

# Reload systemd, enable, and restart service
sudo systemctl daemon-reload
sudo systemctl enable "$APP_NAME"
sudo systemctl restart "$APP_NAME"

echo "$APP_NAME installed successfully"
sudo systemctl status "$APP_NAME" --no-pager
