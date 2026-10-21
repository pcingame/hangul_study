import Foundation

/// Nội dung giáo trình (từ vựng, ngữ pháp, bài tập) nạp từ JSON đóng gói trong app — cùng dữ liệu
/// với bản web. Nội dung giải thích chỉ có tiếng Việt.
struct Vocab: Codable, Identifiable {
    let id: Int
    let unit: Int?
    let word: String
    let reading: String
    let meaning: String
    let partOfSpeech: String
    let example: String
    let translation: String
}

struct GrammarPoint: Codable, Identifiable {
    struct Example: Codable {
        let korean: String
        let vietnamese: String
    }

    let id: Int
    let unit: Int?
    let title: String
    let explanation: String
    let examples: [Example]
}

struct GrammarExercise: Codable, Identifiable {
    let sentence: String
    let vi: String
    let options: [String]
    let answer: String
    let note: String
    let unit: Int?

    var id: String { sentence }
}

enum StudyContent {
    static let vocabulary: [Vocab] = load("vocabulary")
    static let grammar: [GrammarPoint] = load("grammar")
    static let exercises: [GrammarExercise] = load("grammar-exercises")

    /// Các bài (unit) có trong nội dung, để làm bộ lọc.
    static let units: [Int] = Set(vocabulary.compactMap(\.unit) + grammar.compactMap(\.unit)).sorted()

    private static func load<T: Decodable>(_ name: String) -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return items
    }
}
