# Book Quotes Desktop Widget

Full-screen book quotes on your macOS desktop using [Übersicht](http://tracesof.net/uebersicht/). No Xcode or Apple Developer account needed.

## Features

- Full-screen quote display over your wallpaper
- Elegant serif typography with drop shadow
- Automatic dark/light mode support
- Rotates quotes every 30 minutes
- CLI tool to manage quotes
- Auto-starts on login

## Installation

```bash

curl -fsSL https://raw.githubusercontent.com/valivishy/automatic-invention-quotes/master/scripts/install.sh | bash
```

The script will:
1. Install Homebrew (if needed)
2. Install Übersicht
3. Download widget to Übersicht widgets folder
4. Install `book-quote` CLI to `~/.local/bin`
5. Set up LaunchAgent for auto-start
6. Launch Übersicht

## Managing Quotes

```bash

# List all quotes
book-quote --list

# Add a quote
book-quote "Quote text" --author "Author" --book "Book Title"

# Add with chapter and page
book-quote "Quote" -a "Author" -b "Book" -c "3" -p 42

# Delete by index
book-quote --delete 0
```

Or edit directly: `~/Library/Application Support/Übersicht/widgets/book-quotes.widget/quotes.json`

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
| Widget not visible | Übersicht menu bar → Show All Widgets |
| Manual refresh | Right-click anywhere → Refresh Widget |
| View logs | `cat /tmp/uebersicht.log` |
| `book-quote` not found | Restart terminal or run `source ~/.zshrc` |

## Uninstall

```bash

launchctl unload ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm -rf ~/Library/Application\ Support/Übersicht/widgets/book-quotes.widget
rm ~/.local/bin/book-quote
brew uninstall --cask ubersicht  # optional
```

## License

MIT License
