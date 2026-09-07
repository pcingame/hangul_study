import Foundation

/// Tiến độ học của một chữ cái.
struct LetterProgress: Codable {
    /// Ô Leitner 0…5. Càng cao thì càng lâu mới phải ôn lại.
    var box: Int = 0
    var correct: Int = 0
    var wrong: Int = 0
    var lastReviewed: Date?
    var nextReview: Date?

    var isLearned: Bool { box >= 4 }
}

/// Lưu tiến độ và lên lịch ôn tập theo phương pháp lặp lại ngắt quãng (Leitner).
@MainActor
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published private(set) var entries: [String: LetterProgress] = [:]

    private let defaults: UserDefaults
    private let key = "letterProgress"

    /// Khoảng cách ôn lại theo ô, tính bằng ngày.
    private static let intervalDays: [Double] = [0, 1, 3, 7, 16, 35]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: LetterProgress].self, from: data) {
            entries = decoded
        }
    }

    func entry(for letter: HangulLetter) -> LetterProgress {
        entries[letter.character] ?? LetterProgress()
    }

    /// Ghi lại một lần trả lời trong quiz và dời lịch ôn.
    func record(_ letter: HangulLetter, correct isCorrect: Bool) {
        var entry = entries[letter.character] ?? LetterProgress()
        if isCorrect {
            entry.correct += 1
            entry.box = min(entry.box + 1, Self.intervalDays.count - 1)
        } else {
            entry.wrong += 1
            entry.box = 0
        }
        let now = Date()
        entry.lastReviewed = now
        entry.nextReview = now.addingTimeInterval(Self.intervalDays[entry.box] * 86_400)
        entries[letter.character] = entry
        save()
    }

    /// Các chữ chưa gặp hoặc đã tới hạn ôn lại.
    var dueLetters: [HangulLetter] {
        let now = Date()
        return HangulData.all.filter { letter in
            guard let next = entries[letter.character]?.nextReview else { return true }
            return next <= now
        }
    }

    var learnedCount: Int {
        entries.values.filter(\.isLearned).count
    }

    func reset() {
        entries = [:]
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: key)
        }
    }
}
