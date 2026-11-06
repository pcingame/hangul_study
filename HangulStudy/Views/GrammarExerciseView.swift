import SwiftUI

/// Bài tập trắc nghiệm theo đợt 10 câu (ngữ pháp, hoặc quiz từ vựng): chọn đáp án, xem ghi chú, qua câu tiếp, cuối cùng xem điểm.
struct GrammarExerciseView: View {
    let language: AppLanguage
    /// Đổi giá trị này (đổi bộ lọc) thì làm lại từ đầu.
    let reloadKey: String
    let makeQuestions: () -> [GrammarExercise]
    /// Gọi sau mỗi câu trả lời (câu hỏi, đúng/sai); dùng để ghi lịch ôn.
    var onAnswer: ((GrammarExercise, Bool) -> Void)?

    private static let roundSize = 10

    @State private var questions: [GrammarExercise] = []
    @State private var index = 0
    @State private var picked: String?
    @State private var correctCount = 0
    @State private var missed: [GrammarExercise] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if questions.isEmpty {
                Text(L.studyEmpty(language)).foregroundStyle(.secondary)
            } else if index >= questions.count {
                Text("\(L.score(language)): \(correctCount)/\(questions.count)").font(.title2)
                Button(L.tryAgain(language), action: restart).buttonStyle(.borderedProminent)
                if !missed.isEmpty {
                    Button("\(L.retryMissed(language)) (\(missed.count))", action: retryMissed).buttonStyle(.bordered)
                }
            } else {
                let question = questions[index]
                Text("\(L.questionProgress(language)) \(index + 1)/\(questions.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Text(question.sentence).font(.title2)
                Text(question.vi).foregroundStyle(.secondary)

                ForEach(question.options, id: \.self) { option in
                    Button { answer(option, of: question) } label: {
                        Text(option).frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(tint(for: option, in: question))
                    .disabled(picked != nil)
                }

                if picked != nil {
                    Text(question.note).font(.footnote).foregroundStyle(.secondary)
                    Button(index + 1 == questions.count ? L.seeResult(language) : L.nextQuestion(language)) {
                        index += 1
                        picked = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            Spacer()
        }
        .padding()
        .onAppear(perform: restart)
        .onChange(of: reloadKey) { restart() }
    }

    private func restart() {
        questions = Array(makeQuestions().shuffled().prefix(Self.roundSize))
        index = 0
        picked = nil
        correctCount = 0
        missed = []
    }

    /// Làm lại chỉ những câu vừa sai.
    private func retryMissed() {
        questions = missed.shuffled()
        index = 0
        picked = nil
        correctCount = 0
        missed = []
    }

    private func answer(_ option: String, of question: GrammarExercise) {
        picked = option
        onAnswer?(question, option == question.answer)
        if option == question.answer {
            correctCount += 1
            SoundEffects.shared.playCorrect()
        } else {
            missed.append(question)
            SoundEffects.shared.playWrong()
        }
    }

    private func tint(for option: String, in question: GrammarExercise) -> Color? {
        guard let picked else { return nil }
        if option == question.answer { return .green }
        return option == picked ? .red : nil
    }
}
