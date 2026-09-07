import SwiftUI

struct LearnView: View {
    let language: AppLanguage

    @State private var selectedLetter: HangulLetter?
    @State private var showRemainingOnly = false
    @ObservedObject private var progress = ProgressStore.shared

    private let columns = [GridItem(.adaptive(minimum: 76), spacing: 12)]

    private func letters(in category: HangulCategory) -> [HangulLetter] {
        HangulData.letters(in: category).filter {
            !showRemainingOnly || !progress.entry(for: $0).isLearned
        }
    }

    private var hasVisibleLetters: Bool {
        HangulCategory.allCases.contains { !letters(in: $0).isEmpty }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    progressHeader

                    Picker(L.learnFilterAll(language), selection: $showRemainingOnly) {
                        Text(L.learnFilterAll(language)).tag(false)
                        Text(L.learnFilterRemaining(language)).tag(true)
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .padding(.horizontal)

                    if hasVisibleLetters {
                        ForEach(HangulCategory.allCases) { category in
                            let items = letters(in: category)
                            if !items.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(category.title(language))
                                        .font(.headline)
                                        .padding(.horizontal)

                                    LazyVGrid(columns: columns, spacing: 12) {
                                        ForEach(items) { letter in
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
                    } else {
                        ContentUnavailableView(L.learnAllLearned(language),
                                               systemImage: "checkmark.seal.fill")
                            .padding(.top, 40)
                    }
                }
                .padding(.vertical)
                .animation(.default, value: showRemainingOnly)
            }
            .navigationTitle(L.learnTitle(language))
            .sheet(item: $selectedLetter) { letter in
                LetterDetailView(letter: letter, language: language)
            }
        }
    }

    private var progressHeader: some View {
        let total = HangulData.all.count
        let learned = progress.learnedCount
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(L.lettersLearned(language))
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text("\(learned) / \(total)")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(learned), total: Double(max(total, 1)))
        }
        .padding(.horizontal)
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
                .lineLimit(1)
                .minimumScaleFactor(0.7)
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
