import SwiftUI
import SwiftData

@main
struct SpendlyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(Store.container)
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            WalletView().tabItem { Label("Кошелёк", systemImage: "wallet.pass") }
            SubscriptionsView().tabItem { Label("Подписки", systemImage: "arrow.triangle.2.circlepath") }
        }
    }
}
