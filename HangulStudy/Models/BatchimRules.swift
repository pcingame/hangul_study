import Foundation

/// Một nhóm phụ âm cuối (받침) cùng phát âm thành một âm đại diện.
/// Dữ liệu khớp đúng 28 phụ âm cuối trong `HangulSyllable.finals` (trừ "không có").
struct BatchimGroup: Identifiable {
    let sound: String
    let members: [String]

    var id: String { sound }
}

/// Một ví dụ nối âm (연음): phụ âm cuối của âm tiết trước nối sang làm phụ âm
/// đầu của âm tiết sau khi âm tiết sau bắt đầu bằng ㅇ.
struct LiaisonExample: Identifiable {
    let written: String
    let spoken: String
    let meaning: Bilingual

    var id: String { written }
}

enum BatchimRules {
    static let groups: [BatchimGroup] = [
        BatchimGroup(sound: "ㄱ", members: ["ㄱ", "ㄲ", "ㅋ", "ㄳ", "ㄺ"]),
        BatchimGroup(sound: "ㄴ", members: ["ㄴ", "ㄵ", "ㄶ"]),
        BatchimGroup(sound: "ㄷ", members: ["ㄷ", "ㅅ", "ㅆ", "ㅈ", "ㅊ", "ㅌ", "ㅎ"]),
        BatchimGroup(sound: "ㄹ", members: ["ㄹ", "ㄼ", "ㄽ", "ㄾ", "ㅀ"]),
        BatchimGroup(sound: "ㅁ", members: ["ㅁ", "ㄻ"]),
        BatchimGroup(sound: "ㅂ", members: ["ㅂ", "ㅍ", "ㄿ", "ㅄ"]),
        BatchimGroup(sound: "ㅇ", members: ["ㅇ"]),
    ]

    static let liaisonExamples: [LiaisonExample] = [
        LiaisonExample(written: "옷이", spoken: "오시", meaning: Bilingual(vi: "áo (chủ ngữ)", en: "clothes (subject)")),
        LiaisonExample(written: "밥을", spoken: "바블", meaning: Bilingual(vi: "cơm (tân ngữ)", en: "rice (object)")),
        LiaisonExample(written: "한국어", spoken: "한구거", meaning: Bilingual(vi: "tiếng Hàn", en: "Korean language")),
        LiaisonExample(written: "꽃이", spoken: "꼬치", meaning: Bilingual(vi: "hoa (chủ ngữ)", en: "flower (subject)")),
        LiaisonExample(written: "앞에", spoken: "아페", meaning: Bilingual(vi: "phía trước", en: "in front of")),
        LiaisonExample(written: "집에", spoken: "지베", meaning: Bilingual(vi: "ở nhà", en: "at home")),
    ]
}
