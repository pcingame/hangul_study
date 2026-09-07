import CoreGraphics
import Testing
@testable import HangulStudy

struct HangulStrokesTests {

    private let basicConsonants = HangulData.basicConsonants.map(\.character)
    private let basicVowels = HangulData.basicVowels.map(\.character)
    private var basics: [String] { basicConsonants + basicVowels }

    // MARK: Phủ

    @Test func everyBasicLetterHasStrokeData() {
        for character in basics {
            #expect(HangulStrokes.strokes(for: character) != nil, "thiếu nét cho \(character)")
        }
    }

    @Test func onlyBasicLettersHaveData() {
        for character in (HangulData.doubleConsonants + HangulData.compoundVowels).map(\.character) {
            #expect(HangulStrokes.strokes(for: character) == nil, "\(character) không nên có dữ liệu tay")
        }
    }

    @Test func unknownInputReturnsNil() {
        #expect(HangulStrokes.strokes(for: "") == nil)
        #expect(HangulStrokes.strokes(for: "A") == nil)
        #expect(HangulStrokes.strokes(for: "가") == nil) // âm tiết, không phải jamo
    }

    // MARK: Hình học

    @Test func allPointsStayInsideTheUnitBox() {
        for character in basics {
            for stroke in HangulStrokes.strokes(for: character)! {
                for point in stroke {
                    #expect((0...1).contains(point.x), "\(character): x=\(point.x)")
                    #expect((0...1).contains(point.y), "\(character): y=\(point.y)")
                }
            }
        }
    }

    @Test func everyStrokeHasAtLeastTwoPointsAndSomeLength() {
        for character in basics {
            for stroke in HangulStrokes.strokes(for: character)! {
                #expect(stroke.count >= 2)
                let dx = stroke.last!.x - stroke.first!.x
                let dy = stroke.last!.y - stroke.first!.y
                let closed = hypot(dx, dy) < 0.001
                // Nét kín (vòng tròn) phải có nhiều điểm; nét hở phải có độ dài.
                #expect(closed ? stroke.count > 8 : hypot(dx, dy) > 0.05, "\(character) có nét suy biến")
            }
        }
    }

    @Test func strokeUsesTheWholeBoxRoughly() {
        for character in basics {
            let points = HangulStrokes.strokes(for: character)!.flatMap { $0 }
            let width = points.map(\.x).max()! - points.map(\.x).min()!
            let height = points.map(\.y).max()! - points.map(\.y).min()!
            // Ít nhất một chiều phải trải rộng đáng kể.
            #expect(max(width, height) > 0.5, "\(character) quá nhỏ")
        }
    }

    // MARK: Số nét (chốt hồi quy)

    @Test func strokeCountsMatchHandwriting() {
        let expected: [String: Int] = [
            "ㄱ": 1, "ㄴ": 1, "ㄷ": 2, "ㄹ": 3, "ㅁ": 3, "ㅂ": 4, "ㅅ": 2,
            "ㅇ": 1, "ㅈ": 3, "ㅊ": 4, "ㅋ": 2, "ㅌ": 3, "ㅍ": 4, "ㅎ": 3,
            "ㅏ": 2, "ㅑ": 3, "ㅓ": 2, "ㅕ": 3, "ㅗ": 2, "ㅛ": 3,
            "ㅜ": 2, "ㅠ": 3, "ㅡ": 1, "ㅣ": 1,
        ]
        for (character, count) in expected {
            #expect(HangulStrokes.strokes(for: character)?.count == count, "\(character) sai số nét")
        }
    }

    @Test func circleLettersHaveASingleManyPointStroke() {
        for character in ["ㅇ"] {
            let strokes = HangulStrokes.strokes(for: character)!
            #expect(strokes.count == 1)
            #expect(strokes[0].count > 20)
        }
        // ㅎ: nét cuối là vòng tròn.
        #expect(HangulStrokes.strokes(for: "ㅎ")!.last!.count > 20)
    }
}
