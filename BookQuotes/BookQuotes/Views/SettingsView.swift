import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject var quoteStore: QuoteStore

    var body: some View {
        Form {
            Section {
                Picker("Refresh Interval", selection: $quoteStore.refreshInterval) {
                    ForEach(RefreshInterval.allCases, id: \.self) { interval in
                        Text(interval.displayName).tag(interval)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: quoteStore.refreshInterval) { _, _ in
                    quoteStore.saveSettings()
                    WidgetCenter.shared.reloadAllTimelines()
                }

                Text("The widget will show a new random quote at this interval.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Widget")
            }

            Section {
                Button("Refresh Widget Now") {
                    WidgetCenter.shared.reloadAllTimelines()
                }

                Text("Forces the widget to display a new quote immediately.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                LabeledContent("Total Quotes", value: "\(quoteStore.quotes.count)")
                LabeledContent("Favorites", value: "\(quoteStore.quotes.filter { $0.isFavorite }.count)")
            } header: {
                Text("Statistics")
            }

            Section {
                Button("Reset to Sample Quotes") {
                    resetToSamples()
                }
                .foregroundStyle(.red)

                Text("This will replace all quotes with the default sample quotes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Data")
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 350)
    }

    private func resetToSamples() {
        quoteStore.quotes = Quote.samples
        quoteStore.saveQuotes()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    SettingsView()
        .environmentObject(QuoteStore())
}
