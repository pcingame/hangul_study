import Testing
@testable import HangulStudy

@MainActor
struct StrokeSourceTests {

    @Test func basicLetterUsesHandAuthoredCenterlineData() {
        let guide = StrokeSource.guide(for: "ㅂ")
        #expect(guide.strokes.count == HangulStrokes.strokes(for: "ㅂ")!.count)
        #expect(guide.widthFraction > 0.08) // bút dày cho nét trung tâm
    }

    @Test func compoundVowelFallsBackToGlyphContours() {
        let guide = StrokeSource.guide(for: "ㅐ")
        #expect(!guide.strokes.isEmpty)
        #expect(guide.widthFraction < 0.08) // bút mảnh cho đường viền
    }

    @Test func doubleConsonantFallsBackAndStillHasStrokes() {
        let guide = StrokeSource.guide(for: "ㄲ")
        #expect(!guide.strokes.isEmpty)
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
