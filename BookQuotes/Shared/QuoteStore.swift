import Foundation
import SwiftUI

enum RefreshInterval: String, CaseIterable, Codable {
    case fifteenMinutes = "15min"
    case thirtyMinutes = "30min"
    case oneHour = "1hr"
    case fourHours = "4hr"
    case daily = "daily"

    var displayName: String {
        switch self {
        case .fifteenMinutes: return "15 minutes"
        case .thirtyMinutes: return "30 minutes"
        case .oneHour: return "1 hour"
        case .fourHours: return "4 hours"
        case .daily: return "Daily"
        }
    }

    var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60
        case .thirtyMinutes: return 30 * 60
        case .oneHour: return 60 * 60
        case .fourHours: return 4 * 60 * 60
        case .daily: return 24 * 60 * 60
        }
    }
}

@MainActor
class QuoteStore: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var refreshInterval: RefreshInterval = .oneHour

    private let fileManager = FileManager.default
    private let appGroupIdentifier = "group.com.valivishy.BookQuotes"

    private var quotesFileURL: URL {
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL.appendingPathComponent("quotes.json")
        }
        return applicationSupportDirectory.appendingPathComponent("quotes.json")
    }

    private var settingsFileURL: URL {
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL.appendingPathComponent("settings.json")
        }
        return applicationSupportDirectory.appendingPathComponent("settings.json")
    }

    private var applicationSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[0].appendingPathComponent("BookQuotes")

        if !fileManager.fileExists(atPath: appSupportURL.path) {
            try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        }

        return appSupportURL
    }

    init() {
        loadQuotes()
        loadSettings()
    }

    func loadQuotes() {
        guard fileManager.fileExists(atPath: quotesFileURL.path) else {
            quotes = Quote.samples
            saveQuotes()
            return
        }

        do {
            let data = try Data(contentsOf: quotesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            quotes = try decoder.decode([Quote].self, from: data)
        } catch {
            print("Error loading quotes: \(error)")
            quotes = Quote.samples
        }
    }

    func saveQuotes() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(quotes)
            try data.write(to: quotesFileURL)
        } catch {
            print("Error saving quotes: \(error)")
        }
    }

    private func loadSettings() {
        guard fileManager.fileExists(atPath: settingsFileURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: settingsFileURL)
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            refreshInterval = settings.refreshInterval
        } catch {
            print("Error loading settings: \(error)")
        }
    }

    func saveSettings() {
        do {
            let settings = Settings(refreshInterval: refreshInterval)
            let data = try JSONEncoder().encode(settings)
            try data.write(to: settingsFileURL)
        } catch {
            print("Error saving settings: \(error)")
        }
    }

    func addQuote(_ quote: Quote) {
        quotes.append(quote)
        saveQuotes()
    }

    func updateQuote(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote
            saveQuotes()
        }
    }

    func deleteQuote(_ quote: Quote) {
        quotes.removeAll { $0.id == quote.id }
        saveQuotes()
    }

    func deleteQuotes(at offsets: IndexSet) {
        quotes.remove(atOffsets: offsets)
        saveQuotes()
    }

    func toggleFavorite(_ quote: Quote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveQuotes()
        }
    }

    func randomQuote() -> Quote? {
        quotes.randomElement()
    }

    func randomQuote(favoritesOnly: Bool) -> Quote? {
        if favoritesOnly {
            return quotes.filter { $0.isFavorite }.randomElement()
        }
        return quotes.randomElement()
    }

    private struct Settings: Codable {
        let refreshInterval: RefreshInterval
    }
}

class QuoteStoreReader {
    private let fileManager = FileManager.default
    private let appGroupIdentifier = "group.com.valivishy.BookQuotes"

    private var quotesFileURL: URL {
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL.appendingPathComponent("quotes.json")
        }

        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("BookQuotes/quotes.json")
    }

    private var settingsFileURL: URL {
        if let containerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return containerURL.appendingPathComponent("settings.json")
        }

        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("BookQuotes/settings.json")
    }

    func loadQuotes() -> [Quote] {
        guard fileManager.fileExists(atPath: quotesFileURL.path) else {
            return Quote.samples
        }

        do {
            let data = try Data(contentsOf: quotesFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Quote].self, from: data)
        } catch {
            print("Error loading quotes: \(error)")
            return Quote.samples
        }
    }

    func loadRefreshInterval() -> RefreshInterval {
        guard fileManager.fileExists(atPath: settingsFileURL.path) else {
            return .oneHour
        }

        do {
            let data = try Data(contentsOf: settingsFileURL)
            let settings = try JSONDecoder().decode(Settings.self, from: data)
            return settings.refreshInterval
        } catch {
            return .oneHour
        }
    }

    func randomQuote() -> Quote {
        let quotes = loadQuotes()
        return quotes.randomElement() ?? Quote.samples[0]
    }

    private struct Settings: Codable {
        let refreshInterval: RefreshInterval
    }
}
