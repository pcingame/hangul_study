import SwiftUI
import Translation

/// Ghi âm giọng nói tiếng Hàn, nhận diện trên máy rồi dịch ngay sang ngôn ngữ của app (Việt/Anh)
/// bằng framework Translation của Apple (iOS 18+, dịch trên máy, tự hỏi tải gói ngôn ngữ lần đầu).
@available(iOS 18.0, *)
struct SpeechTranslateView: View {
    let language: AppLanguage

    @StateObject private var speech = PronunciationService.shared
    @State private var korean = ""
    @State private var translated = ""
    @State private var failed = false
    @State private var holding = false
    @State private var config: TranslationSession.Configuration?

    var body: some View {
        VStack(spacing: 20) {
            if !speech.isOnDeviceRecognitionAvailable {
                Text(L.pronunciationOnDeviceUnavailable(language)).foregroundStyle(.secondary)
            } else if speech.authorizationStatus == .denied {
                Text(L.pronunciationPermissionDenied(language)).foregroundStyle(.secondary)
            }

            if speech.isRecording {
                AudioLevelMeter(level: speech.audioLevel)
            }

            // Giữ để ghi, thả tay để dừng & dịch (Button không bắt được lúc thả nên dùng DragGesture).
            Label(speech.isRecording ? L.releaseToTranslate(language) : L.holdToRecord(language),
                  systemImage: speech.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                .font(.title3)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(speech.isRecording ? Color.red : Color.accentColor, in: Capsule())
                .foregroundStyle(.white)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !holding else { return }
                            holding = true
                            start()
                        }
                        .onEnded { _ in
                            holding = false
                            if speech.isRecording { finish(speech.stopRecording()) }
                        }
                )

            if !korean.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L.youSaid(language)).font(.caption).foregroundStyle(.secondary)
                    Text(korean).font(.title2)
                    if !translated.isEmpty {
                        Divider()
                        Text(L.translation(language)).font(.caption).foregroundStyle(.secondary)
                        Text(translated).font(.title2)
                    } else if failed {
                        Text(L.translationFailed(language)).foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(L.speechTranslateTitle(language))
        .navigationBarTitleDisplayMode(.inline)
        .translationTask(config) { session in
            do {
                translated = try await session.translate(korean).targetText
            } catch {
                failed = true
            }
        }
        .onDisappear { speech.stopRecording() }
    }

    private func start() {
        Task {
            guard await speech.requestAuthorization(), holding else { return }
            korean = ""; translated = ""; failed = false
            speech.startRecording(maxDuration: 300, stopOnSilence: false, onAutoStop: finish)
        }
    }

    private func finish(_ text: String) {
        korean = text
        guard !text.isEmpty else { return }
        failed = false
        if config == nil {
            config = .init(source: .init(identifier: "ko"),
                           target: .init(identifier: language == .vi ? "vi" : "en"))
        } else {
            config?.invalidate()
        }
    }
}
