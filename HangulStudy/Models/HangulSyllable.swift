import Foundation

/// Ghép các jamo thành một khối âm tiết Hangul theo bảng mã Unicode.
///
/// Mã âm tiết = 0xAC00 + (chỉ_số_phụ_âm_đầu × 21 + chỉ_số_nguyên_âm) × 28 + chỉ_số_phụ_âm_cuối
enum HangulSyllable {
    /// 19 phụ âm đầu, đúng thứ tự Unicode.
    static let initials = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
                           "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    /// 21 nguyên âm, đúng thứ tự Unicode.
    static let medials = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ",
                          "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]

    /// 28 phụ âm cuối (batchim); phần tử đầu tiên là "không có", đúng thứ tự Unicode.
    static let finals = ["", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ",
                         "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    static func compose(initial: Int, medial: Int, final: Int) -> String {
        let code = 0xAC00 + (initial * 21 + medial) * 28 + final
        guard let scalar = UnicodeScalar(code) else { return "" }
        return String(scalar)
    }
}
