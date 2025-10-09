#!/bin/bash
set -e

APP_NAME="TestSuite"
BIN_SRC="./$APP_NAME"
BIN_DEST="/usr/local/bin/$APP_NAME"
SERVICE_SRC="./$APP_NAME.service"
SERVICE_DEST="/etc/systemd/system/$APP_NAME.service"

echo "Installing $APP_NAME..."

# Copy binary
if [ -f "$BIN_DEST" ]; then
    echo "Updating existing binary..."
else
    echo "Installing new binary..."
fi
sudo cp "$BIN_SRC" "$BIN_DEST"
sudo chmod +x "$BIN_DEST"

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
