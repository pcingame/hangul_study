import SwiftUI

struct PronunciationRulesView: View {
    let language: AppLanguage

    var body: some View {
        List {
            Section {
                Text(L.batchimSectionBody(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text(L.batchimSectionTitle(language))
            }

            Section {
                ForEach(BatchimRules.groups) { group in
                    BatchimGroupRow(group: group)
                }
            }

            Section {
                Text(L.liaisonSectionBody(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text(L.liaisonSectionTitle(language))
            }

            Section {
                ForEach(BatchimRules.liaisonExamples) { example in
                    LiaisonRow(example: example, language: language)
                }
            }
        }
        .navigationTitle(L.pronunciationRulesTitle(language))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BatchimGroupRow: View {
    let group: BatchimGroup

    var body: some View {
        Button {
            SpeechService.shared.speak(group.sound)
        } label: {
            HStack(spacing: 14) {
                Text(group.sound)
                    .font(.system(size: 26, weight: .medium))
                    .frame(width: 40)

                Text(group.members.joined(separator: "  "))
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "speaker.wave.2")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct LiaisonRow: View {
    let example: LiaisonExample
    let language: AppLanguage

    var body: some View {
        Button {
            SpeechService.shared.speak(example.spoken)
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(example.written)
                            .font(.system(size: 20, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("[\(example.spoken)]")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.tint)
                    }
                    Text(example.meaning(language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "speaker.wave.2")
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PronunciationRulesView(language: .vi)
    }
}
