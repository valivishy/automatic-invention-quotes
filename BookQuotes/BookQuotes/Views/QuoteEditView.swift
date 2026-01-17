import SwiftUI

struct QuoteEditView: View {
    @EnvironmentObject var quoteStore: QuoteStore
    @Environment(\.dismiss) private var dismiss

    enum Mode {
        case add
        case edit(Quote)

        var title: String {
            switch self {
            case .add: return "Add Quote"
            case .edit: return "Edit Quote"
            }
        }
    }

    let mode: Mode

    @State private var text: String = ""
    @State private var bookTitle: String = ""
    @State private var author: String = ""
    @State private var pageString: String = ""
    @State private var chapter: String = ""
    @State private var isFavorite: Bool = false

    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !bookTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section {
                    TextEditor(text: $text)
                        .frame(minHeight: 100)
                        .font(.body)
                } header: {
                    Text("Quote")
                }

                Section {
                    TextField("Book Title", text: $bookTitle)
                    TextField("Author", text: $author)
                } header: {
                    Text("Book Information")
                }

                Section {
                    TextField("Chapter (optional)", text: $chapter)
                    TextField("Page Number (optional)", text: $pageString)
                } header: {
                    Text("Location")
                }

                Section {
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveQuote()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValid)
            }
            .padding()
        }
        .frame(minWidth: 450, minHeight: 400)
        .onAppear {
            loadQuoteData()
        }
    }

    private func loadQuoteData() {
        switch mode {
        case .add:
            break
        case .edit(let quote):
            text = quote.text
            bookTitle = quote.bookTitle
            author = quote.author
            chapter = quote.chapter ?? ""
            pageString = quote.page.map { String($0) } ?? ""
            isFavorite = quote.isFavorite
        }
    }

    private func saveQuote() {
        let page = Int(pageString)
        let chapterValue = chapter.isEmpty ? nil : chapter

        switch mode {
        case .add:
            let quote = Quote(
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                bookTitle: bookTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                author: author.trimmingCharacters(in: .whitespacesAndNewlines),
                page: page,
                chapter: chapterValue,
                isFavorite: isFavorite
            )
            quoteStore.addQuote(quote)

        case .edit(var quote):
            quote.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            quote.bookTitle = bookTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            quote.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
            quote.page = page
            quote.chapter = chapterValue
            quote.isFavorite = isFavorite
            quoteStore.updateQuote(quote)
        }
    }
}

#Preview("Add") {
    QuoteEditView(mode: .add)
        .environmentObject(QuoteStore())
}

#Preview("Edit") {
    QuoteEditView(mode: .edit(Quote.samples[0]))
        .environmentObject(QuoteStore())
}
