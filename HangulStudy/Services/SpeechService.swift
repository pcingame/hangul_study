import AVFoundation

/// Phát âm tiếng Hàn bằng giọng tổng hợp có sẵn của hệ thống (ko-KR).
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    /// Máy đã cài ít nhất một giọng tiếng Hàn hay chưa. Nếu chưa, `speak` sẽ im lặng.
    let isKoreanVoiceAvailable: Bool

    private init() {
        isKoreanVoiceAvailable = AVSpeechSynthesisVoice.speechVoices()
            .contains { $0.language.hasPrefix("ko") }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        try? AVAudioSession.sharedInstance().setActive(true)

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = 0.35

        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    /// Đọc chữ cái bằng tên/âm tiết của nó thay vì jamo rời (nghe tự nhiên hơn).
    func speak(_ letter: HangulLetter) {
        speak(letter.spoken)
    }
}
