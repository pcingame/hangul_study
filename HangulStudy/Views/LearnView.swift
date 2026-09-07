import SwiftUI

struct LearnView: View {
    let language: AppLanguage

    @State private var selectedLetter: HangulLetter?

    private let columns = [GridItem(.adaptive(minimum: 76), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(HangulCategory.allCases) { category in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(category.title(language))
                                .font(.headline)
                                .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(HangulData.letters(in: category)) { letter in
                                    Button {
                                        selectedLetter = letter
                                    } label: {
                                        LetterTile(letter: letter)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(L.learnTitle(language))
            .sheet(item: $selectedLetter) { letter in
                LetterDetailView(letter: letter, language: language)
            }
        }
    }
}

private struct LetterTile: View {
    let letter: HangulLetter

    var body: some View {
        VStack(spacing: 4) {
            Text(letter.character)
                .font(.system(size: 34, weight: .medium))
            Text(letter.romanization)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LearnView(language: .vi)
}
