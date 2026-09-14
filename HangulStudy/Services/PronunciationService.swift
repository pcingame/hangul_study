import AVFoundation
import Speech

/// Ghi âm và nhận diện giọng nói tiếng Hàn để chấm điểm phát âm. Luôn bắt buộc nhận diện
/// hoàn toàn trên máy (`requiresOnDeviceRecognition`) — không gửi giọng nói lên máy chủ.
/// Tự động dừng ghi âm khi im lặng một lúc, tương tự cách các app ghi âm giọng nói thường làm.
@MainActor
final class PronunciationService: NSObject, ObservableObject {
    static let shared = PronunciationService()

    enum AuthorizationStatus {
        case notDetermined, authorized, denied
    }

    /// Mức âm lượng (0…1, đã khuếch đại) được coi là "đang nói" — dưới ngưỡng này tính là im lặng.
    private static let speechLevelThreshold: Float = 0.08
    /// Im lặng liên tục từ sau khi đã nghe thấy tiếng nói bằng ngần này thì tự động dừng ghi âm.
    private static let autoStopSilenceDuration: TimeInterval = 1.2
    /// Giới hạn an toàn: dù vẫn đang nói cũng tự dừng sau ngần này, tránh ghi âm vô hạn.
    private static let maximumRecordingDuration: TimeInterval = 8

    @Published private(set) var isRecording = false
    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    /// Mức âm lượng đang ghi, 0…1 — dùng để vẽ thanh mức âm lượng trên UI khi ghi âm.
    @Published private(set) var audioLevel: Float = 0

    /// Máy có hỗ trợ nhận diện tiếng Hàn hoàn toàn trên thiết bị hay không (cần gói ngôn ngữ đã tải,
    /// giống yêu cầu giọng đọc TTS của `SpeechService`).
    let isOnDeviceRecognitionAvailable: Bool

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizedText = ""
    private var recordingStartedAt: Date?
    private var lastLoudAt: Date?
    private var hasDetectedSpeech = false
    /// Gọi khi bộ tự-dừng-khi-im-lặng dừng ghi âm thay vì người dùng tự bấm dừng, kèm văn bản
    /// nhận diện được — để UI vẫn chấm điểm/hiển thị kết quả như khi bấm dừng thủ công.
    private var onAutoStop: ((String) -> Void)?

    private override init() {
        isOnDeviceRecognitionAvailable = recognizer?.supportsOnDeviceRecognition ?? false
        super.init()
    }

    /// Xin quyền micro + nhận diện giọng nói (chỉ hỏi lần đầu, hệ thống tự nhớ lựa chọn sau đó).
    func requestAuthorization() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else {
            authorizationStatus = .denied
            return false
        }
        let micGranted = await AVAudioApplication.requestRecordPermission()
        authorizationStatus = micGranted ? .authorized : .denied
        return micGranted
    }

    /// Bắt đầu ghi âm + nhận diện trực tiếp; tự động dừng sau khoảng lặng hoặc quá thời lượng tối đa.
    /// - Parameter onAutoStop: gọi (kèm văn bản nhận diện được) nếu ghi âm tự dừng — không gọi nếu
    ///   người dùng tự bấm dừng bằng `stopRecording()`.
    func startRecording(onAutoStop: ((String) -> Void)? = nil) {
        guard !isRecording, let recognizer, recognizer.isAvailable else { return }

        task?.cancel()
        task = nil
        recognizedText = ""
        hasDetectedSpeech = false
        lastLoudAt = nil
        recordingStartedAt = Date()
        self.onAutoStop = onAutoStop

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.requiresOnDeviceRecognition = isOnDeviceRecognitionAvailable
        // Câu/từ ngắn, rời rạc (tên chữ cái, từ đơn) thay vì văn bản tự do dài — giúp nhận diện
        // chính xác hơn cho đúng kiểu nội dung app này cần.
        request.taskHint = .confirmation
        self.request = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.request?.append(buffer)
            let level = Self.level(from: buffer)
            Task { @MainActor [weak self] in
                self?.handle(level: level)
            }
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            inputNode.removeTap(onBus: 0)
            self.request = nil
            return
        }

        isRecording = true
        task = recognizer.recognitionTask(with: request) { [weak self] result, _ in
            guard let self, let result else { return }
            self.recognizedText = result.bestTranscription.formattedString
        }
    }

    /// Dừng ghi âm, trả về văn bản nhận diện được (tích luỹ từ kết quả tạm thời tốt nhất).
    @discardableResult
    func stopRecording() -> String {
        guard isRecording else { return recognizedText }
        isRecording = false
        audioLevel = 0
        onAutoStop = nil

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        request = nil
        task?.cancel()
        task = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        return recognizedText
    }

    /// Cập nhật mức âm lượng cho UI và kiểm tra điều kiện tự dừng — chạy trên main actor mỗi lần
    /// có buffer âm thanh mới (buffer tap chạy trên luồng âm thanh riêng, không phải main thread).
    private func handle(level: Float) {
        guard isRecording else { return }
        audioLevel = level

        let now = Date()
        if level >= Self.speechLevelThreshold {
            hasDetectedSpeech = true
            lastLoudAt = now
        }

        if hasDetectedSpeech, let lastLoudAt, now.timeIntervalSince(lastLoudAt) >= Self.autoStopSilenceDuration {
            autoStop()
            return
        }
        if let recordingStartedAt, now.timeIntervalSince(recordingStartedAt) >= Self.maximumRecordingDuration {
            autoStop()
        }
    }

    private func autoStop() {
        let handler = onAutoStop
        let text = stopRecording()
        handler?(text)
    }

    /// Biên độ trung bình (RMS) của buffer, chuẩn hoá về 0…1 và khuếch đại nhẹ để mức nói chuyện
    /// bình thường cũng lên được mức nhìn thấy rõ trên thanh mức âm lượng.
    private static func level(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0 }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        let samples = channelData[0]
        var sumOfSquares: Float = 0
        for i in 0..<frameLength {
            let sample = samples[i]
            sumOfSquares += sample * sample
        }
        let rms = sqrt(sumOfSquares / Float(frameLength))
        return min(1, rms * 6)
    }
}
