import Foundation

/// Một số đếm tiếng Hàn: cách đọc Hán-Hàn (dùng đếm số, tiền, ngày...) và
/// cách đọc thuần Hàn (dùng đếm đồ vật, tuổi... tới 99; không có cho 0 và 100).
struct KoreanNumber: Identifiable {
    let value: Int
    let sino: String
    let native: String?

    var id: Int { value }
}

enum KoreanNumbers {
    static let all: [KoreanNumber] = [
        KoreanNumber(value: 0, sino: "영 / 공", native: nil),
        KoreanNumber(value: 1, sino: "일", native: "하나"),
        KoreanNumber(value: 2, sino: "이", native: "둘"),
        KoreanNumber(value: 3, sino: "삼", native: "셋"),
        KoreanNumber(value: 4, sino: "사", native: "넷"),
        KoreanNumber(value: 5, sino: "오", native: "다섯"),
        KoreanNumber(value: 6, sino: "육", native: "여섯"),
        KoreanNumber(value: 7, sino: "칠", native: "일곱"),
        KoreanNumber(value: 8, sino: "팔", native: "여덟"),
        KoreanNumber(value: 9, sino: "구", native: "아홉"),
        KoreanNumber(value: 10, sino: "십", native: "열"),
        KoreanNumber(value: 11, sino: "십일", native: "열하나"),
        KoreanNumber(value: 12, sino: "십이", native: "열둘"),
        KoreanNumber(value: 13, sino: "십삼", native: "열셋"),
        KoreanNumber(value: 14, sino: "십사", native: "열넷"),
        KoreanNumber(value: 15, sino: "십오", native: "열다섯"),
        KoreanNumber(value: 16, sino: "십육", native: "열여섯"),
        KoreanNumber(value: 17, sino: "십칠", native: "열일곱"),
        KoreanNumber(value: 18, sino: "십팔", native: "열여덟"),
        KoreanNumber(value: 19, sino: "십구", native: "열아홉"),
        KoreanNumber(value: 20, sino: "이십", native: "스물"),
        KoreanNumber(value: 30, sino: "삼십", native: "서른"),
        KoreanNumber(value: 40, sino: "사십", native: "마흔"),
        KoreanNumber(value: 50, sino: "오십", native: "쉰"),
        KoreanNumber(value: 60, sino: "육십", native: "예순"),
        KoreanNumber(value: 70, sino: "칠십", native: "일흔"),
        KoreanNumber(value: 80, sino: "팔십", native: "여든"),
        KoreanNumber(value: 90, sino: "구십", native: "아흔"),
        KoreanNumber(value: 100, sino: "백", native: nil),
    ]
}
