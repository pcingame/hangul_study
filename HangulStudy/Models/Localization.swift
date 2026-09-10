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
    static let resetProgressConfirmTitle = Bilingual(vi: "Xóa toàn bộ tiến độ?", en: "Reset all progress?")
    static let resetProgressConfirmMessage = Bilingual(
        vi: "Thao tác này sẽ xóa tiến độ học của tất cả các chữ và không thể hoàn tác.",
        en: "This clears your learning progress for every letter and cannot be undone."
    )
    static let cancel = Bilingual(vi: "Hủy", en: "Cancel")
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

    // Lọc bảng chữ cái
    static let learnFilterAll = Bilingual(vi: "Tất cả", en: "All")
    static let learnFilterRemaining = Bilingual(vi: "Chưa thuộc", en: "Not learned")
    static let learnAllLearned = Bilingual(vi: "Bạn đã thuộc hết bảng chữ cái! 🎉",
                                           en: "You've learned every letter! 🎉")

    // Quiz
    static let quizReviewMissed = Bilingual(vi: "Cần ôn lại", en: "Review these")
    static let quizPerfect = Bilingual(vi: "Tuyệt vời — đúng tất cả!", en: "Perfect — every answer correct!")
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
    static let tapToReplay = Bilingual(vi: "Chạm để xem lại", en: "Tap to replay")
    static let checkWriting = Bilingual(vi: "Chấm điểm", en: "Check")
    static let writingScoreGreat = Bilingual(vi: "Rất tốt! 🎉", en: "Great job! 🎉")
    static let writingScoreOk = Bilingual(vi: "Khá ổn, viết lại cho quen nét nhé", en: "Not bad — trace it again to get the strokes smoother")
    static let writingScoreLow = Bilingual(vi: "Chưa khớp lắm, thử theo đúng nét mẫu nhé", en: "Doesn't match yet — try to follow the guide's strokes")
    static let writingScoreEmpty = Bilingual(vi: "Viết chữ vào ô trước đã nhé", en: "Write the letter in the box first")

    // Tham khảo (quy tắc phát âm, số đếm)
    static let referenceTab = Bilingual(vi: "Tham khảo", en: "Reference")
    static let referenceTitle = Bilingual(vi: "Tham khảo thêm", en: "More to learn")
    static let pronunciationRulesTitle = Bilingual(vi: "Quy tắc phát âm", en: "Pronunciation rules")
    static let pronunciationRulesSubtitle = Bilingual(vi: "Phụ âm cuối & nối âm", en: "Batchim & liaison")
    static let numbersTitle = Bilingual(vi: "Số đếm", en: "Numbers")
    static let numbersSubtitle = Bilingual(vi: "Hán-Hàn & thuần Hàn", en: "Sino-Korean & native")

    static let batchimSectionTitle = Bilingual(vi: "Quy tắc âm cuối (받침)", en: "Final-consonant rule (받침)")
    static let batchimSectionBody = Bilingual(
        vi: "28 phụ âm cuối chỉ đọc thành 7 âm đại diện — chạm một nhóm để nghe âm đó.",
        en: "All 28 possible final consonants collapse into just 7 sounds — tap a group to hear it."
    )
    static let liaisonSectionTitle = Bilingual(vi: "Nối âm (연음)", en: "Liaison (연음)")
    static let liaisonSectionBody = Bilingual(
        vi: "Khi âm tiết sau bắt đầu bằng ㅇ, phụ âm cuối của âm tiết trước nối sang làm phụ âm đầu.",
        en: "When the next syllable starts with ㅇ, the previous syllable's final consonant carries over as its initial sound."
    )

    static let numbersSino = Bilingual(vi: "Hán-Hàn", en: "Sino-Korean")
    static let numbersNative = Bilingual(vi: "Thuần Hàn", en: "Native Korean")
    static let numbersSinoHint = Bilingual(vi: "đếm số, tiền, ngày, số điện thoại", en: "counting, money, dates, phone numbers")
    static let numbersNativeHint = Bilingual(vi: "đếm đồ vật, tuổi (chỉ tới 99)", en: "counting objects, age (up to 99 only)")

    // Kiểm tra kiểu gõ đáp án
    static let quizModeType = Bilingual(vi: "Gõ đáp án", en: "Type answer")
    static let quizTypePrompt = Bilingual(vi: "Chữ này đọc là gì? Gõ cách đọc:", en: "How is this letter read? Type it:")
    static let quizTypePlaceholder = Bilingual(vi: "cách đọc...", en: "romanization...")
    static let checkAnswer = Bilingual(vi: "Kiểm tra", en: "Check")
}
