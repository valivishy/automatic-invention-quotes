#!/usr/bin/env python3
"""
CLI tool to add quotes to the Book Quotes widget.

Usage:
    python add-quote.py "Quote text" --author "Author Name" --book "Book Title"
    python add-quote.py "Quote text" -a "Author" -b "Book" -c "Chapter" -p 123
"""

import argparse
import json
import os
import sys
from pathlib import Path


def get_quotes_path() -> Path:
    """Get the path to the quotes.json file."""
    # First, check if there's a symlinked widget in Übersicht
    ubersicht_path = Path.home() / "Library/Application Support/Übersicht/widgets/book-quotes.widget/quotes.json"
    if ubersicht_path.exists():
        # Follow symlink to get actual path
        return ubersicht_path.resolve()

    # Fall back to project directory
    script_dir = Path(__file__).parent.resolve()
    project_dir = script_dir.parent
    return project_dir / "book-quotes.widget" / "quotes.json"


def load_quotes(path: Path) -> list:
    """Load existing quotes from JSON file."""
    if not path.exists():
        return []

    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_quotes(path: Path, quotes: list) -> None:
    """Save quotes to JSON file."""
    with open(path, "w", encoding="utf-8") as f:
        json.dump(quotes, f, indent=2, ensure_ascii=False)


def add_quote(
    text: str,
    author: str | None = None,
    book: str | None = None,
    chapter: str | None = None,
    page: int | None = None,
) -> dict:
    """Create a quote dictionary."""
    quote = {"text": text}

    if author:
        quote["author"] = author
    if book:
        quote["book"] = book
    if chapter:
        quote["chapter"] = chapter
    if page:
        quote["page"] = page

    return quote


def main():
    parser = argparse.ArgumentParser(
        description="Add a quote to the Book Quotes widget",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s "To be or not to be" --author "Shakespeare" --book "Hamlet"
  %(prog)s "The unexamined life is not worth living" -a "Socrates"
  %(prog)s "Quote text" -a "Author" -b "Book" -c "3" -p 42
        """,
    )

    parser.add_argument("text", nargs="?", help="The quote text")
    parser.add_argument(
        "-a", "--author", help="Author of the quote", default=None
    )
    parser.add_argument(
        "-b", "--book", help="Book title or source", default=None
    )
    parser.add_argument(
        "-c", "--chapter", help="Chapter number or name", default=None
    )
    parser.add_argument(
        "-p", "--page", type=int, help="Page number", default=None
    )
    parser.add_argument(
        "--list", "-l", action="store_true", help="List all existing quotes"
    )
    parser.add_argument(
        "--delete", "-d", type=int, help="Delete quote at index (0-based)"
    )

    args = parser.parse_args()
    quotes_path = get_quotes_path()

    # Handle list command
    if args.list:
        quotes = load_quotes(quotes_path)
        if not quotes:
            print("No quotes found.")
            return

        print(f"Quotes in {quotes_path}:\n")
        for i, q in enumerate(quotes):
            author = q.get("author", "Unknown")
            book = q.get("book", "")
            text_preview = q["text"][:50] + "..." if len(q["text"]) > 50 else q["text"]
            print(f"[{i}] \"{text_preview}\"")
            print(f"    — {author}" + (f", {book}" if book else ""))
            print()
        return

    # Handle delete command
    if args.delete is not None:
        quotes = load_quotes(quotes_path)
        if args.delete < 0 or args.delete >= len(quotes):
            print(f"Error: Index {args.delete} out of range (0-{len(quotes)-1})")
            sys.exit(1)

        deleted = quotes.pop(args.delete)
        save_quotes(quotes_path, quotes)
        print(f"Deleted quote: \"{deleted['text'][:50]}...\"")
        return

    # Add new quote
    if not args.text or args.text == "text":
        parser.print_help()
        sys.exit(1)

    quotes = load_quotes(quotes_path)
    new_quote = add_quote(
        text=args.text,
        author=args.author,
        book=args.book,
        chapter=args.chapter,
        page=args.page,
    )

    quotes.append(new_quote)
    save_quotes(quotes_path, quotes)

    print(f"[PASS] Quote added successfully!")
    print(f"       Total quotes: {len(quotes)}")
    print(f"       File: {quotes_path}")
    print()
    print("Preview:")
    print(f'  "{args.text[:60]}{"..." if len(args.text) > 60 else ""}"')
    if args.author:
        print(f"  — {args.author}")


if __name__ == "__main__":
    main()
