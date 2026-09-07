import SwiftUI

struct SyllableBuilderView: View {
    let language: AppLanguage

    @State private var initial = 0
    @State private var medial = 0
    @State private var final = 0 // 0 = không có batchim

    private var syllable: String {
        HangulSyllable.compose(initial: initial, medial: medial, final: final)
    }

    private var components: String {
        var parts = [HangulSyllable.initials[initial], HangulSyllable.medials[medial]]
        if final > 0 { parts.append(HangulSyllable.finals[final]) }
        return parts.joined(separator: " + ")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(syllable)
                        .font(.system(size: 150, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))

                    Text(components)
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Button {
                        SpeechService.shared.speak(syllable)
                    } label: {
                        Label(L.listenSyllable(language), systemImage: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    jamoRow(title: L.buildInitial(language), items: HangulSyllable.initials, selection: $initial)
                    jamoRow(title: L.buildMedial(language), items: HangulSyllable.medials, selection: $medial)
                    jamoRow(title: L.buildFinal(language),
                            items: [L.buildNoFinal(language)] + HangulSyllable.finals.dropFirst(),
                            selection: $final)
                }
                .padding()
            }
            .navigationTitle(L.buildTitle(language))
        }
    }

    private func jamoRow(title: String, items: [String], selection: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items.indices, id: \.self) { index in
                        Button {
                            selection.wrappedValue = index
                        } label: {
                            Text(items[index])
                                .font(.title3)
                                .frame(minWidth: 44, minHeight: 44)
                                .padding(.horizontal, 4)
                                .background(
                                    selection.wrappedValue == index ? Color.accentColor : Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 10)
                                )
                                .foregroundStyle(selection.wrappedValue == index ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

#Preview {
    SyllableBuilderView(language: .vi)
}
