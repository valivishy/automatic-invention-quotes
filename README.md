# Book Quotes Desktop Widget

Full-screen book quotes on your macOS desktop using [Übersicht](http://tracesof.net/uebersicht/).

## Features

- Full-screen quote display over your wallpaper
- Elegant serif typography with drop shadow
- Automatic dark/light mode support
- Rotates quotes every 30 minutes
- Auto-starts on login

## Installation

**Remote install** (downloads from GitHub):
```bash

curl -fsSL https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master/scripts/install.sh | bash
```

**Local install** (symlinks to repo - edits sync automatically):
```bash

git clone https://github.com/valivishy/automatic-invention-quotes.git
cd automatic-invention-quotes
./scripts/install.sh --local
```

The script will:
1. Install Homebrew (if needed)
2. Install Übersicht
3. Install widget (download or symlink)
4. Set up LaunchAgent for auto-start
5. Launch Übersicht

## Managing Quotes

Edit directly: `~/Library/Application Support/Übersicht/widgets/book-quotes.widget/quotes.json`

## Quote Format

```json
{
  "text": "The quote text...",
  "author": "Author Name",
  "book": "Book Title",
  "chapter": "3",
  "page": 42
}
```

Only `text` is required. All other fields are optional.

## Configuration

Edit `~/Library/Application Support/Übersicht/widgets/book-quotes.widget/index.jsx`:

- **Refresh rate**: Change `refreshFrequency` (default: 30 minutes)
- **Font size**: Modify `fontSize` in `styles.quoteText`
- **Max width**: Adjust `maxWidth` in `styles.quoteWrapper`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Widget not visible | Übersicht menu bar -> Show All Widgets |
| Manual refresh | Right-click anywhere -> Refresh Widget |
| View logs | `cat /tmp/uebersicht.log` |

## Uninstall

```bash

launchctl unload ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm -rf ~/Library/Application\ Support/Übersicht/widgets/book-quotes.widget
brew uninstall --cask ubersicht  # optional
```

## License

MIT License
