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
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        // Đặt lại category mỗi lần đọc (không chỉ lúc khởi tạo): `PronunciationService` đổi session
        // sang `.record` khi ghi âm chấm điểm phát âm — category đó không có đường ra loa, nên nếu
        // không tự đặt lại ở đây, các lần đọc sau khi ghi âm xong sẽ bị im lặng.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
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
