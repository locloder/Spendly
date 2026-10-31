import SwiftUI
import SwiftData

struct SubscriptionsView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Subscription.billingDay) private var subs: [Subscription]
    @State private var showAdd = false

    private var monthly: Double { subs.reduce(0) { $0 + $1.price } }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack { Text("В месяц"); Spacer(); Text(monthly.money).bold() }
                    HStack { Text("В год"); Spacer(); Text((monthly * 12).money).foregroundStyle(.secondary) }
                }
                Section {
                    ForEach(subs) { s in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(s.name)
                                Text("Списание \(s.billingDay)-го · напомню за \(s.remindDaysBefore) дн.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(s.price.money)
                        }
                        .swipeActions(edge: .leading) {
                            Button("Оплачено") {
                                ctx.insert(MoneyEntry(amount: s.price, category: .subscriptions, note: s.name))
                            }.tint(.green)
                        }
                    }
                    .onDelete { offsets in
                        offsets.forEach { Notifier.cancel(subs[$0]); ctx.delete(subs[$0]) }
                    }
                } footer: {
                    Text("Свайп вправо — записать списание в траты.")
                }
            }
            .navigationTitle("Подписки")
            .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
            .sheet(isPresented: $showAdd) { AddSubscriptionView() }
        }
    }
}

struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var priceText = ""
    @State private var day = 1
    @State private var remind = 1

    var body: some View {
        NavigationStack {
            Form {
                TextField("Название (Netflix, Spotify…)", text: $name)
                TextField("Цена в месяц", text: $priceText).keyboardType(.decimalPad)
                Stepper("День списания: \(day)", value: $day, in: 1...28)
                Picker("Напомнить за", selection: $remind) {
                    ForEach(0...7, id: \.self) { Text($0 == 0 ? "в день списания" : "\($0) дн.").tag($0) }
                }
            }
            .navigationTitle("Новая подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        guard !name.isEmpty, let p = Parser.number(priceText) else { return }
                        let s = Subscription(name: name, price: p, billingDay: day, remindDaysBefore: remind)
                        ctx.insert(s)
                        Notifier.requestAccess()
                        Notifier.schedule(s)
                        dismiss()
                    }
                }
            }
        }
    }
}
