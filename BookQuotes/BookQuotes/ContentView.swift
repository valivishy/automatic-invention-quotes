import SwiftUI

struct ContentView: View {
    @EnvironmentObject var quoteStore: QuoteStore
    @State private var selectedQuote: Quote?
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var showFavoritesOnly = false

    var filteredQuotes: [Quote] {
        var result = quoteStore.quotes

        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }

        if !searchText.isEmpty {
            result = result.filter { quote in
                quote.text.localizedCaseInsensitiveContains(searchText) ||
                quote.bookTitle.localizedCaseInsensitiveContains(searchText) ||
                quote.author.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                filterBar

                List(selection: $selectedQuote) {
                    ForEach(filteredQuotes) { quote in
                        QuoteRowView(quote: quote)
                            .tag(quote)
                            .contextMenu {
                                Button {
                                    quoteStore.toggleFavorite(quote)
                                } label: {
                                    Label(
                                        quote.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                        systemImage: quote.isFavorite ? "star.slash" : "star"
                                    )
                                }
                                Divider()
                                Button(role: .destructive) {
                                    quoteStore.deleteQuote(quote)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: quoteStore.deleteQuotes)
                }
                .listStyle(.sidebar)
            }
            .navigationTitle("Book Quotes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Add Quote")
                }
            }
            .frame(minWidth: 250)
        } detail: {
            if let quote = selectedQuote {
                QuoteDetailView(quote: quote)
            } else {
                Text("Select a quote")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText, prompt: "Search quotes")
        .sheet(isPresented: $showingAddSheet) {
            QuoteEditView(mode: .add)
        }
    }

    private var filterBar: some View {
        HStack {
            Toggle(isOn: $showFavoritesOnly) {
                Label("Favorites", systemImage: showFavoritesOnly ? "star.fill" : "star")
            }
            .toggleStyle(.button)
            .buttonStyle(.bordered)
            .tint(showFavoritesOnly ? .yellow : nil)

            Spacer()

            Text("\(filteredQuotes.count) quotes")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct QuoteRowView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quote.text)
                    .lineLimit(2)
                    .font(.body)

                if quote.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }

            Text("— \(quote.author)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct QuoteDetailView: View {
    @EnvironmentObject var quoteStore: QuoteStore
    let quote: Quote
    @State private var showingEditSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(quote.text)
                        .font(.title2)
                        .fontWeight(.medium)
                        .lineSpacing(8)
                        .textSelection(.enabled)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("— \(quote.author)")
                                .font(.title3)
                                .italic()
                        }

                        Text(quote.bookTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        if let chapter = quote.chapter {
                            Text("Chapter: \(chapter)")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }

                        if let page = quote.page {
                            Text("Page \(page)")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                )

                Spacer()
            }
            .padding(32)
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    quoteStore.toggleFavorite(quote)
                } label: {
                    Image(systemName: quote.isFavorite ? "star.fill" : "star")
                }
                .help(quote.isFavorite ? "Remove from Favorites" : "Add to Favorites")

                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
                .help("Edit Quote")

                Button(role: .destructive) {
                    quoteStore.deleteQuote(quote)
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete Quote")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            QuoteEditView(mode: .edit(quote))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(QuoteStore())
}
