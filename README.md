# Book Quotes Desktop Widget

A native macOS app using SwiftUI and WidgetKit that displays quotes and passages from books on your desktop, with timed rotation.

## Features

- **Desktop Widget**: Shows quotes in small, medium, or large sizes
- **Quote Management**: Add, edit, delete, and favorite quotes
- **Automatic Rotation**: Configurable refresh intervals (15min to daily)
- **Dark Mode Support**: Works in both light and dark modes
- **Sample Quotes**: Ships with literary quotes to get you started

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Installation

### Building from Source

1. Clone the repository:
   ```bash
   git clone git@github.com:valivishy/automatic-invention-quotes.git
   cd automatic-invention-quotes
   ```

2. Open the Xcode project:
   ```bash
   open BookQuotes/BookQuotes.xcodeproj
   ```

3. In Xcode:
   - Select the **BookQuotes** scheme
   - Go to **Signing & Capabilities**
   - Select your Development Team for both targets
   - Build and run (Cmd+R)

### Adding the Widget

1. Run the app once to initialize sample data
2. Right-click on your desktop
3. Select **Edit Widgets...**
4. Search for "Book Quotes"
5. Drag your preferred size to the desktop

## Widget Sizes

| Size | Content |
|------|---------|
| Small | Quote text only (truncated if long) |
| Medium | Quote + book title + author |
| Large | Full quote + book info + decorative elements |

## Usage

### Managing Quotes

- **Add Quote**: Click the + button in the main app
- **Edit Quote**: Select a quote and click the pencil icon
- **Delete Quote**: Right-click and select Delete, or use the toolbar
- **Favorite**: Star quotes to mark as favorites

### Settings

Access via **BookQuotes > Settings...** or Cmd+,

- **Refresh Interval**: How often the widget shows a new quote
  - 15 minutes
  - 30 minutes
  - 1 hour (default)
  - 4 hours
  - Daily

## Project Structure

```
BookQuotes/
├── BookQuotes/                    # Main app target
│   ├── BookQuotesApp.swift       # App entry point
│   ├── ContentView.swift         # Main UI
│   └── Views/
│       ├── QuoteEditView.swift   # Add/edit form
│       └── SettingsView.swift    # App settings
├── BookQuotesWidget/             # Widget extension
│   └── BookQuotesWidget.swift    # Widget views & provider
└── Shared/                       # Shared between targets
    ├── Quote.swift               # Data model
    └── QuoteStore.swift          # JSON persistence
```

## Data Storage

Quotes are stored in JSON format at:
```
~/Library/Group Containers/group.com.valivishy.BookQuotes/quotes.json
```

This location is shared between the main app and widget via App Groups.

## License

MIT License
