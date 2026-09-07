import Testing
@testable import HangulStudy

struct SoundEffectsTests {
    @Test func bothEffectsSynthesizeAndLoad() {
        #expect(SoundEffects.shared.isReady)
    }

    @Test func playingDoesNotCrash() {
        SoundEffects.shared.playCorrect()
        SoundEffects.shared.playWrong()
    }
}
