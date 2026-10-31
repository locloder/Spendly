import SwiftUI
import SwiftData
import PhotosUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var category: SpendCategory = .other
    @State private var note = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var photo: PhotosPickerItem?
    @State private var scanning = false
    @StateObject private var speech = SpeechRecognizer()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Button { speech.toggle() } label: {
                            Label(speech.isRecording ? "Стоп" : "Голосом",
                                  systemImage: speech.isRecording ? "stop.circle.fill" : "mic.fill")
                        }
                        Spacer()
                        PhotosPicker(selection: $photo, matching: .images) {
                            Label("Чек", systemImage: "doc.text.viewfinder")
                        }
                    }
                    .buttonStyle(.borderless)
                    if !speech.transcript.isEmpty {
                        Text("«\(speech.transcript)»").foregroundStyle(.secondary)
                    }
                    if scanning { ProgressView("Читаю чек…") }
                } footer: {
                    Text("Скажите, например: «кофе 150» или «стипендия 5000».")
                }

                Section {
                    Picker("Тип", selection: $isIncome) {
                        Text("Расход").tag(false)
                        Text("Доход").tag(true)
                    }.pickerStyle(.segmented)
                    TextField("Сумма", text: $amountText).keyboardType(.decimalPad)
                    Picker("Категория", selection: $category) {
                        ForEach(SpendCategory.allCases) { Label($0.rawValue, systemImage: $0.icon).tag($0) }
                    }
                    TextField("Заметка", text: $note)
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Новая операция")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Сохранить", action: save) }
            }
            .onChange(of: speech.transcript) { _, text in applyVoice(text) }
            .onChange(of: photo) { _, item in Task { await scan(item) } }
        }
    }

    private func applyVoice(_ text: String) {
        guard !text.isEmpty else { return }
        if let a = Parser.amounts(in: text).first { amountText = String(a) }
        category = Parser.category(for: text)
        isIncome = Parser.looksLikeIncome(text)
        note = text
    }

    private func scan(_ item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let img = UIImage(data: data) else { return }
        scanning = true
        let r = await Parser.scanReceipt(img)
        scanning = false
        photo = nil
        isIncome = false
        if let a = r.amount { amountText = String(format: "%.2f", a) }
        category = r.category
        note = r.merchant
    }

    private func save() {
        guard let a = Parser.number(amountText), a > 0 else { return }
        ctx.insert(MoneyEntry(amount: a, isIncome: isIncome, category: category, note: note, date: date))
        dismiss()
    }
}
