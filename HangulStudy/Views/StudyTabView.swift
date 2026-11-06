import SwiftUI

/// Tab "Từ vựng": từ vựng, ngữ pháp và bài tập ngữ pháp từ giáo trình, lọc theo bài.
struct StudyTabView: View {
    let language: AppLanguage

    private enum Section: CaseIterable {
        case vocabulary, flashcards, vocabQuiz, grammar, exercises

        var title: Bilingual {
            switch self {
            case .vocabulary: return L.studyVocabulary
            case .flashcards: return L.studyFlashcards
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

    @ObservedObject private var vocabStore = ProgressStore.vocab
    @AppStorage("learnedVocab") private var learnedRaw = ""

    /// Giá trị đặc biệt của bộ lọc bài: các từ đã ôn và tới hạn ôn lại.
    private static let dueTag = "__due__"

    private var dueWords: [Vocab] { StudyContent.vocabulary.filter { vocabStore.isReviewDue(key: $0.word) } }

    /// Từ vựng theo bộ lọc hiện tại, dùng chung cho danh sách, thẻ và quiz.
    private var vocabWords: [Vocab] {
        lesson == Self.dueTag ? dueWords : StudyContent.words(unit: unit, lesson: lesson)
    }

    private var vocabKey: String { "\(unit ?? 0)|\(lesson ?? "")" }

    private func lessonLabel(_ lesson: Lesson) -> String {
        let learned = StudyContent.learnedIDs(learnedRaw)
        let done = StudyContent.words(unit: nil, lesson: lesson.title).filter { learned.contains($0.id) }.count
        return "\(lesson.title) (\(done)/\(lesson.words.count))"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $section) {
                    ForEach(Section.allCases, id: \.self) { Text($0.title(language)).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                switch section {
                case .vocabulary:
                    VocabularyListView(language: language, words: vocabWords,
                                       grouped: lesson != nil && lesson != Self.dueTag)
                case .flashcards:
                    FlashcardView(language: language, words: vocabWords, reloadKey: vocabKey)
                case .vocabQuiz:
                    GrammarExerciseView(language: language, reloadKey: vocabKey,
                                        makeQuestions: { StudyContent.vocabQuiz(from: vocabWords) },
                                        onAnswer: { vocabStore.record(key: $0.sentence, correct: $1) })
                case .grammar: GrammarListView(language: language, unit: unit)
                case .exercises: GrammarExerciseView(language: language, reloadKey: "\(unit ?? 0)") {
                        StudyContent.exercises.filter { unit == nil || $0.unit == unit }
                    }
                }
            }
            .navigationTitle(L.studyTitle(language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if [.vocabulary, .flashcards, .vocabQuiz].contains(section) {
                    ToolbarItem(placement: .topBarLeading) {
                        Picker(L.studyUnit(language), selection: $lesson) {
                            Text(L.studyAllUnits(language)).tag(String?.none)
                            if !dueWords.isEmpty || lesson == Self.dueTag {
                                Text("\(L.studyDue(language)) (\(dueWords.count))").tag(String?.some(Self.dueTag))
                            }
                            ForEach(StudyContent.lessons, id: \.title) { Text(lessonLabel($0)).tag(String?.some($0.title)) }
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
    let words: [Vocab]
    /// Chia thành từng nhóm 7 từ (như bản web); không thì giữ một danh sách liền.
    let grouped: Bool

    /// Id các từ đã thuộc, lưu dạng "1,2,3" trong UserDefaults.
    @AppStorage("learnedVocab") private var learnedRaw = ""
    @State private var search = ""

    private var learned: Set<Int> { StudyContent.learnedIDs(learnedRaw) }

    private var shown: [Vocab] {
        words.filter { word in
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
        .overlay { if shown.isEmpty { Text(L.studyEmpty(language)).foregroundStyle(.secondary) } }
    }

    /// Nhóm 7 từ khi `grouped`, ngược lại một nhóm duy nhất.
    private var groups: [(start: Int, title: String, words: [Vocab])] {
        guard grouped else { return [(0, "", shown)] }
        return stride(from: 0, to: shown.count, by: 7).enumerated().map { index, start in
            (start, "\(L.studyGroup(language)) \(index + 1)", Array(shown[start..<min(start + 7, shown.count)]))
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
        learnedRaw = StudyContent.learnedRaw(ids)
    }
}

private struct GrammarListView: View {
    let language: AppLanguage
    let unit: Int?

    /// Gom theo bài (unit); các điểm chưa gắn bài xếp cuối trong mục "Khác".
    private var sections: [(unit: Int?, points: [GrammarPoint])] {
        let points = StudyContent.grammar.filter { unit == nil || $0.unit == unit }
        let grouped = Dictionary(grouping: points, by: \.unit)
        return grouped.keys.sorted { ($0 ?? .max) < ($1 ?? .max) }.map { ($0, grouped[$0] ?? []) }
    }

    var body: some View {
        List {
            ForEach(sections, id: \.unit) { section in
                Section(section.unit.map { "\(L.studyUnit(language)) \($0)" } ?? L.studyOther(language)) {
                    ForEach(section.points) { point in
                        NavigationLink(point.title) { GrammarDetailView(point: point) }
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

private struct GrammarDetailView: View {
    let point: GrammarPoint

    var body: some View {
        List {
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
        .navigationTitle(point.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
