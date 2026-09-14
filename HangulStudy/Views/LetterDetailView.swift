import SwiftUI

struct LetterDetailView: View {
    let letter: HangulLetter
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var pronunciation = PronunciationService.shared
    @State private var recognizedPronunciation = ""
    @State private var pronunciationResult: PronunciationCheckResult?
    @State private var pronunciationTarget: PronunciationTarget = .letterName

    private enum PronunciationCheckResult: Equatable {
        case empty
        case scored(Int)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text(letter.character)
                        .font(.system(size: 140, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)

                    Button {
                        SpeechService.shared.speak(letter)
                    } label: {
                        Label(L.listenLetter(language), systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    if !SpeechService.shared.isKoreanVoiceAvailable {
                        Text(L.koreanVoiceMissing(language))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 0) {
                        infoRow(title: L.romanization(language), value: letter.romanization)
                        Divider()
                        infoRow(title: L.letterName(language), value: letter.name)
                    }
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Label(L.pronunciationTip(language), systemImage: "lightbulb.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)

                        Text(letter.pronunciationTip(language))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 10) {
                        Label(L.pronunciationCheckTitle(language), systemImage: "mic.fill")
                            .font(.headline)

                        Picker(L.pronunciationTargetLabel(language), selection: $pronunciationTarget) {
                            ForEach(PronunciationTarget.allCases) { Text($0.label(language)).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: pronunciationTarget) { _, _ in
                            pronunciationResult = nil
                            recognizedPronunciation = ""
                        }

                        Text(pronunciationTarget.displayText(for: letter))
                            .font(.title2.weight(.medium))
                            .frame(maxWidth: .infinity, alignment: .center)

                        Button {
                            togglePronunciationRecording()
                        } label: {
                            Label(pronunciation.isRecording ? L.stopRecording(language) : L.recordPronunciation(language),
                                  systemImage: pronunciation.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(pronunciation.isRecording ? .red : .accentColor)

                        if pronunciation.isRecording {
                            AudioLevelMeter(level: pronunciation.audioLevel)
                        }

                        if let pronunciationResult {
                            pronunciationResultView(pronunciationResult)
                        }

                        if pronunciation.authorizationStatus == .denied {
                            Text(L.pronunciationPermissionDenied(language))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else if !pronunciation.isOnDeviceRecognitionAvailable {
                            Text(L.pronunciationOnDeviceUnavailable(language))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 12) {
                        Text(L.showStrokes(language))
                            .font(.headline)

                        StrokeOrderView(character: letter.character)
                            .frame(width: 180, height: 180)
                            .frame(maxWidth: .infinity)

                        Text(L.tapToReplay(language))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 12) {
                        Text(L.example(language))
                            .font(.headline)

                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(letter.exampleWord)
                                .font(.system(size: 40, weight: .medium))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(letter.exampleRomanization)
                                    .foregroundStyle(.secondary)
                                Text(letter.exampleMeaning(language))
                            }
                            Spacer()
                        }

                        Button {
                            SpeechService.shared.speak(letter.exampleWord)
                        } label: {
                            Label(L.listenWord(language), systemImage: "speaker.wave.2")
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDisappear {
                // Rời màn hình khi đang ghi âm dở (vd bấm nút X) thì phải dừng, không để mic treo.
                if pronunciation.isRecording { pronunciation.stopRecording() }
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }

    @ViewBuilder
    private func pronunciationResultView(_ result: PronunciationCheckResult) -> some View {
        switch result {
        case .empty:
            Text(L.pronunciationEmpty(language))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        case .scored(let score):
            let message: Bilingual = score >= 80 ? L.pronunciationScoreGreat : (score >= 50 ? L.pronunciationScoreOk : L.pronunciationScoreLow)
            let color: Color = score >= 80 ? .green : (score >= 50 ? .orange : .red)
            VStack(alignment: .leading, spacing: 2) {
                if !recognizedPronunciation.isEmpty {
                    Text("\(L.youSaid(language)): \(recognizedPronunciation)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(score)% — \(message(language))")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(color)
            }
        }
    }

    /// Bắt đầu/dừng ghi âm (hoặc tự dừng khi im lặng); khi dừng thì so khớp văn bản nhận diện được
    /// với nội dung đang chọn (`pronunciationTarget`) để chấm điểm.
    private func togglePronunciationRecording() {
        if pronunciation.isRecording {
            finishPronunciationRecording(pronunciation.stopRecording())
        } else {
            recognizedPronunciation = ""
            pronunciationResult = nil
            Task {
                if pronunciation.authorizationStatus != .authorized {
                    guard await pronunciation.requestAuthorization() else { return }
                }
                pronunciation.startRecording { recognized in
                    finishPronunciationRecording(recognized)
                }
            }
        }
    }

    private func finishPronunciationRecording(_ recognized: String) {
        recognizedPronunciation = recognized
        let expected = pronunciationTarget.spokenText(for: letter)
        if let score = PronunciationScorer.score(recognized: recognized, expected: expected) {
            pronunciationResult = .scored(score)
        } else {
            pronunciationResult = .empty
        }
    }
}

#Preview {
    LetterDetailView(letter: HangulData.basicConsonants[0], language: .vi)
}
