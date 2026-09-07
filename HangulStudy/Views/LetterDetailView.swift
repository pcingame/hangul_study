import SwiftUI

struct LetterDetailView: View {
    let letter: HangulLetter
    let language: AppLanguage

    @Environment(\.dismiss) private var dismiss

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
}

#Preview {
    LetterDetailView(letter: HangulData.basicConsonants[0], language: .vi)
}
