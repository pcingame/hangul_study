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

    // Tiến độ
    static let progress = Bilingual(vi: "Tiến độ", en: "Progress")
    static let lettersLearned = Bilingual(vi: "Chữ đã thuộc", en: "Letters learned")
    static let resetProgress = Bilingual(vi: "Xóa tiến độ", en: "Reset progress")
    static let learned = Bilingual(vi: "Đã thuộc", en: "Learned")

    // Phát âm
    static let koreanVoiceMissing = Bilingual(
        vi: "Chưa có giọng tiếng Hàn. Vào Cài đặt iOS ▸ Trợ năng ▸ Nội dung nói ▸ Giọng nói để tải.",
        en: "No Korean voice installed. Add one in iOS Settings ▸ Accessibility ▸ Spoken Content ▸ Voices."
    )

    // Onboarding
    static let onboardNext = Bilingual(vi: "Tiếp tục", en: "Next")
    static let onboardStart = Bilingual(vi: "Bắt đầu học", en: "Start learning")
    static let onboard1Title = Bilingual(vi: "Hangul là bảng chữ cái", en: "Hangul is an alphabet")
    static let onboard1Body = Bilingual(
        vi: "Không giống chữ Hán, Hangul chỉ có 24 chữ cái cơ bản. Học vài giờ là đọc được.",
        en: "Unlike Chinese characters, Hangul has just 24 basic letters. A few hours and you can read."
    )
    static let onboard2Title = Bilingual(vi: "Ghép thành khối âm tiết", en: "Letters form syllable blocks")
    static let onboard2Body = Bilingual(
        vi: "Các chữ cái xếp thành khối: ㄱ + ㅏ → 가. Mỗi khối là một âm tiết.",
        en: "Letters stack into blocks: ㄱ + ㅏ → 가. Each block is one syllable."
    )
    static let onboard3Title = Bilingual(vi: "Nghe và luyện tập", en: "Listen and practice")
    static let onboard3Body = Bilingual(
        vi: "Chạm để nghe cách đọc, làm quiz và luyện viết. Tiến độ được lưu và nhắc ôn lại.",
        en: "Tap to hear pronunciation, take quizzes, practice writing. Progress is saved and scheduled for review."
    )

    // Quiz
    static let quizModeSeeLetter = Bilingual(vi: "Nhìn chữ", en: "See letter")
    static let quizModeHearSound = Bilingual(vi: "Nghe âm", en: "Hear sound")
    static let quizScopeAll = Bilingual(vi: "Tất cả", en: "All")
    static let quizScopeDue = Bilingual(vi: "Cần ôn", en: "Due for review")
    static let quizPromptHear = Bilingual(vi: "Đây là chữ nào?", en: "Which letter is this?")
    static let quizPlaySound = Bilingual(vi: "Nghe lại", en: "Play again")
    static let quizNothingDue = Bilingual(vi: "Không có chữ nào cần ôn. Quay lại sau nhé!", en: "Nothing to review right now. Come back later!")
    static let quizScopeLabel = Bilingual(vi: "Phạm vi", en: "Scope")

    // Ghép chữ
    static let buildTab = Bilingual(vi: "Ghép chữ", en: "Build")
    static let buildTitle = Bilingual(vi: "Ghép âm tiết", en: "Build a syllable")
    static let buildInitial = Bilingual(vi: "Phụ âm đầu", en: "Initial consonant")
    static let buildMedial = Bilingual(vi: "Nguyên âm", en: "Vowel")
    static let buildFinal = Bilingual(vi: "Phụ âm cuối", en: "Final consonant")
    static let buildNoFinal = Bilingual(vi: "Không", en: "None")
    static let listenSyllable = Bilingual(vi: "Nghe âm tiết", en: "Listen to syllable")

    // Luyện viết
    static let showStrokes = Bilingual(vi: "Xem cách viết", en: "Show strokes")
}
