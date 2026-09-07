import Foundation

enum HangulCategory: String, CaseIterable, Identifiable {
    case basicConsonant
    case basicVowel
    case doubleConsonant
    case compoundVowel

    var id: String { rawValue }

    var title: Bilingual {
        switch self {
        case .basicConsonant:
            return Bilingual(vi: "Phụ âm cơ bản", en: "Basic consonants")
        case .basicVowel:
            return Bilingual(vi: "Nguyên âm cơ bản", en: "Basic vowels")
        case .doubleConsonant:
            return Bilingual(vi: "Phụ âm đôi", en: "Double consonants")
        case .compoundVowel:
            return Bilingual(vi: "Nguyên âm ghép", en: "Compound vowels")
        }
    }
}

struct HangulLetter: Identifiable, Equatable {
    /// Ký tự Hangul, cũng dùng làm id (mỗi ký tự là duy nhất).
    let character: String
    /// Cách đọc theo hệ Latinh (Revised Romanization).
    let romanization: String
    /// Tên gọi của chữ cái trong tiếng Hàn, ví dụ "기역".
    let name: String
    let category: HangulCategory
    /// Từ ví dụ chứa chữ cái này.
    let exampleWord: String
    let exampleRomanization: String
    let exampleMeaning: Bilingual

    var id: String { character }

    /// Dạng đọc được cho bộ đọc tiếng Hàn: phần Hangul trong `name`
    /// (ví dụ "기역" cho ㄱ, "아" cho ㅏ). Đọc jamo rời trực tiếp nghe không tự nhiên.
    var spoken: String {
        String(name.prefix { $0 != " " })
    }
}
