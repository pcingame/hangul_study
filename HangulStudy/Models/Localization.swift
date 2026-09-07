import SwiftUI

/// Ngôn ngữ hiển thị của app / App display language.
enum AppLanguage: String, CaseIterable, Identifiable {
    case vi
    case en

    var id: String { rawValue }

    var label: String {
        switch self {
        case .vi: return "Tiếng Việt"
        case .en: return "English"
        }
    }
}

/// Giao diện sáng/tối / App appearance.
enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var label: Bilingual {
        switch self {
        case .system: return Bilingual(vi: "Theo hệ thống", en: "System")
        case .light: return Bilingual(vi: "Sáng", en: "Light")
        case .dark: return Bilingual(vi: "Tối", en: "Dark")
        }
    }
}

/// Một chuỗi song ngữ Việt / Anh.
struct Bilingual: Equatable {
    let vi: String
    let en: String

    func callAsFunction(_ language: AppLanguage) -> String {
        language == .vi ? vi : en
    }
}

/// Toàn bộ chuỗi giao diện, gom một chỗ cho dễ dịch.
enum L {
    static let learnTab = Bilingual(vi: "Học", en: "Learn")
    static let quizTab = Bilingual(vi: "Kiểm tra", en: "Quiz")
    static let writeTab = Bilingual(vi: "Luyện viết", en: "Write")
    static let settingsTab = Bilingual(vi: "Cài đặt", en: "Settings")

    static let learnTitle = Bilingual(vi: "Bảng chữ cái Hangul", en: "Hangul Alphabet")
    static let quizTitle = Bilingual(vi: "Kiểm tra", en: "Quiz")
    static let writeTitle = Bilingual(vi: "Luyện viết", en: "Writing Practice")
    static let settingsTitle = Bilingual(vi: "Cài đặt", en: "Settings")

    static let romanization = Bilingual(vi: "Cách đọc", en: "Romanization")
    static let letterName = Bilingual(vi: "Tên chữ", en: "Letter name")
    static let example = Bilingual(vi: "Ví dụ", en: "Example")
    static let listen = Bilingual(vi: "Nghe", en: "Listen")
    static let listenLetter = Bilingual(vi: "Nghe chữ cái", en: "Listen to letter")
    static let listenWord = Bilingual(vi: "Nghe từ ví dụ", en: "Listen to example")

    static let startQuiz = Bilingual(vi: "Bắt đầu", en: "Start")
    static let quizPrompt = Bilingual(vi: "Chữ này đọc là gì?", en: "How is this letter read?")
    static let nextQuestion = Bilingual(vi: "Câu tiếp theo", en: "Next question")
    static let seeResult = Bilingual(vi: "Xem kết quả", en: "See result")
    static let score = Bilingual(vi: "Điểm", en: "Score")
    static let quizDone = Bilingual(vi: "Hoàn thành!", en: "Completed!")
    static let tryAgain = Bilingual(vi: "Làm lại", en: "Try again")
    static let correct = Bilingual(vi: "Chính xác!", en: "Correct!")
    static let wrong = Bilingual(vi: "Chưa đúng", en: "Not quite")
    static let questionProgress = Bilingual(vi: "Câu", en: "Question")

    static let writeHint = Bilingual(vi: "Viết theo nét mờ bên dưới", en: "Trace over the faint guide below")
    static let clear = Bilingual(vi: "Xóa", en: "Clear")
    static let nextLetter = Bilingual(vi: "Chữ tiếp theo", en: "Next letter")
    static let showGuide = Bilingual(vi: "Hiện nét mẫu", en: "Show guide")

    static let language = Bilingual(vi: "Ngôn ngữ", en: "Language")
    static let appearance = Bilingual(vi: "Giao diện", en: "Appearance")
    static let about = Bilingual(vi: "Giới thiệu", en: "About")
    static let aboutText = Bilingual(
        vi: "App học bảng chữ cái tiếng Hàn: thẻ học, kiểm tra, luyện viết và phát âm.",
        en: "An app to learn the Korean alphabet: flashcards, quizzes, writing practice and pronunciation."
    )
    static let meaning = Bilingual(vi: "Nghĩa", en: "Meaning")
}
