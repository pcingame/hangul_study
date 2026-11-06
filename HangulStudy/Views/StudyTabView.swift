import SwiftUI

/// Tab "Từ vựng": từ vựng, ngữ pháp và bài tập ngữ pháp từ giáo trình, lọc theo bài.
struct StudyTabView: View {
    let language: AppLanguage

    private enum Section: CaseIterable {
        case vocabulary, vocabQuiz, grammar, exercises

        var title: Bilingual {
            switch self {
            case .vocabulary: return L.studyVocabulary
            case .vocabQuiz: return L.studyVocabQuiz
            case .grammar: return L.studyGrammar
            case .exercises: return L.studyExercises
            }
        }
    }

    @State private var section = Section.vocabulary
    /// `nil` = tất cả các bài.
    @State private var unit: Int?
    @State private var lesson: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { Text($0.title(language)).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                switch section {
                case .vocabulary: VocabularyListView(language: language, unit: unit, lesson: lesson)
                case .vocabQuiz:
                    GrammarExerciseView(language: language, reloadKey: "\(unit ?? 0)|\(lesson ?? "")") {
                        StudyContent.vocabQuiz(unit: unit, lesson: lesson)
                    }
                case .grammar: GrammarListView(unit: unit)
                case .exercises: GrammarExerciseView(language: language, reloadKey: "\(unit ?? 0)") {
                        StudyContent.exercises.filter { unit == nil || $0.unit == unit }
                    }
                }
            }
            .navigationTitle(L.studyTitle(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if section == .vocabulary || section == .vocabQuiz {
                    ToolbarItem(placement: .topBarLeading) {
                        Picker(L.studyUnit(language), selection: $lesson) {
                            Text(L.studyAllUnits(language)).tag(String?.none)
                            ForEach(StudyContent.lessons, id: \.title) { Text($0.title).tag(String?.some($0.title)) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Picker(L.studyUnit(language), selection: $unit) {
                        Text(L.studyAllUnits(language)).tag(Int?.none)
                        ForEach(StudyContent.units, id: \.self) { Text("\(L.studyUnit(language)) \($0)").tag(Int?.some($0)) }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}

private struct VocabularyListView: View {
    let language: AppLanguage
    let unit: Int?
    let lesson: String?

    /// Id các từ đã thuộc, lưu dạng "1,2,3" trong UserDefaults.
    @AppStorage("learnedVocab") private var learnedRaw = ""
    @State private var search = ""

    private var learned: Set<Int> { Set(learnedRaw.split(separator: ",").compactMap { Int($0) }) }

    private var words: [Vocab] {
        StudyContent.words(unit: unit, lesson: lesson).filter { word in
            search.isEmpty || word.word.contains(search)
                || word.meaning.localizedCaseInsensitiveContains(search)
                || word.reading.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            ForEach(groups, id: \.start) { group in
                Section(group.title) {
                    ForEach(group.words) { wordRow($0) }
                }
            }
        }
        .listStyle(.plain)
        .searchable(text: $search)
        .overlay { if words.isEmpty { Text(L.studyEmpty(language)).foregroundStyle(.secondary) } }
    }

    /// Khi đã chọn một bài, chia thành từng nhóm 7 từ (như bản web); ngược lại giữ một danh sách liền.
    private var groups: [(start: Int, title: String, words: [Vocab])] {
        guard lesson != nil else { return [(0, "", words)] }
        return stride(from: 0, to: words.count, by: 7).enumerated().map { index, start in
            (start, "\(L.studyGroup(language)) \(index + 1)", Array(words[start..<min(start + 7, words.count)]))
        }
    }

    private func wordRow(_ word: Vocab) -> some View {
        HStack(spacing: 12) {
            Button { SpeechService.shared.speak(word.word) } label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(word.word).font(.title3)
                    Text("\(word.reading) · \(word.meaning)").font(.subheadline)
                    Text(word.example).font(.caption).foregroundStyle(.secondary)
                    Text(word.translation).font(.caption).foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button { toggle(word.id) } label: {
                Image(systemName: learned.contains(word.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(learned.contains(word.id) ? Color.green : .secondary)
            }
            .buttonStyle(.borderless)
        }
    }

    private func toggle(_ id: Int) {
        var ids = learned
        if !ids.insert(id).inserted { ids.remove(id) }
        learnedRaw = ids.sorted().map(String.init).joined(separator: ",")
    }
}

private struct GrammarListView: View {
    let unit: Int?

    private var points: [GrammarPoint] {
        StudyContent.grammar.filter { unit == nil || $0.unit == unit }
    }

    var body: some View {
        List(points) { point in
            VStack(alignment: .leading, spacing: 6) {
                Text(point.title).font(.headline)
                Text(point.explanation).font(.subheadline)
                ForEach(point.examples, id: \.korean) { example in
                    Button { SpeechService.shared.speak(example.korean) } label: {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(example.korean)
                            Text(example.vietnamese).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
        .listStyle(.plain)
    }
}
