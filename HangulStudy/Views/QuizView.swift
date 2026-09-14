import SwiftUI
import UIKit

enum QuizMode: CaseIterable, Identifiable {
    case seeLetter   // nhìn chữ, chọn cách đọc
    case hearSound   // nghe âm, chọn chữ
    case typeAnswer  // nhìn chữ, tự gõ cách đọc (không có sẵn lựa chọn)
    case pronounce   // nhìn chữ, đọc to và được chấm điểm phát âm

    var id: Self { self }

    var label: Bilingual {
        switch self {
        case .seeLetter: return L.quizModeSeeLetter
        case .hearSound: return L.quizModeHearSound
        case .typeAnswer: return L.quizModeType
        case .pronounce: return L.quizModePronounce
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
    /// Chỉ có ý nghĩa khi `mode == .pronounce`: đọc theo tên chữ hay theo từ ví dụ.
    var pronunciationTarget: PronunciationTarget = .letterName

    /// Đáp án đúng để hiển thị khi trả lời sai: cách đọc (seeLetter/typeAnswer), ký tự (hearSound)
    /// hoặc cách đọc thành tiếng (pronounce, theo `pronunciationTarget`).
    var answer: String {
        switch mode {
        case .hearSound: return letter.character
        case .pronounce: return pronunciationTarget.spokenText(for: letter)
        case .seeLetter, .typeAnswer: return letter.romanization
        }
    }

    /// Nội dung hiển thị cho mỗi lựa chọn / ô nhập.
    var prompt: Bilingual {
        switch mode {
        case .seeLetter: return L.quizPrompt
        case .hearSound: return L.quizPromptHear
        case .typeAnswer: return L.quizTypePrompt
        case .pronounce: return L.quizPronouncePrompt
        }
    }

    /// Cách đọc có thể chấp nhận khi gõ tay: `letter.romanization` đôi khi gộp nhiều lựa
    /// chọn cách nhau bởi "/" (vd "g / k"), gõ đúng một trong các phần đó là được.
    private var acceptableTypedAnswers: [String] {
        letter.romanization.split(separator: "/").map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
    }

    /// Kiểm tra một lựa chọn (hoặc nội dung gõ tay) có đúng không. Chế độ `pronounce` không so
    /// khớp chuỗi — `option` là "correct"/"wrong" do `QuizModel.choosePronunciation` tính sẵn từ điểm phát âm.
    func isCorrect(_ option: String) -> Bool {
        switch mode {
        case .typeAnswer:
            return acceptableTypedAnswers.contains(option.trimmingCharacters(in: .whitespaces).lowercased())
        case .pronounce:
            return option == "correct"
        case .seeLetter, .hearSound:
            return option == answer
        }
    }
}

@MainActor
final class QuizModel: ObservableObject {
    static let questionCount = 10
    /// Điểm phát âm tối thiểu (0…100) để tính là trả lời đúng ở chế độ `.pronounce`.
    static let pronunciationPassScore = 50

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

    func start(mode: QuizMode, scope: QuizScope, pronunciationTarget: PronunciationTarget = .letterName) {
        let pool = scope.pool(using: progress)
        guard pool.count >= 4 else {
            questions = []
            return
        }
        let count = min(Self.questionCount, pool.count)
        questions = pool.shuffled().prefix(count).map { letter in
            makeQuestion(for: letter, mode: mode, pool: pool, pronunciationTarget: pronunciationTarget)
        }
        index = 0
        score = 0
        selected = nil
        missedLetters = []
    }

    private func makeQuestion(for letter: HangulLetter, mode: QuizMode, pool: [HangulLetter],
                               pronunciationTarget: PronunciationTarget) -> QuizQuestion {
        // Chế độ gõ tay / đọc to không cần lựa chọn sẵn.
        guard mode != .typeAnswer, mode != .pronounce else {
            return QuizQuestion(letter: letter, mode: mode, options: [], pronunciationTarget: pronunciationTarget)
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

    /// Chấm câu hỏi chế độ `.pronounce` từ điểm phát âm đã tính (`PronunciationScorer`), thay vì
    /// so khớp một lựa chọn đã bấm. Đúng khi điểm đạt `pronunciationPassScore` trở lên.
    @discardableResult
    func choosePronunciation(score: Int?) -> Bool {
        guard selected == nil, let current else { return false }
        let isCorrect = (score ?? 0) >= Self.pronunciationPassScore
        selected = isCorrect ? "correct" : "wrong"
        if isCorrect {
            self.score += 1
        } else {
            missedLetters.append(current.letter)
        }
        progress.record(current.letter, correct: isCorrect)
        return isCorrect
    }
}

struct QuizView: View {
    let language: AppLanguage

    @StateObject private var model = QuizModel()
    @ObservedObject private var pronunciation = PronunciationService.shared
    @State private var mode: QuizMode = .seeLetter
    @State private var scope: QuizScope = .all
    @State private var pronunciationTarget: PronunciationTarget = .letterName
    @State private var typedAnswer = ""
    @State private var recognizedPronunciation = ""
    @State private var pronounceResult: PronounceCheckResult?

    private enum PronounceCheckResult: Equatable {
        case empty
        case scored(Int)
    }

    private let haptics = UINotificationFeedbackGenerator()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(L.quizTitle(language))
        }
        .onDisappear {
            // Rời tab Quiz khi đang ghi âm dở thì phải dừng, không để mic treo.
            if pronunciation.isRecording { pronunciation.stopRecording() }
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

            if mode == .pronounce {
                Picker(L.pronunciationTargetLabel(language), selection: $pronunciationTarget) {
                    ForEach(PronunciationTarget.allCases) { Text($0.label(language)).tag($0) }
                }
                .pickerStyle(.segmented)
            }

            if scope == .due && ProgressStore.shared.dueLetters.count < 4 {
                Text(L.quizNothingDue(language))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(L.startQuiz(language)) {
                typedAnswer = ""
                recognizedPronunciation = ""
                pronounceResult = nil
                model.start(mode: mode, scope: scope, pronunciationTarget: pronunciationTarget)
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
                    } else if question.mode == .pronounce {
                        Text(question.pronunciationTarget.displayText(for: question.letter))
                            .font(.system(size: question.pronunciationTarget == .letterName ? 88 : 44, weight: .medium))
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
                } else if question.mode == .pronounce {
                    pronounceField(question)
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
                        recognizedPronunciation = ""
                        pronounceResult = nil
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

    private func pronounceField(_ question: QuizQuestion) -> some View {
        VStack(spacing: 10) {
            Button {
                togglePronunciationRecording(question)
            } label: {
                Label(pronunciation.isRecording ? L.stopRecording(language) : L.recordPronunciation(language),
                      systemImage: pronunciation.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(pronunciation.isRecording ? .red : .accentColor)
            .disabled(model.selected != nil)

            if pronunciation.isRecording {
                AudioLevelMeter(level: pronunciation.audioLevel)
                    .frame(maxWidth: 240)
            }

            if let pronounceResult {
                pronounceResultView(pronounceResult)
            }

            if pronunciation.authorizationStatus == .denied {
                Text(L.pronunciationPermissionDenied(language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else if !pronunciation.isOnDeviceRecognitionAvailable {
                Text(L.pronunciationOnDeviceUnavailable(language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    @ViewBuilder
    private func pronounceResultView(_ result: PronounceCheckResult) -> some View {
        switch result {
        case .empty:
            Text(L.pronunciationEmpty(language))
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .scored:
            if !recognizedPronunciation.isEmpty {
                Text("\(L.youSaid(language)): \(recognizedPronunciation)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Bắt đầu/dừng ghi âm (hoặc tự dừng khi im lặng); khi dừng thì chấm điểm phát âm và ghi nhận
    /// câu trả lời ngay (không cần nút Kiểm tra riêng).
    private func togglePronunciationRecording(_ question: QuizQuestion) {
        if pronunciation.isRecording {
            finishPronunciationRecording(question, recognized: pronunciation.stopRecording())
        } else {
            recognizedPronunciation = ""
            pronounceResult = nil
            Task {
                if pronunciation.authorizationStatus != .authorized {
                    guard await pronunciation.requestAuthorization() else { return }
                }
                pronunciation.startRecording { recognized in
                    finishPronunciationRecording(question, recognized: recognized)
                }
            }
        }
    }

    private func finishPronunciationRecording(_ question: QuizQuestion, recognized: String) {
        guard model.selected == nil else { return }
        recognizedPronunciation = recognized
        let score = PronunciationScorer.score(recognized: recognized, expected: question.answer)
        pronounceResult = score.map(PronounceCheckResult.scored) ?? .empty
        let correct = model.choosePronunciation(score: score)
        haptics.notificationOccurred(correct ? .success : .error)
        if correct {
            SoundEffects.shared.playCorrect()
        } else {
            SoundEffects.shared.playWrong()
        }
        SpeechService.shared.speak(question.letter)
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

                Button(L.tryAgain(language)) {
                    recognizedPronunciation = ""
                    pronounceResult = nil
                    model.start(mode: mode, scope: scope, pronunciationTarget: pronunciationTarget)
                }
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
