import SwiftUI

struct LearnView: View {
    let language: AppLanguage

    @State private var selectedLetter: HangulLetter?
    @ObservedObject private var progress = ProgressStore.shared

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
                                        LetterTile(letter: letter,
                                                   isLearned: progress.entry(for: letter).isLearned)
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
    let isLearned: Bool

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
        .overlay(alignment: .topTrailing) {
            if isLearned {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption2)
                    .foregroundStyle(.tint)
                    .padding(5)
            }
        }
    }
}

#Preview {
    LearnView(language: .vi)
}
