import SwiftUI

struct NumbersView: View {
    let language: AppLanguage

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Label(L.numbersSino(language), systemImage: "1.circle")
                        .font(.subheadline.weight(.medium))
                    Text(L.numbersSinoHint(language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Label(L.numbersNative(language), systemImage: "2.circle")
                        .font(.subheadline.weight(.medium))
                        .padding(.top, 4)
                    Text(L.numbersNativeHint(language))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section {
                ForEach(KoreanNumbers.all) { number in
                    NumberRow(number: number)
                }
            }
        }
        .navigationTitle(L.numbersTitle(language))
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct NumberRow: View {
    let number: KoreanNumber

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number.value)")
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .leading)

            readingButton(number.sino)

            if let native = number.native {
                readingButton(native)
            } else {
                Text("—")
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func readingButton(_ reading: String) -> some View {
        Button {
            SpeechService.shared.speak(reading)
        } label: {
            HStack(spacing: 4) {
                Text(reading)
                Image(systemName: "speaker.wave.2")
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        NumbersView(language: .vi)
    }
}
