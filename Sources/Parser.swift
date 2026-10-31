import UIKit
import Vision

enum Parser {
    static func number(_ s: String) -> Double? {
        Double(s.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: ""))
    }

    static func amounts(in text: String, decimalOnly: Bool = false) -> [Double] {
        let cleaned = text.replacingOccurrences(of: ",", with: ".")
        let pattern = decimalOnly ? #"\d+\.\d{2}\b"# : #"\d+(?:\.\d{1,2})?"#
        guard let re = try? NSRegularExpression(pattern: pattern) else { return [] }
        return re.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned)).compactMap {
            Range($0.range, in: cleaned).flatMap { Double(cleaned[$0]) }
        }
    }

    static func category(for text: String) -> SpendCategory {
        let t = text.lowercased()
        return SpendCategory.allCases.first { c in c.keywords.contains { t.contains($0) } } ?? .other
    }

    static func looksLikeIncome(_ text: String) -> Bool {
        let t = text.lowercased()
        return ["получил", "зарплат", "стипенди", "перевод от", "доход", "salary", "income", "received"].contains { t.contains($0) }
    }

    /// Распознаёт чек: сумма (по строке «итого/total»), категория, название магазина.
    static func scanReceipt(_ image: UIImage) async -> (amount: Double?, category: SpendCategory, merchant: String) {
        let lines = await recognizeLines(image)
        let totalWords = ["итого", "итог", "к оплате", "total", "celkem", "k úhradě", "suma", "amount due"]
        var total: Double?
        for (i, line) in lines.enumerated() {
            let l = line.lowercased()
            guard totalWords.contains(where: { l.contains($0) }) else { continue }
            let next = i + 1 < lines.count ? lines[i + 1] : ""
            if let n = (amounts(in: line, decimalOnly: true) + amounts(in: next, decimalOnly: true)).first { total = n }
        }
        let amount = total ?? lines.flatMap { amounts(in: $0, decimalOnly: true) }.max()
        let merchant = lines.first { $0.count > 2 && !$0.allSatisfy { $0.isNumber } } ?? ""
        return (amount, category(for: lines.joined(separator: " ")), merchant)
    }

    private static func recognizeLines(_ image: UIImage) async -> [String] {
        await Task.detached { () -> [String] in
            let fmt = UIGraphicsImageRendererFormat()
            fmt.scale = 1
            let upright = UIGraphicsImageRenderer(size: image.size, format: fmt).image { _ in image.draw(at: .zero) }
            guard let cg = upright.cgImage else { return [] }
            let req = VNRecognizeTextRequest()
            req.recognitionLevel = .accurate
            req.automaticallyDetectsLanguage = true
            try? VNImageRequestHandler(cgImage: cg).perform([req])
            return (req.results ?? []).compactMap { $0.topCandidates(1).first?.string }
        }.value
    }
}
