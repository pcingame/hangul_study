import Testing
@testable import HangulStudy

struct HangulSyllableTests {

    @Test func jamoTableSizes() {
        #expect(HangulSyllable.initials.count == 19)
        #expect(HangulSyllable.medials.count == 21)
        #expect(HangulSyllable.finals.count == 28)
    }

    @Test func finalsStartWithEmptyThenSingleJamo() {
        #expect(HangulSyllable.finals.first == "")
        for batchim in HangulSyllable.finals.dropFirst() {
            #expect(!batchim.isEmpty)
            #expect(batchim.unicodeScalars.count == 1)
        }
    }

    @Test func initialsAndMedialsAreDistinctSingleJamo() {
        for jamo in HangulSyllable.initials + HangulSyllable.medials {
            #expect(jamo.unicodeScalars.count == 1)
        }
        #expect(Set(HangulSyllable.initials).count == 19)
        #expect(Set(HangulSyllable.medials).count == 21)
    }

    @Test func composesKnownSyllables() {
        #expect(HangulSyllable.compose(initial: 0, medial: 0, final: 0) == "가")   // ㄱ + ㅏ
        #expect(HangulSyllable.compose(initial: 18, medial: 0, final: 4) == "한")  // ㅎ + ㅏ + ㄴ
        #expect(HangulSyllable.compose(initial: 0, medial: 18, final: 8) == "글")  // ㄱ + ㅡ + ㄹ
        #expect(HangulSyllable.compose(initial: 11, medial: 20, final: 0) == "이") // ㅇ + ㅣ
    }

    @Test func firstAndLastSyllableCoverTheHangulBlock() {
        #expect(HangulSyllable.compose(initial: 0, medial: 0, final: 0) == "\u{AC00}")
        #expect(HangulSyllable.compose(initial: 18, medial: 20, final: 27) == "\u{D7A3}")
    }

    @Test func allCombinationsAreOneSyllableInRange() {
        var seen = Set<String>()
        for i in HangulSyllable.initials.indices {
            for m in HangulSyllable.medials.indices {
                for f in HangulSyllable.finals.indices {
                    let syllable = HangulSyllable.compose(initial: i, medial: m, final: f)
                    #expect(syllable.unicodeScalars.count == 1)
                    let value = syllable.unicodeScalars.first!.value
                    #expect((0xAC00...0xD7A3).contains(value))
                    seen.insert(syllable)
                }
            }
        }
        // 19 × 21 × 28 = toàn bộ 11172 âm tiết, không trùng.
        #expect(seen.count == 19 * 21 * 28)
    }

    @Test func decomposingBackMatchesTheIndices() {
        for i in [0, 5, 18] {
            for m in [0, 10, 20] {
                for f in [0, 1, 27] {
                    let syllable = HangulSyllable.compose(initial: i, medial: m, final: f)
                    let code = Int(syllable.unicodeScalars.first!.value) - 0xAC00
                    #expect(code / 28 / 21 == i)
                    #expect(code / 28 % 21 == m)
                    #expect(code % 28 == f)
                }
            }
        }
    }
}
