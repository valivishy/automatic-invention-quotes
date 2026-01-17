import Foundation

struct Quote: Codable, Identifiable, Hashable {
    let id: UUID
    var text: String
    var bookTitle: String
    var author: String
    var page: Int?
    var chapter: String?
    var dateAdded: Date
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        text: String,
        bookTitle: String,
        author: String,
        page: Int? = nil,
        chapter: String? = nil,
        dateAdded: Date = Date(),
        isFavorite: Bool = false
    ) {
        self.id = id
        self.text = text
        self.bookTitle = bookTitle
        self.author = author
        self.page = page
        self.chapter = chapter
        self.dateAdded = dateAdded
        self.isFavorite = isFavorite
    }

    var attribution: String {
        var parts = [bookTitle]
        if let chapter = chapter {
            parts.append("Chapter: \(chapter)")
        }
        if let page = page {
            parts.append("p. \(page)")
        }
        return parts.joined(separator: " · ")
    }
}

extension Quote {
    static let samples: [Quote] = [
        Quote(
            text: "It is our choices, Harry, that show what we truly are, far more than our abilities.",
            bookTitle: "Harry Potter and the Chamber of Secrets",
            author: "J.K. Rowling",
            chapter: "The Very Secret Diary"
        ),
        Quote(
            text: "So we beat on, boats against the current, borne back ceaselessly into the past.",
            bookTitle: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            page: 180
        ),
        Quote(
            text: "All happy families are alike; each unhappy family is unhappy in its own way.",
            bookTitle: "Anna Karenina",
            author: "Leo Tolstoy",
            chapter: "Part One"
        ),
        Quote(
            text: "It was the best of times, it was the worst of times, it was the age of wisdom, it was the age of foolishness.",
            bookTitle: "A Tale of Two Cities",
            author: "Charles Dickens",
            chapter: "Book the First"
        ),
        Quote(
            text: "The only way to do great work is to love what you do.",
            bookTitle: "Steve Jobs",
            author: "Walter Isaacson",
            chapter: "Stanford Commencement"
        )
    ]
}
