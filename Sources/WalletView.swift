import SwiftUI
import SwiftData

struct WalletView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \MoneyEntry.date, order: .reverse) private var items: [MoneyEntry]
    @AppStorage("startBalance") private var startBalance = 0.0
    @State private var showAdd = false
    @State private var editBalance = false
    @State private var balanceText = ""

    private var balance: Double {
        startBalance + items.reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
    }
    private var monthExpenses: [MoneyEntry] {
        items.filter { !$0.isIncome && Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }
    }
    private var byCategory: [(SpendCategory, Double)] {
        Dictionary(grouping: monthExpenses, by: \.category)
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Баланс").font(.caption).foregroundStyle(.secondary)
                        Text(balance.money).font(.largeTitle.bold()).foregroundStyle(balance < 0 ? .red : .primary)
                        Text("Потрачено в этом месяце: \(monthExpenses.reduce(0) { $0 + $1.amount }.money)")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Button("Указать начальный баланс") {
                        balanceText = String(startBalance); editBalance = true
                    }.font(.footnote)
                }

                if !byCategory.isEmpty {
                    Section("Категории за месяц") {
                        ForEach(byCategory, id: \.0) { cat, sum in
                            HStack {
                                Label(cat.rawValue, systemImage: cat.icon)
                                Spacer()
                                Text(sum.money).foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Операции") {
                    ForEach(items) { e in
                        HStack {
                            Image(systemName: e.category.icon).frame(width: 28)
                            VStack(alignment: .leading) {
                                Text(e.note.isEmpty ? e.category.rawValue : e.note)
                                Text(e.date, style: .date).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text((e.isIncome ? "+" : "−") + e.amount.money)
                                .foregroundStyle(e.isIncome ? .green : .primary)
                        }
                    }
                    .onDelete { $0.forEach { ctx.delete(items[$0]) } }
                }
            }
            .navigationTitle("Spendly")
            .toolbar {
                Button { showAdd = true } label: { Image(systemName: "plus") }
            }
            .sheet(isPresented: $showAdd) { AddEntryView() }
            .alert("Начальный баланс", isPresented: $editBalance) {
                TextField("0", text: $balanceText).keyboardType(.decimalPad)
                Button("Сохранить") { startBalance = Parser.number(balanceText) ?? startBalance }
                Button("Отмена", role: .cancel) {}
            }
        }
    }
}
