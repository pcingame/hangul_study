import AVFoundation

/// Âm báo đúng / sai cho quiz. Tổng hợp sẵn vài nốt sine ngắn nên không cần file âm thanh.
final class SoundEffects {
    static let shared = SoundEffects()

    private let correctPlayer: AVAudioPlayer?
    private let wrongPlayer: AVAudioPlayer?
    private let completePlayer: AVAudioPlayer?

    private enum Waveform { case sine, square }

    private init() {
        // Đúng: hai nốt đi lên, nghe tươi.
        correctPlayer = Self.makePlayer(
            notes: [(784, 0.09), (1046, 0.16)], waveform: .sine, volume: 0.35
        )
        // Sai: hai nốt đi xuống, trầm.
        wrongPlayer = Self.makePlayer(
            notes: [(220, 0.12), (165, 0.22)], waveform: .square, volume: 0.28
        )
        // Hoàn thành: hợp âm rải đi lên, nốt cuối ngân dài.
        completePlayer = Self.makePlayer(
            notes: [(659, 0.10), (784, 0.10), (988, 0.10), (1319, 0.34)], waveform: .sine, volume: 0.32
        )
    }

    /// Cả ba âm đã tổng hợp và nạp thành công.
    var isReady: Bool { correctPlayer != nil && wrongPlayer != nil && completePlayer != nil }

    /// Độ dài từng âm (giây) — dùng để kiểm thử.
    var durations: (correct: TimeInterval, wrong: TimeInterval, complete: TimeInterval) {
        (correctPlayer?.duration ?? 0, wrongPlayer?.duration ?? 0, completePlayer?.duration ?? 0)
    }

    func playCorrect() { play(correctPlayer) }
    func playWrong() { play(wrongPlayer) }
    func playComplete() { play(completePlayer) }

    private func play(_ player: AVAudioPlayer?) {
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.currentTime = 0
        player?.play()
    }

    private static func makePlayer(notes: [(frequency: Double, duration: Double)],
                                   waveform: Waveform,
                                   volume: Float) -> AVAudioPlayer? {
        let sampleRate = 44_100.0
        var samples: [Int16] = []

        for note in notes {
            let frameCount = Int(sampleRate * note.duration)
            guard frameCount > 0 else { continue }
            for frame in 0..<frameCount {
                let time = Double(frame) / sampleRate
                let progress = Double(frame) / Double(frameCount)
                // Vào nhanh, tắt dần để không bị "tách".
                let envelope = min(1, progress * 12) * min(1, (1 - progress) * 5)

                var wave = sin(2 * .pi * note.frequency * time)
                if waveform == .square { wave = wave >= 0 ? 1 : -1 }

                let value = wave * envelope * 0.85
                samples.append(Int16(value * Double(Int16.max)))
            }
        }

        guard let data = wav(samples: samples, sampleRate: Int(sampleRate)),
              let player = try? AVAudioPlayer(data: data) else { return nil }
        player.volume = volume
        player.prepareToPlay()
        return player
    }

    /// Gói mẫu PCM 16-bit mono thành một file WAV trong bộ nhớ.
    private static func wav(samples: [Int16], sampleRate: Int) -> Data? {
        var data = Data()
        let dataSize = samples.count * 2

        func append<T: FixedWidthInteger>(_ value: T) {
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
        }
        func append(_ text: String) {
            data.append(contentsOf: Array(text.utf8))
        }

        append("RIFF")
        append(UInt32(36 + dataSize))
        append("WAVE")
        append("fmt ")
        append(UInt32(16))                 // kích thước chunk fmt
        append(UInt16(1))                  // PCM
        append(UInt16(1))                  // mono
        append(UInt32(sampleRate))
        append(UInt32(sampleRate * 2))     // byte rate
        append(UInt16(2))                  // block align
        append(UInt16(16))                 // bits / sample
        append("data")
        append(UInt32(dataSize))
        for sample in samples { append(sample) }

        return data
    }
}
