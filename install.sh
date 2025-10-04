#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="note.sh"
TARGET_DIR="/usr/local/bin"
TARGET_PATH="$TARGET_DIR/note"

# Colors for nicer output
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
RESET="\033[0m"

echo -e "${YELLOW}Installing ${SCRIPT_NAME}...${RESET}"

# --- 1. Check that the script exists ---
if [[ ! -f "$SCRIPT_NAME" ]]; then
    echo -e "${RED}Error:${RESET} Could not find '$SCRIPT_NAME' in the current directory."
    exit 1
fi

# --- 2. Check for write permissions (needs sudo if not root) ---
if [[ ! -w "$TARGET_DIR" ]]; then
    echo -e "${YELLOW}Elevated permissions required. Using sudo...${RESET}"
    if ! sudo cp "$SCRIPT_NAME" "$TARGET_PATH"; then
        echo -e "${RED}Error:${RESET} Failed to copy script to $TARGET_DIR."
        exit 1
    fi
    if ! sudo chmod +x "$TARGET_PATH"; then
        echo -e "${RED}Error:${RESET} Failed to set executable permissions."
        exit 1
    fi
else
    cp "$SCRIPT_NAME" "$TARGET_PATH"
    chmod +x "$TARGET_PATH"
fi

# --- 3. Confirm installation ---
if [[ -x "$TARGET_PATH" ]]; then
    echo -e "${GREEN}Success:${RESET} Installed '$TARGET_PATH'"
else
    echo -e "${RED}Error:${RESET} Installation failed."
    exit 1
fi
