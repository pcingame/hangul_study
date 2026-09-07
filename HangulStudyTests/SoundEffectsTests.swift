import Testing
@testable import HangulStudy

@MainActor
struct SoundEffectsTests {

    @Test func allThreeEffectsSynthesizeAndLoad() {
        #expect(SoundEffects.shared.isReady)
    }

    @Test func durationsRoughlyMatchTheNoteLengths() {
        let d = SoundEffects.shared.durations
        // đúng: 0.09 + 0.16 ≈ 0.25s
        #expect((0.2...0.35).contains(d.correct))
        // sai: 0.12 + 0.22 ≈ 0.34s
        #expect((0.28...0.45).contains(d.wrong))
        // hoàn thành: 0.10 + 0.10 + 0.10 + 0.34 ≈ 0.64s
        #expect((0.55...0.8).contains(d.complete))
    }

    @Test func completionEffectIsTheLongest() {
        let d = SoundEffects.shared.durations
        #expect(d.complete > d.correct)
        #expect(d.complete > d.wrong)
    }

    @Test func playingAnyEffectDoesNotCrash() {
        SoundEffects.shared.playCorrect()
        SoundEffects.shared.playWrong()
        SoundEffects.shared.playComplete()
    }
}
