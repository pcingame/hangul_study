import SwiftUI

private struct QuizQuestion: Identifiable {
    let id = UUID()
    let letter: HangulLetter
    let options: [String]
    var answer: String { letter.romanization }
}

@MainActor
private final class QuizModel: ObservableObject {
    static let questionCount = 10

    @Published private(set) var questions: [QuizQuestion] = []
    @Published private(set) var index = 0
    @Published private(set) var score = 0
    @Published private(set) var selected: String?

    var current: QuizQuestion? {
        guard index < questions.count else { return nil }
        return questions[index]
    }

    var isFinished: Bool { !questions.isEmpty && index >= questions.count }

    var progressText: String { "\(min(index + 1, questions.count)) / \(questions.count)" }

    func start() {
        let pool = HangulData.all.shuffled()
        questions = pool.prefix(Self.questionCount).map { letter in
            let distractors = HangulData.all
                .filter { $0.romanization != letter.romanization }
                .shuffled()
                .prefix(3)
                .map(\.romanization)
            return QuizQuestion(letter: letter, options: ([letter.romanization] + distractors).shuffled())
        }
        index = 0
        score = 0
        selected = nil
    }

    func choose(_ option: String) {
        guard selected == nil, let current else { return }
        selected = option
        if option == current.answer { score += 1 }
    }

    func advance() {
        index += 1
        selected = nil
    }
}

struct QuizView: View {
    let language: AppLanguage

    @StateObject private var model = QuizModel()

    var body: some View {
        NavigationStack {
            Group {
                if model.questions.isEmpty {
                    startScreen
                } else if model.isFinished {
                    resultScreen
                } else if let question = model.current {
                    questionScreen(question)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(L.quizTitle(language))
        }
    }

    private var startScreen: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text(L.quizPrompt(language))
                .font(.title3)
                .multilineTextAlignment(.center)
            Button(L.startQuiz(language)) { model.start() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }

    private func questionScreen(_ question: QuizQuestion) -> some View {
        VStack(spacing: 24) {
            Text("\(L.questionProgress(language)) \(model.progressText)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(question.letter.character)
                .font(.system(size: 120, weight: .medium))

            Text(L.quizPrompt(language))
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    Button {
                        model.choose(option)
                        SpeechService.shared.speak(question.letter.character)
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(optionTint(option, question: question))
                    .disabled(model.selected != nil)
                }
            }

            if model.selected != nil {
                Text(model.selected == question.answer ? L.correct(language) : "\(L.wrong(language)) — \(question.answer)")
                    .font(.headline)
                    .foregroundStyle(model.selected == question.answer ? .green : .red)

                Button(model.index + 1 < model.questions.count ? L.nextQuestion(language) : L.seeResult(language)) {
                    model.advance()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Spacer()
        }
    }

    private func optionTint(_ option: String, question: QuizQuestion) -> Color {
        guard let selected = model.selected else { return .accentColor }
        if option == question.answer { return .green }
        if option == selected { return .red }
        return .gray
    }

    private var resultScreen: some View {
        VStack(spacing: 16) {
            Text(L.quizDone(language))
                .font(.largeTitle.bold())
            Text("\(L.score(language)): \(model.score) / \(model.questions.count)")
                .font(.title2)
            Button(L.tryAgain(language)) { model.start() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }
}

#Preview {
    QuizView(language: .vi)
}
