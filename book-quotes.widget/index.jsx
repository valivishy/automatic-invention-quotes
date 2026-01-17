/**
 * Book Quotes Widget for Übersicht
 * Full-screen display of rotating book quotes
 */

// Widget configuration
export const refreshFrequency = 30 * 60 * 1000; // 30 minutes in milliseconds

// Load quotes from the bundled JSON file
const quotesPath = "book-quotes.widget/quotes.json";

export const command = `cat "$HOME/Library/Application Support/Übersicht/widgets/${quotesPath}"`;

// Parse the quotes and select a random one
export const updateState = (event, previousState) => {
  if (event.error) {
    return { error: event.error };
  }

  try {
    const quotes = JSON.parse(event.output);
    if (!quotes || quotes.length === 0) {
      return { error: "No quotes available" };
    }

    const randomIndex = Math.floor(Math.random() * quotes.length);
    return { quote: quotes[randomIndex], error: null };
  } catch (e) {
    return { error: `Failed to parse quotes: ${e.message}` };
  }
};

// Initial state
export const initialState = {
  quote: null,
  error: null,
};

// Full-screen widget styling
const styles = {
  fullscreen: {
    position: "fixed",
    top: 0,
    left: 0,
    width: "100vw",
    height: "100vh",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
    fontFamily: "'Georgia', 'Times New Roman', serif",
    padding: "80px",
    boxSizing: "border-box",
  },
  quoteWrapper: {
    maxWidth: "900px",
    textAlign: "center",
  },
  quoteText: {
    fontSize: "32px",
    fontStyle: "italic",
    lineHeight: 1.7,
    marginBottom: "40px",
    fontWeight: 400,
    letterSpacing: "0.02em",
  },
  quoteMark: {
    fontSize: "64px",
    lineHeight: 0.5,
    opacity: 0.3,
    fontFamily: "Georgia, serif",
  },
  attribution: {
    fontSize: "20px",
    fontStyle: "normal",
    opacity: 0.85,
  },
  author: {
    fontWeight: 600,
    marginBottom: "8px",
  },
  bookInfo: {
    fontSize: "16px",
    opacity: 0.7,
    fontStyle: "italic",
  },
  error: {
    fontSize: "18px",
    opacity: 0.6,
  },
};

// CSS for dark/light mode and text shadow for readability
export const className = `
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;

  .quote-fullscreen {
    text-shadow: 0 2px 20px rgba(0, 0, 0, 0.5);
  }

  @media (prefers-color-scheme: dark) {
    .quote-fullscreen {
      color: rgba(255, 255, 255, 0.9);
      text-shadow: 0 2px 30px rgba(0, 0, 0, 0.8);
    }
  }

  @media (prefers-color-scheme: light) {
    .quote-fullscreen {
      color: rgba(255, 255, 255, 0.95);
      text-shadow:
        0 2px 20px rgba(0, 0, 0, 0.7),
        0 4px 40px rgba(0, 0, 0, 0.5);
    }
  }
`;

// Render the widget
export const render = ({ quote, error }) => {
  if (error) {
    return (
      <div className="quote-fullscreen" style={styles.fullscreen}>
        <p style={styles.error}>{error}</p>
      </div>
    );
  }

  if (!quote) {
    return (
      <div className="quote-fullscreen" style={styles.fullscreen}>
        <p style={styles.error}>Loading...</p>
      </div>
    );
  }

  const bookDetails = [];
  if (quote.book) bookDetails.push(quote.book);
  if (quote.chapter) bookDetails.push(`Ch. ${quote.chapter}`);
  if (quote.page) bookDetails.push(`p. ${quote.page}`);

  return (
    <div className="quote-fullscreen" style={styles.fullscreen}>
      <div style={styles.quoteWrapper}>
        <div style={styles.quoteMark}>"</div>
        <p style={styles.quoteText}>{quote.text}</p>
        <div style={styles.quoteMark}>"</div>
        <div style={styles.attribution}>
          <div style={styles.author}>— {quote.author || "Unknown"}</div>
          {bookDetails.length > 0 && (
            <div style={styles.bookInfo}>{bookDetails.join(", ")}</div>
          )}
        </div>
      </div>
    </div>
  );
};
