import Testing
@testable import HangulStudy

@MainActor
struct StrokeSourceTests {

    @Test func basicLetterUsesHandAuthoredCenterlineData() {
        let guide = StrokeSource.guide(for: "ㅂ")
        #expect(guide.strokes.count == HangulStrokes.strokes(for: "ㅂ")!.count)
        #expect(guide.widthFraction > 0.08) // bút dày cho nét trung tâm
    }

    @Test func doubleConsonantUsesHandAuthoredCenterlineData() {
        let guide = StrokeSource.guide(for: "ㅃ")
        #expect(guide.strokes.count == HangulStrokes.strokes(for: "ㅃ")!.count)
        #expect(guide.widthFraction > 0.08) // bút dày cho nét trung tâm
    }

    @Test func compoundVowelUsesHandAuthoredCenterlineData() {
        let guide = StrokeSource.guide(for: "ㅐ")
        #expect(guide.strokes.count == HangulStrokes.strokes(for: "ㅐ")!.count)
        #expect(guide.widthFraction > 0.08) // bút dày cho nét trung tâm
    }

    /// Chữ không có trong `HangulStrokes` (âm tiết, không phải jamo rời) mới rơi vào dự phòng.
    @Test func unknownCharacterFallsBackToGlyphContours() {
        let guide = StrokeSource.guide(for: "가")
        #expect(!guide.strokes.isEmpty)
        #expect(guide.widthFraction < 0.08) // bút mảnh cho đường viền
    }

    @Test func everyLetterProducesAtLeastOneStroke() {
        for letter in HangulData.all {
            #expect(!StrokeSource.guide(for: letter.character).strokes.isEmpty, "\(letter.character) không có nét")
        }
    }

    @Test func repeatedCallsAreConsistent() {
        let first = StrokeSource.guide(for: "ㄱ")
        let second = StrokeSource.guide(for: "ㄱ")
        #expect(first.strokes.count == second.strokes.count)
        #expect(first.widthFraction == second.widthFraction)
    }
}
