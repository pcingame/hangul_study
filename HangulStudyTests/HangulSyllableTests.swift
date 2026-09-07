import Testing
@testable import HangulStudy

struct HangulSyllableTests {
    @Test func jamoTableSizes() {
        #expect(HangulSyllable.initials.count == 19)
        #expect(HangulSyllable.medials.count == 21)
        #expect(HangulSyllable.finals.count == 28)
        #expect(HangulSyllable.finals.first == "")
    }

    @Test func composesKnownSyllables() {
        // 가 = ㄱ(0) + ㅏ(0), không batchim
        #expect(HangulSyllable.compose(initial: 0, medial: 0, final: 0) == "가")
        // 한 = ㅎ(18) + ㅏ(0) + ㄴ(4)
        #expect(HangulSyllable.compose(initial: 18, medial: 0, final: 4) == "한")
        // 글 = ㄱ(0) + ㅡ(18) + ㄹ(8)
        #expect(HangulSyllable.compose(initial: 0, medial: 18, final: 8) == "글")
    }

    @Test func allCombinationsAreSingleHangulScalars() {
        for i in HangulSyllable.initials.indices {
            for m in HangulSyllable.medials.indices {
                let syllable = HangulSyllable.compose(initial: i, medial: m, final: 0)
                #expect(syllable.unicodeScalars.count == 1)
                let value = syllable.unicodeScalars.first!.value
                #expect((0xAC00...0xD7A3).contains(value))
            }
        }
    }
}
