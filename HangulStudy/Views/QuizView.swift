import SwiftUI
import UIKit

enum QuizMode: CaseIterable, Identifiable {
    case seeLetter   // nhìn chữ, chọn cách đọc
    case hearSound   // nghe âm, chọn chữ
    case typeAnswer  // nhìn chữ, tự gõ cách đọc (không có sẵn lựa chọn)

    var id: Self { self }

    var label: Bilingual {
        switch self {
        case .seeLetter: return L.quizModeSeeLetter
        case .hearSound: return L.quizModeHearSound
        case .typeAnswer: return L.quizModeType
        }
    }
}

enum QuizScope: Identifiable, Hashable {
    case all
    case due
    case category(HangulCategory)

    var id: String {
        switch self {
        case .all: return "all"
        case .due: return "due"
        case .category(let category): return category.rawValue
        }
    }

    static let allChoices: [QuizScope] = [.all, .due] + HangulCategory.allCases.map(QuizScope.category)

    func label(_ language: AppLanguage) -> String {
        switch self {
        case .all: return L.quizScopeAll(language)
        case .due: return L.quizScopeDue(language)
        case .category(let category): return category.title(language)
        }
    }

    @MainActor
    func pool(using store: ProgressStore = .shared) -> [HangulLetter] {
        switch self {
        case .all: return HangulData.all
        case .due: return store.dueLetters
        case .category(let category): return HangulData.letters(in: category)
        }
    }
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let letter: HangulLetter
    let mode: QuizMode
    let options: [String]

    /// Đáp án đúng để hiển thị khi trả lời sai: cách đọc (seeLetter/typeAnswer) hoặc ký tự (hearSound).
    var answer: String { mode == .hearSound ? letter.character : letter.romanization }

    /// Nội dung hiển thị cho mỗi lựa chọn / ô nhập.
    var prompt: Bilingual {
        switch mode {
        case .seeLetter: return L.quizPrompt
        case .hearSound: return L.quizPromptHear
        case .typeAnswer: return L.quizTypePrompt
        }
    }

    /// Cách đọc có thể chấp nhận khi gõ tay: `letter.romanization` đôi khi gộp nhiều lựa
    /// chọn cách nhau bởi "/" (vd "g / k"), gõ đúng một trong các phần đó là được.
    private var acceptableTypedAnswers: [String] {
        letter.romanization.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    }

    /// Kiểm tra một lựa chọn (hoặc nội dung gõ tay) có đúng không.
    func isCorrect(_ option: String) -> Bool {
        if mode == .typeAnswer {
            return acceptableTypedAnswers.contains(option.trimmingCharacters(in: .whitespaces).lowercased())
        }
        return option == answer
    }
}

@MainActor
final class QuizModel: ObservableObject {
    static let questionCount = 10

    @Published private(set) var questions: [QuizQuestion] = []
    @Published private(set) var index = 0
    @Published private(set) var score = 0
    @Published private(set) var selected: String?
    @Published private(set) var missedLetters: [HangulLetter] = []

    private let progress: ProgressStore

    init(progress: ProgressStore = .shared) {
        self.progress = progress
    }

    var current: QuizQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var isFinished: Bool { !questions.isEmpty && index >= questions.count }

    var progressText: String { "\(min(index + 1, questions.count)) / \(questions.count)" }

    func start(mode: QuizMode, scope: QuizScope) {
        let pool = scope.pool(using: progress)
        guard pool.count >= 4 else {
            questions = []
            return
        }
        let count = min(Self.questionCount, pool.count)
        questions = pool.shuffled().prefix(count).map { letter in
            makeQuestion(for: letter, mode: mode, pool: pool)
        }
        index = 0
        score = 0
        selected = nil
        missedLetters = []
    }

    private func makeQuestion(for letter: HangulLetter, mode: QuizMode, pool: [HangulLetter]) -> QuizQuestion {
        // Chế độ gõ tay không cần lựa chọn sẵn.
        guard mode != .typeAnswer else {
            return QuizQuestion(letter: letter, mode: mode, options: [])
        }
        let correct = mode == .seeLetter ? letter.romanization : letter.character
        let distractorSource = (pool.count >= 4 ? pool : HangulData.all)
        let distractors = distractorSource
            .filter { $0.character != letter.character }
            .shuffled()
            .prefix(3)
            .map { mode == .seeLetter ? $0.romanization : $0.character }
        return QuizQuestion(letter: letter, mode: mode, options: ([correct] + distractors).shuffled())
    }

    /// Trả về true nếu chọn/gõ đúng.
    @discardableResult
    func choose(_ option: String) -> Bool {
        guard selected == nil, let current else { return false }
        selected = option
        let isCorrect = current.isCorrect(option)
        if isCorrect {
            score += 1
        } else {
            missedLetters.append(current.letter)
        }
        progress.record(current.letter, correct: isCorrect)
        return isCorrect
    }

    func advance() {
        index += 1
        selected = nil
    }
}

