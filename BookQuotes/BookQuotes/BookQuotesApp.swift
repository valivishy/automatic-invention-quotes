import SwiftUI

@main
struct BookQuotesApp: App {
    @StateObject private var quoteStore = QuoteStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(quoteStore)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 700, height: 500)

        Settings {
            SettingsView()
                .environmentObject(quoteStore)
        }
    }
}
