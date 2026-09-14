import Testing
@testable import HangulStudy

struct PronunciationScorerTests {

    @Test func exactMatchScoresPerfect() {
        #expect(PronunciationScorer.score(recognized: "기역", expected: "기역") == 100)
    }

    @Test func matchIsCaseAndWhitespaceInsensitive() {
        #expect(PronunciationScorer.score(recognized: " 기역 ", expected: "기역") == 100)
        #expect(PronunciationScorer.score(recognized: "Hello", expected: "hello") == 100)
    }

    @Test func closeMatchScoresReasonablyHigh() {
        // "기역" vs "기억": chỉ sai 1 jamo (nguyên âm ㅕ→ㅓ) trong 5 jamo cấu thành 2 âm tiết,
        // nên chấm theo jamo phải khoan dung hơn nhiều so với coi cả âm tiết "억"/"역" là sai hẳn.
        let score = PronunciationScorer.score(recognized: "기억", expected: "기역")!
        #expect(score >= 70)
        #expect(score < 100)
    }

    @Test func wrongJamoWithinOneSyllableScoresHigherThanWrongWholeSyllable() {
        // So với "기역" (đúng): "기억" sai 1 jamo trong 1 âm tiết; "바나" sai hẳn cả 2 âm tiết.
        let closeScore = PronunciationScorer.score(recognized: "기억", expected: "기역")!
        let farScore = PronunciationScorer.score(recognized: "바나", expected: "기역")!
        #expect(closeScore > farScore)
    }

    @Test func unrelatedTextScoresLow() {
        let score = PronunciationScorer.score(recognized: "완전히 다른 문장입니다", expected: "기역")!
        #expect(score < 30)
    }

    @Test func nilWhenRecognizedIsEmpty() {
        #expect(PronunciationScorer.score(recognized: "", expected: "기역") == nil)
    }

    @Test func nilWhenExpectedIsEmpty() {
        #expect(PronunciationScorer.score(recognized: "기역", expected: "") == nil)
    }

    @Test func scoreIsAlwaysWithinZeroToHundred() {
        let cases = [("기역", "기역"), ("가", "하늘"), ("abc", "xyz123"), ("아", "이")]
        for (recognized, expected) in cases {
            let score = PronunciationScorer.score(recognized: recognized, expected: expected)!
            #expect((0...100).contains(score))
        }
    }
}
