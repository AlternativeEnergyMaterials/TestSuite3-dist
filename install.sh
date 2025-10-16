#!/bin/bash
set -e

APP_NAME="TestSuite"
APP_DIR="./$APP_NAME"                  # the folder containing the binary
INSTALL_DIR="/usr/local/bin/$APP_NAME" # install destination (entire folder)
SERVICE_SRC="./$APP_NAME.service"
SERVICE_DEST="/etc/systemd/system/$APP_NAME.service"

OVERWRITE_DB=false
if [[ "$1" == "--overwrite-db" ]]; then
    OVERWRITE_DB=true
fi

echo "Installing $APP_NAME..."

# If app already installed
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."

    if [ "$OVERWRITE_DB" = false ]; then
        echo "Preserving existing .db files..."
        # Temporarily save .db files
        TMP_DB_DIR=$(mktemp -d)
        sudo find "$INSTALL_DIR" -maxdepth 1 -name "*.db" -exec cp {} "$TMP_DB_DIR/" \;
    else
        echo "Overwriting existing .db files..."
    fi

    sudo rm -rf "$INSTALL_DIR"
else
    echo "Installing new binary directory..."
fi

# Recreate folder and copy files
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r "$APP_DIR"/* "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/$APP_NAME"

# Restore preserved .db files (if any)
if [ "$OVERWRITE_DB" = false ] && [ -n "${TMP_DB_DIR:-}" ]; then
    sudo cp "$TMP_DB_DIR"/*.db "$INSTALL_DIR/" 2>/dev/null || true
    rm -rf "$TMP_DB_DIR"
fi

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
