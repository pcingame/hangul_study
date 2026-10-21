import SwiftUI

/// Bài tập điền chỗ trống ngữ pháp: chọn đáp án, xem ghi chú, qua câu tiếp, cuối cùng xem điểm.
struct GrammarExerciseView: View {
    let language: AppLanguage
    let unit: Int?

    @State private var questions: [GrammarExercise] = []
    @State private var index = 0
    @State private var picked: String?
    @State private var correctCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if questions.isEmpty {
                Text(L.studyEmpty(language)).foregroundStyle(.secondary)
            } else if index >= questions.count {
                Text("\(L.score(language)): \(correctCount)/\(questions.count)").font(.title2)
                Button(L.tryAgain(language), action: restart).buttonStyle(.borderedProminent)
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
        .onChange(of: unit) { restart() }
    }

    private func restart() {
        questions = StudyContent.exercises.filter { unit == nil || $0.unit == unit }.shuffled()
        index = 0
        picked = nil
        correctCount = 0
    }

    private func answer(_ option: String, of question: GrammarExercise) {
        picked = option
        if option == question.answer {
            correctCount += 1
            SoundEffects.shared.playCorrect()
        } else {
            SoundEffects.shared.playWrong()
        }
    }

    private func tint(for option: String, in question: GrammarExercise) -> Color? {
        guard let picked else { return nil }
        if option == question.answer { return .green }
        return option == picked ? .red : nil
    }
}
