import CoreGraphics
import Testing
@testable import HangulStudy

struct HangulStrokesTests {
    /// 14 phụ âm + 10 nguyên âm cơ bản.
    private let basics = (HangulData.basicConsonants + HangulData.basicVowels).map(\.character)

    @Test func everyBasicLetterHasStrokeData() {
        for character in basics {
            #expect(HangulStrokes.strokes(for: character) != nil, "thiếu nét cho \(character)")
        }
    }

    @Test func strokeDataStaysInsideUnitBox() {
        for character in basics {
            for stroke in HangulStrokes.strokes(for: character) ?? [] {
                #expect(stroke.count >= 2)
                for point in stroke {
                    #expect((0...1).contains(point.x))
                    #expect((0...1).contains(point.y))
                }
            }
        }
    }

    @Test func compoundLettersFallBackToNil() {
        #expect(HangulStrokes.strokes(for: "ㅐ") == nil)
        #expect(HangulStrokes.strokes(for: "ㄲ") == nil)
    }
}
