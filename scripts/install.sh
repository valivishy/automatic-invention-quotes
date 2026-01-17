#!/bin/bash

# Book Quotes Widget Installer
# Run with: curl -fsSL https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master/scripts/install.sh | bash

set -e

REPO_URL="https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master"
WIDGET_NAME="book-quotes.widget"
UBERSICHT_WIDGETS_DIR="$HOME/Library/Application Support/Übersicht/widgets"
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="com.tracesof.uebersicht.plist"

echo ""
echo "Book Quotes Widget Installer"
echo "============================"
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

# Download and install the widget
install_widget() {
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

# Install CLI tool
install_cli() {
    local cli_dir="$HOME/.local/bin"
    local cli_path="$cli_dir/book-quote"

    mkdir -p "$cli_dir"

    echo "[INFO] Installing CLI tool..."
    curl -fsSL "$REPO_URL/scripts/add-quote.py" -o "$cli_path"
    chmod +x "$cli_path"

    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$cli_dir:"* ]]; then
        echo "[INFO] Adding $cli_dir to PATH in shell config..."

        # Detect shell and update config
        if [[ -f "$HOME/.zshrc" ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
            echo "[INFO] Added to ~/.zshrc - restart terminal or run: source ~/.zshrc"
        elif [[ -f "$HOME/.bashrc" ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            echo "[INFO] Added to ~/.bashrc - restart terminal or run: source ~/.bashrc"
        fi
    fi

    echo "[PASS] CLI installed at: $cli_path"
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

    echo "Step 4: Downloading and installing widget..."
    install_widget
    echo ""

    echo "Step 5: Installing CLI tool..."
    install_cli
    echo ""

    echo "Step 6: Setting up auto-start..."
    install_launch_agent
    echo ""

    echo "Step 7: Starting Übersicht..."
    start_ubersicht
    echo ""

    echo "============================"
    echo "[SUCCESS] Installation complete!"
    echo ""
    echo "Your desktop now shows full-screen book quotes."
    echo ""
    echo "Usage:"
    echo "  book-quote --list                    # List all quotes"
    echo "  book-quote \"Text\" -a \"Author\"        # Add a quote"
    echo "  book-quote --delete 0               # Delete by index"
    echo ""
    echo "Quotes file: $UBERSICHT_WIDGETS_DIR/$WIDGET_NAME/quotes.json"
    echo ""
}

main "$@"
