#!/bin/bash

# Book Quotes Widget Installer
# Remote: curl -fsSL https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master/scripts/install.sh | bash
# Local:  ./scripts/install.sh --local

set -e

REPO_URL="https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master"
WIDGET_NAME="book-quotes.widget"
UBERSICHT_WIDGETS_DIR="$HOME/Library/Application Support/Übersicht/widgets"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="com.tracesof.uebersicht.plist"
LOCAL_MODE=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --local|-l)
            LOCAL_MODE=true
            ;;
    esac
done

echo ""
echo "Book Quotes Widget Installer"
echo "============================"
if $LOCAL_MODE; then
    echo "Mode: Local (symlink)"
else
    echo "Mode: Remote (download)"
fi
echo ""

# Check for Homebrew
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo "[INFO] Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "[PASS] Homebrew is installed"
    fi
}

# Install Übersicht
install_ubersicht() {
    if [[ -d "/Applications/Übersicht.app" ]]; then
        echo "[PASS] Übersicht is already installed"
    else
        echo "[INFO] Installing Übersicht..."
        brew install --cask ubersicht
        echo "[PASS] Übersicht installed successfully"
    fi
}

# Create widgets directory if it doesn't exist
create_widgets_dir() {
    if [[ ! -d "$UBERSICHT_WIDGETS_DIR" ]]; then
        echo "[INFO] Creating Übersicht widgets directory..."
        mkdir -p "$UBERSICHT_WIDGETS_DIR"
    fi
    echo "[PASS] Widgets directory exists"
}

# Download and install the widget (remote mode)
install_widget_remote() {
    local widget_dest="$UBERSICHT_WIDGETS_DIR/$WIDGET_NAME"

    # Remove existing widget
    if [[ -L "$widget_dest" ]] || [[ -d "$widget_dest" ]]; then
        echo "[INFO] Removing existing widget..."
        rm -rf "$widget_dest"
    fi

    echo "[INFO] Downloading widget files..."
    mkdir -p "$widget_dest"

    # Download widget files from GitHub
    curl -fsSL "$REPO_URL/book-quotes.widget/index.jsx" -o "$widget_dest/index.jsx"
    curl -fsSL "$REPO_URL/book-quotes.widget/quotes.json" -o "$widget_dest/quotes.json"

    echo "[PASS] Widget installed at: $widget_dest"
}

# Symlink widget to local repo (local mode)
install_widget_local() {
    local widget_dest="$UBERSICHT_WIDGETS_DIR/$WIDGET_NAME"

    # Find repo root (script is in scripts/)
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local repo_root="$(dirname "$script_dir")"
    local widget_src="$repo_root/$WIDGET_NAME"

    if [[ ! -d "$widget_src" ]]; then
        echo "[FAIL] Widget not found at: $widget_src"
        exit 1
    fi

    # Remove existing widget
    if [[ -L "$widget_dest" ]] || [[ -d "$widget_dest" ]]; then
        echo "[INFO] Removing existing widget..."
        rm -rf "$widget_dest"
    fi

    echo "[INFO] Creating symlink to local repo..."
    ln -s "$widget_src" "$widget_dest"

    echo "[PASS] Widget symlinked: $widget_dest -> $widget_src"
}

# Install LaunchAgent for auto-start
install_launch_agent() {
    local plist_path="$LAUNCH_AGENT_DIR/$LAUNCH_AGENT_PLIST"

    mkdir -p "$LAUNCH_AGENT_DIR"

    # Unload existing agent if present
    if [[ -f "$plist_path" ]]; then
        echo "[INFO] Unloading existing LaunchAgent..."
        launchctl unload "$plist_path" 2>/dev/null || true
    fi

    echo "[INFO] Creating LaunchAgent for auto-start..."
    cat > "$plist_path" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tracesof.uebersicht</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>-a</string>
        <string>Übersicht</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>Crashed</key>
        <true/>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/uebersicht.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/uebersicht.error.log</string>
</dict>
</plist>
EOF

    echo "[INFO] Loading LaunchAgent..."
    launchctl load "$plist_path"
    echo "[PASS] LaunchAgent installed and loaded"
}

# Start Übersicht
start_ubersicht() {
    if pgrep -x "Übersicht" > /dev/null; then
        echo "[INFO] Übersicht is already running. Refreshing widgets..."
        osascript -e 'tell application "Übersicht" to refresh' 2>/dev/null || true
    else
        echo "[INFO] Starting Übersicht..."
        open -a "Übersicht"
    fi
    echo "[PASS] Übersicht is running"
}

# Main installation
main() {
    echo "Step 1: Checking Homebrew..."
    check_homebrew
    echo ""

    echo "Step 2: Installing Übersicht..."
    install_ubersicht
    echo ""

    echo "Step 3: Setting up widgets directory..."
    create_widgets_dir
    echo ""

    echo "Step 4: Installing widget..."
    if $LOCAL_MODE; then
        install_widget_local
    else
        install_widget_remote
    fi
    echo ""

    echo "Step 5: Setting up auto-start..."
    install_launch_agent
    echo ""

    echo "Step 6: Starting Übersicht..."
    start_ubersicht
    echo ""

    echo "============================"
    echo "[SUCCESS] Installation complete!"
    echo ""
    echo "Your desktop now shows full-screen book quotes."
    echo ""
    echo "Edit quotes: $UBERSICHT_WIDGETS_DIR/$WIDGET_NAME/quotes.json"
    echo ""
}

main "$@"
