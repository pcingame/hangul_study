import Foundation

/// So khớp văn bản nhận diện được từ giọng nói với cách đọc mong đợi, cho điểm 0…100
/// dựa trên khoảng cách chỉnh sửa (Levenshtein) chuẩn hoá theo độ dài — không dùng ML.
enum PronunciationScorer {
    /// - Parameters:
    ///   - recognized: văn bản `SFSpeechRecognizer` nhận diện được từ giọng người dùng.
    ///   - expected: cách đọc chuẩn để so khớp (ví dụ `letter.spoken`).
    /// - Returns: điểm 0…100, hoặc `nil` nếu không có gì để so (chưa ghi âm được gì).
    static func score(recognized: String, expected: String) -> Int? {
        let a = jamoScalars(normalize(recognized))
        let b = jamoScalars(normalize(expected))
        guard !a.isEmpty, !b.isEmpty else { return nil }
        if a == b { return 100 }

        let distance = levenshteinDistance(a, b)
        let similarity = 1 - Double(distance) / Double(max(a.count, b.count))
        return Int((max(similarity, 0) * 100).rounded())
    }

    private static func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .filter { !$0.isWhitespace && !$0.isPunctuation }
    }

    /// Tách mỗi khối âm tiết Hangul (vd "역") thành các jamo rời cấu thành nó (vd ㅇ, ㅕ, ㄱ) bằng
    /// phân rã Unicode NFD, rồi lấy từng jamo làm một đơn vị so sánh (`unicodeScalars`, không phải
    /// `Character`, vì Swift gộp một chuỗi jamo ghép được thành một `Character` duy nhất). Nhờ vậy
    /// sai một nguyên âm/phụ âm trong một âm tiết chỉ bị trừ điểm phần đó, không tính sai cả khối.
    private static func jamoScalars(_ text: String) -> [Unicode.Scalar] {
        Array(text.decomposedStringWithCanonicalMapping.unicodeScalars)
    }

    private static func levenshteinDistance(_ a: [Unicode.Scalar], _ b: [Unicode.Scalar]) -> Int {
        if a.isEmpty { return b.count }
        if b.isEmpty { return a.count }

        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                current[j] = a[i - 1] == b[j - 1]
                    ? previous[j - 1]
                    : 1 + min(previous[j - 1], previous[j], current[j - 1])
            }
            previous = current
        }
        return previous[b.count]
    }
}
