/**
 * Book Quotes Widget for Übersicht
 * Full-screen display of rotating book quotes
 */

// Widget configuration
export const refreshFrequency = 30 * 60 * 1000; // 30 minutes in milliseconds

// Load quotes from the bundled JSON file
const quotesPath = "book-quotes.widget/quotes.json";

export const command = `cat "$HOME/Library/Application Support/Übersicht/widgets/${quotesPath}"`;

// 32-bit FNV-1a over UTF-8 bytes — change-detection fingerprint for quotes.json.
// Spec TOOLING-26-01: each consumer compares its own current hash against its own
// stored hash; cross-consumer agreement is incidental.
function fnv1a32(str) {
  const bytes = new TextEncoder().encode(str);
  let h = 0x811c9dc5 >>> 0;
  for (let i = 0; i < bytes.length; i++) {
    h ^= bytes[i];
    h = Math.imul(h, 0x01000193) >>> 0;
  }
  return h.toString(16).padStart(8, "0");
}

// Hash-guarded sequential iteration (TOOLING-26-01):
// hash change (new scramble) → reset to index 0; hash same → advance (wrap at end).
// No client-side randomization — order on disk IS the display order.
export const updateState = (event, previousState) => {
  if (event.error) {
    return { ...(previousState || {}), error: event.error };
  }

  try {
    const quotes = JSON.parse(event.output);
    if (!quotes || quotes.length === 0) {
      return { ...(previousState || {}), error: "No quotes available" };
    }

    const hash = fnv1a32(event.output);
    const prev = previousState || {};
    const currentIndex = prev.quotesHash === hash
      ? ((prev.currentIndex || 0) + 1) % quotes.length
      : 0;

    return {
      quote: quotes[currentIndex],
      quotesHash: hash,
      currentIndex,
      error: null,
    };
  } catch (e) {
    return { ...(previousState || {}), error: `Failed to parse quotes: ${e.message}` };
  }
};

// Initial state
export const initialState = {
  quote: null,
  error: null,
  quotesHash: null,
  currentIndex: 0,
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
