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

/// Một bài của giáo trình Seoul: tiêu đề (vd "Seoul 1A · Bài 1") và các từ theo đúng thứ tự giáo trình.
struct Lesson: Codable {
    let title: String
    let words: [String]
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
    static let lessons: [Lesson] = load("lessons")

    /// Id các từ đã thuộc được lưu dạng "1,2,3" (khóa `learnedVocab` trong UserDefaults).
    static func learnedIDs(_ raw: String) -> Set<Int> { Set(raw.split(separator: ",").compactMap { Int($0) }) }
    static func learnedRaw(_ ids: Set<Int>) -> String { ids.sorted().map(String.init).joined(separator: ",") }

    private static let wordIndex = Dictionary(vocabulary.map { ($0.word, $0) }, uniquingKeysWith: { first, _ in first })

    /// Từ vựng theo bộ lọc: chọn một bài giáo trình thì lấy đủ từ của bài đó (đúng thứ tự giáo trình), không thì lọc theo unit.
    static func words(unit: Int?, lesson: String?) -> [Vocab] {
        if let lesson, let found = lessons.first(where: { $0.title == lesson }) {
            return found.words.compactMap { wordIndex[$0] }
        }
        return vocabulary.filter { unit == nil || $0.unit == unit }
    }

    /// Các bài (unit) có trong nội dung, để làm bộ lọc.
    static let units: [Int] = Set(vocabulary.compactMap(\.unit) + grammar.compactMap(\.unit)).sorted()

    /// Quiz từ vựng: hiện từ Hàn, chọn nghĩa đúng trong 4 đáp án (nhiễu lấy từ chính nhóm từ đó, thiếu thì lấy toàn bộ từ vựng).
    static func vocabQuiz(from pool: [Vocab]) -> [GrammarExercise] {
        return pool.map { word in
            let others = (pool.count >= 4 ? pool : vocabulary).map(\.meaning).filter { $0 != word.meaning }
            let options = (Array(Set(others)).shuffled().prefix(3) + [word.meaning]).shuffled()
            return GrammarExercise(sentence: word.word, vi: word.reading, options: Array(options),
                                   answer: word.meaning, note: "\(word.example)\n\(word.translation)", unit: word.unit)
        }
    }

    private static func load<T: Decodable>(_ name: String) -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return [] }
        return items
    }
}
