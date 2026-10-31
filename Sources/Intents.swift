import AppIntents
import SwiftData

extension SpendCategory: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Категория" }
    static var caseDisplayRepresentations: [SpendCategory: DisplayRepresentation] {
        Dictionary(uniqueKeysWithValues: allCases.map { c in
            (c, DisplayRepresentation(title: "\(c.rawValue)"))
        })
    }
}

struct AddExpenseIntent: AppIntent {
    static let title: LocalizedStringResource = "Добавить трату"

    @Parameter(title: "Сумма") var amount: Double
    @Parameter(title: "Категория", default: .other) var category: SpendCategory
    @Parameter(title: "Заметка") var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Потратил \(\.$amount) на \(\.$category)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let ctx = Store.container.mainContext
        ctx.insert(MoneyEntry(amount: amount, category: category, note: note ?? ""))
        try ctx.save()
        return .result(dialog: IntentDialog("Записал: \(amount.money), \(category.rawValue)"))
    }
}

struct SpendlyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddExpenseIntent(),
            phrases: [
                "Добавить трату в \(.applicationName)",
                "Записать расход в \(.applicationName)",
                "Add expense in \(.applicationName)"
            ],
            shortTitle: "Добавить трату",
            systemImageName: "plus.circle"
        )
    }
}
