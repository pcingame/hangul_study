import CoreGraphics
import Testing
@testable import HangulStudy

struct HandwritingScorerTests {

    private let referenceStroke: [[CGPoint]] = [
        [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.8, y: 0.2), CGPoint(x: 0.8, y: 0.8)],
    ]

    @Test func nilWhenReferenceIsEmpty() {
        #expect(HandwritingScorer.score(userStrokes: [[CGPoint(x: 0.5, y: 0.5)]], reference: []) == nil)
    }

    @Test func nilWhenUserHasNotWrittenAnything() {
        #expect(HandwritingScorer.score(userStrokes: [], reference: referenceStroke) == nil)
    }

    @Test func exactTraceScoresNearPerfect() {
        let score = HandwritingScorer.score(userStrokes: referenceStroke, reference: referenceStroke)
        #expect(score! >= 95)
    }

    @Test func slightOffsetStillScoresReasonablyHigh() {
        let offset = referenceStroke.map { stroke in
            stroke.map { CGPoint(x: $0.x + 0.02, y: $0.y + 0.02) }
        }
        let score = HandwritingScorer.score(userStrokes: offset, reference: referenceStroke)!
        #expect(score > 60)
        #expect(score < 100)
    }

    @Test func unrelatedScribbleScoresLow() {
        let farAway: [[CGPoint]] = [[CGPoint(x: 0.05, y: 0.95), CGPoint(x: 0.1, y: 0.9)]]
        let score = HandwritingScorer.score(userStrokes: farAway, reference: referenceStroke)!
        #expect(score < 40)
    }

    @Test func scoreIsAlwaysWithinZeroToHundred() {
        let cases: [[[CGPoint]]] = [
            referenceStroke,
            [[CGPoint(x: 0, y: 0)]],
            [[CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 0)]],
        ]
        for user in cases {
            let score = HandwritingScorer.score(userStrokes: user, reference: referenceStroke)!
            #expect((0...100).contains(score))
        }
    }

    @Test func missingAStrokeLowersCoverageScore() {
        let reference = [
            [CGPoint(x: 0.1, y: 0.1), CGPoint(x: 0.1, y: 0.9)],
            [CGPoint(x: 0.9, y: 0.1), CGPoint(x: 0.9, y: 0.9)],
        ]
        let onlyFirstStroke = [reference[0]]
        let fullScore = HandwritingScorer.score(userStrokes: reference, reference: reference)!
        let partialScore = HandwritingScorer.score(userStrokes: onlyFirstStroke, reference: reference)!
        #expect(partialScore < fullScore)
    }
}