struct QuizView: View {
    let language: AppLanguage

    @StateObject private var model = QuizModel()
    @State private var mode: QuizMode = .seeLetter
    @State private var scope: QuizScope = .all
    @State private var typedAnswer = ""

    private let haptics = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L.quizTitle(language))
        }
    }

    @ViewBuilder
    private var content: some View {
        if model.questions.isEmpty {
            startScreen
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if model.isFinished {
            resultScreen
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let question = model.current {
            questionScreen(question)
        }
    }

    // MARK: - Start

    private var startScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Picker(L.quizTitle(language), selection: $mode) {
                ForEach(QuizMode.allCases) { Text($0.label(language)).tag($0) }
            }
            .pickerStyle(.segmented)

            Picker(L.quizScopeLabel(language), selection: $scope) {
                ForEach(QuizScope.allChoices) { Text($0.label(language)).tag($0) }
            }
            .pickerStyle(.menu)

            if scope == .due && ProgressStore.shared.dueLetters.count < 4 {
                Text(L.quizNothingDue(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(L.startQuiz(language)) {
                typedAnswer = ""
                model.start(mode: mode, scope: scope)
            }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(scope.pool().count < 4)
        }
        .frame(maxWidth: 420)
    }

    // MARK: - Question

    private func questionScreen(_ question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    ProgressView(value: Double(model.index + 1),
                                 total: Double(max(model.questions.count, 1)))
                    Text("\(L.questionProgress(language)) \(model.progressText)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 420)

                Group {
                    if question.mode == .seeLetter {
                        Text(question.letter.character)
                            .font(.system(size: 88, weight: .medium))
                    } else {
                        Button {
                            SpeechService.shared.speak(question.letter)
                        } label: {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 60))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.tint)
                    }
                }
                .frame(height: 110)

                Text(question.prompt(language))
                    .font(.headline)

                if question.mode == .typeAnswer {
                    typedAnswerField(question)
                } else {
                    VStack(spacing: 10) {
                        ForEach(question.options, id: \.self) { option in
                            Button {
                                answer(question, with: option)
                            } label: {
                                Text(option)
                                    .font(question.mode == .hearSound ? .title2.weight(.medium) : .body)
                                    .frame(maxWidth: .infinity, minHeight: 28)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.large)
                            .tint(optionTint(option, question: question))
                            .disabled(model.selected != nil)
                        }
                    }
                }
            }
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            if let selected = model.selected {
                let wasCorrect = question.isCorrect(selected)
                VStack(spacing: 10) {
                    Text(wasCorrect
                         ? L.correct(language)
                         : "\(L.wrong(language)) — \(question.answer)")
                        .font(.headline)
                        .foregroundStyle(wasCorrect ? .green : .red)

                    Button(model.index + 1 < model.questions.count ? L.nextQuestion(language) : L.seeResult(language)) {
                        model.advance()
                        typedAnswer = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: 420)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.bar)
            }
        }
    }

    private func typedAnswerField(_ question: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            TextField(L.quizTypePlaceholder(language), text: $typedAnswer)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(model.selected != nil)
                .onSubmit { answer(question, with: typedAnswer) }
                .frame(maxWidth: 280)
                .frame(maxWidth: .infinity)

            Button(L.checkAnswer(language)) { answer(question, with: typedAnswer) }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(model.selected != nil || typedAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    /// Xử lý chung cho cả bấm lựa chọn lẫn gõ đáp án: ghi nhận, rung, phát âm thanh + đọc chữ.
    private func answer(_ question: QuizQuestion, with option: String) {
        guard model.selected == nil, !option.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let correct = model.choose(option)
        haptics.notificationOccurred(correct ? .success : .error)
        if correct {
            SoundEffects.shared.playCorrect()
        } else {
            SoundEffects.shared.playWrong()
        }
        SpeechService.shared.speak(question.letter)
    }

    private func optionTint(_ option: String, question: QuizQuestion) -> Color {
        guard let selected = model.selected else { return .accentColor }
        if option == question.answer { return .green }
        if option == selected { return .red }
        return .gray
    }

    // MARK: - Result

    private var resultScreen: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(L.quizDone(language))
                    .font(.largeTitle.bold())
                Text("\(L.score(language)): \(model.score) / \(model.questions.count)")
                    .font(.title2)

                if model.missedLetters.isEmpty {
                    Label(L.quizPerfect(language), systemImage: "star.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    missedList
                }

                Button(L.tryAgain(language)) { model.start(mode: mode, scope: scope) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .frame(maxWidth: 420)
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear { SoundEffects.shared.playComplete() }
    }

    private var missedList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L.quizReviewMissed(language))
                .font(.headline)

            ForEach(model.missedLetters) { letter in
                Button {
                    SpeechService.shared.speak(letter)
                } label: {
                    HStack(spacing: 14) {
                        Text(letter.character)
                            .font(.system(size: 32, weight: .medium))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(letter.romanization)
                            Text(letter.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    QuizView(language: .vi)
}
