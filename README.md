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

./scripts/install.sh
```

The script will:
1. Install Homebrew (if needed)
2. Install Übersicht
3. Symlink widget to Übersicht widgets folder
4. Set up LaunchAgent for auto-start
5. Launch Übersicht

## Managing Quotes

```bash

# Add a quote
python scripts/add-quote.py "Quote text" --author "Author" --book "Book Title"

# Add with chapter and page
python scripts/add-quote.py "Quote" -a "Author" -b "Book" -c "3" -p 42

# List all quotes
python scripts/add-quote.py --list

# Delete by index
python scripts/add-quote.py --delete 0
```

Or edit directly: `book-quotes.widget/quotes.json`

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

Edit `book-quotes.widget/index.jsx`:

- **Refresh rate**: Change `refreshFrequency` (default: 30 minutes)
- **Font size**: Modify `fontSize` in `styles.quoteText`
- **Max width**: Adjust `maxWidth` in `styles.quoteWrapper`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Widget not visible | Übersicht menu bar → Show All Widgets |
| Manual refresh | Right-click anywhere → Refresh Widget |
| View logs | `cat /tmp/uebersicht.log` |

## Uninstall

```bash

launchctl unload ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm ~/Library/LaunchAgents/com.tracesof.uebersicht.plist
rm ~/Library/Application\ Support/Übersicht/widgets/book-quotes.widget
brew uninstall --cask ubersicht  # optional
```

## Project Structure

```
book-quotes/
├── book-quotes.widget/
│   ├── index.jsx        # Widget code (React/JSX)
│   └── quotes.json      # Quote data
├── scripts/
│   ├── install.sh       # Installation script
│   └── add-quote.py     # Quote management CLI
└── README.md
```

## License

MIT License
