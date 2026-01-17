import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

struct Provider: TimelineProvider {
    private let storeReader = QuoteStoreReader()

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: Quote.samples[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let quote = storeReader.randomQuote()
        let entry = QuoteEntry(date: Date(), quote: quote)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let refreshInterval = storeReader.loadRefreshInterval()
        let quotes = storeReader.loadQuotes()

        var entries: [QuoteEntry] = []
        var currentDate = Date()

        let entryCount = min(quotes.count, 10)

        for i in 0..<entryCount {
            let quote = quotes.isEmpty ? Quote.samples[0] : quotes[i % quotes.count]
            let entry = QuoteEntry(date: currentDate, quote: quote)
            entries.append(entry)
            currentDate = currentDate.addingTimeInterval(refreshInterval.timeInterval)
        }

        if entries.isEmpty {
            let entry = QuoteEntry(date: Date(), quote: Quote.samples[0])
            entries.append(entry)
        }

        let nextUpdate = entries.last?.date.addingTimeInterval(refreshInterval.timeInterval) ?? Date().addingTimeInterval(3600)
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct BookQuotesWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(quote: entry.quote)
        case .systemMedium:
            MediumWidgetView(quote: entry.quote)
        case .systemLarge:
            LargeWidgetView(quote: entry.quote)
        default:
            MediumWidgetView(quote: entry.quote)
        }
    }
}

struct SmallWidgetView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(quote.text)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(6)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)

            Text("— \(quote.author)")
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    let quote: Quote

    var body: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(.accent)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(quote.text)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 2) {
                    Text("— \(quote.author)")
                        .font(.system(size: 12, weight: .semibold))

                    Text(quote.bookTitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct LargeWidgetView: View {
    let quote: Quote

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.title2)
                    .foregroundStyle(.accent)
                Spacer()
            }

            Text(quote.text)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .lineSpacing(6)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)

            HStack {
                Rectangle()
                    .fill(.accent)
                    .frame(width: 40, height: 3)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("— \(quote.author)")
                    .font(.system(size: 14, weight: .semibold))

                Text(quote.bookTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                if let chapter = quote.chapter {
                    Text(chapter)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }

                if let page = quote.page {
                    Text("Page \(page)")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(20)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct BookQuotesWidget: Widget {
    let kind: String = "BookQuotesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            BookQuotesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Book Quotes")
        .description("Display inspiring quotes from your favorite books.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview("Small", as: .systemSmall) {
    BookQuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: Quote.samples[0])
    QuoteEntry(date: .now.addingTimeInterval(3600), quote: Quote.samples[1])
}

#Preview("Medium", as: .systemMedium) {
    BookQuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: Quote.samples[0])
}

#Preview("Large", as: .systemLarge) {
    BookQuotesWidget()
} timeline: {
    QuoteEntry(date: .now, quote: Quote.samples[0])
}
