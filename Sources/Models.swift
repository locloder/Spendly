import SwiftUI
import SwiftData

let currencyCode = Locale.current.currency?.identifier ?? "USD"

extension Double {
    var money: String { formatted(.currency(code: currencyCode)) }
}

enum SpendCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Еда", transport = "Транспорт", home = "Жильё", fun = "Развлечения"
    case study = "Учёба", health = "Здоровье", shopping = "Покупки", subscriptions = "Подписки", other = "Другое"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .transport: "bus"
        case .home: "house"
        case .fun: "popcorn"
        case .study: "book"
        case .health: "cross.case"
        case .shopping: "bag"
        case .subscriptions: "arrow.triangle.2.circlepath"
        case .other: "ellipsis.circle"
        }
    }

    /// Ключевые слова для автоопределения категории (голос и чеки). Добавляйте свои магазины.
    var keywords: [String] {
        switch self {
        case .food: ["кофе", "кафе", "обед", "ужин", "завтрак", "еда", "продукт", "магазин", "пицц", "супермаркет",
                     "coffee", "lunch", "dinner", "grocer", "restaurant", "lidl", "billa", "albert", "tesco",
                     "kaufland", "mcdonald", "kfc", "starbucks", "supermarket", "penny", "žabka"]
        case .transport: ["такси", "метро", "автобус", "бензин", "проезд", "поезд", "taxi", "uber", "bolt", "bus",
                          "fuel", "train", "tram", "mhd", "benzina", "shell", "omv"]
        case .home: ["аренда", "квартира", "коммунал", "интернет", "свет", "rent", "electric", "internet", "ikea"]
        case .fun: ["кино", "игр", "бар", "клуб", "пиво", "вечеринк", "cinema", "game", "party", "bar", "concert"]
        case .study: ["книг", "курс", "учеб", "универ", "печать", "book", "course", "tuition", "print", "kniha"]
        case .health: ["аптек", "врач", "лекарств", "pharmacy", "doctor", "lékárna", "dr.max", "drmax"]
        case .shopping: ["одежд", "обув", "zara", "h&m", "amazon", "alza", "zalando", "shop", "куртк", "кроссовк"]
        case .subscriptions: ["подписк", "netflix", "spotify", "youtube", "icloud", "subscription"]
        case .other: []
        }
    }
}

@Model final class MoneyEntry {
    var amount: Double
    var isIncome: Bool
    var categoryRaw: String
    var note: String
    var date: Date

    init(amount: Double, isIncome: Bool = false, category: SpendCategory = .other, note: String = "", date: Date = .now) {
        self.amount = amount
        self.isIncome = isIncome
        self.categoryRaw = category.rawValue
        self.note = note
        self.date = date
    }

    var category: SpendCategory { SpendCategory(rawValue: categoryRaw) ?? .other }
}

@Model final class Subscription {
    var uid: String = UUID().uuidString
    var name: String
    var price: Double
    var billingDay: Int          // 1...28, ежемесячно
    var remindDaysBefore: Int    // за сколько дней напомнить

    init(name: String, price: Double, billingDay: Int, remindDaysBefore: Int) {
        self.name = name
        self.price = price
        self.billingDay = billingDay
        self.remindDaysBefore = remindDaysBefore
    }
}

/// Общий контейнер: его используют и интерфейс, и Siri-интент.
enum Store {
    @MainActor static let container: ModelContainer = {
        try! ModelContainer(for: MoneyEntry.self, Subscription.self)
    }()
}
