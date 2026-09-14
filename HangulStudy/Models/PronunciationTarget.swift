import Foundation

/// Nội dung để người dùng đọc to khi luyện/chấm điểm phát âm: tên chữ cái hoặc từ ví dụ của nó.
enum PronunciationTarget: String, CaseIterable, Identifiable {
    case letterName
    case exampleWord

    var id: String { rawValue }

    var label: Bilingual {
        switch self {
        case .letterName: return L.pronunciationTargetLetterName
        case .exampleWord: return L.pronunciationTargetExampleWord
        }
    }

    /// Văn bản đúng để so khớp với giọng nói nhận diện được.
    func spokenText(for letter: HangulLetter) -> String {
        switch self {
        case .letterName: return letter.spoken
        case .exampleWord: return letter.exampleWord
        }
    }

    /// Nội dung hiển thị lớn để người dùng biết cần đọc gì.
    func displayText(for letter: HangulLetter) -> String {
        switch self {
        case .letterName: return letter.character
        case .exampleWord: return letter.exampleWord
        }
    }
}
