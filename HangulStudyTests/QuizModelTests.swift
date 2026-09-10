import Foundation
import Testing
@testable import HangulStudy

@MainActor
struct QuizModelTests {

    /// Model dùng một `ProgressStore` riêng để test không đụng dữ liệu thật.
    private func makeModel() -> (QuizModel, ProgressStore) {
        let store = ProgressStore(defaults: UserDefaults(suiteName: "quiz-\(UUID().uuidString)")!)
        return (QuizModel(progress: store), store)
    }

    // MARK: Khởi tạo bộ câu hỏi

    @Test func startFillsExactlyQuestionCountForLargePools() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        #expect(model.questions.count == QuizModel.questionCount)
    }

    @Test func startClampsToPoolSizeForSmallCategories() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .category(.doubleConsonant)) // chỉ 5 chữ
        #expect(model.questions.count == 5)
    }

    @Test func startYieldsNoQuestionsWhenPoolTooSmall() {
        let (model, store) = makeModel()
        // Cho gần hết chữ "đã ôn xong" (nextReview ở tương lai) → còn < 4 chữ cần ôn.
        for letter in HangulData.all.dropLast(3) {
            for _ in 0..<3 { store.record(letter, correct: true) }
        }
        #expect(store.dueLetters.count == 3)
        model.start(mode: .seeLetter, scope: .due)
        #expect(model.questions.isEmpty)
        #expect(!model.isFinished)
    }

    @Test func startResetsScoreIndexAndSelection() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        _ = model.choose(model.current!.answer)
        model.advance()

        model.start(mode: .seeLetter, scope: .all)
        #expect(model.index == 0)
        #expect(model.score == 0)
        #expect(model.selected == nil)
    }

    // MARK: Cấu trúc câu hỏi

    @Test func seeLetterOptionsAreFourDistinctRomanizationsIncludingAnswer() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        for question in model.questions {
            #expect(question.options.count == 4)
            #expect(Set(question.options).count == 4)
            #expect(question.options.contains(question.answer))
            #expect(question.answer == question.letter.romanization)
            #expect(question.prompt(.vi) == L.quizPrompt(.vi))
        }
    }

    @Test func hearSoundOptionsAreFourDistinctCharactersIncludingAnswer() {
        let (model, _) = makeModel()
        model.start(mode: .hearSound, scope: .all)
        for question in model.questions {
            #expect(question.options.count == 4)
            #expect(Set(question.options).count == 4)
            #expect(question.options.contains(question.answer))
            #expect(question.answer == question.letter.character)
            #expect(question.prompt(.vi) == L.quizPromptHear(.vi))
        }
    }

    @Test func typeAnswerQuestionsHaveNoPresetOptions() {
        let (model, _) = makeModel()
        model.start(mode: .typeAnswer, scope: .all)
        #expect(model.questions.allSatisfy { $0.options.isEmpty })
        #expect(model.questions.allSatisfy { $0.prompt(.vi) == L.quizTypePrompt(.vi) })
    }

    @Test func typeAnswerAcceptsAnyRomanizationVariantCaseInsensitively() {
        let question = QuizQuestion(letter: HangulData.basicConsonants[0], mode: .typeAnswer, options: [])
        // ㄱ: romanization "g / k" — cả hai đều phải được chấp nhận, không phân biệt hoa/thường/khoảng trắng.
        #expect(question.isCorrect("g"))
        #expect(question.isCorrect(" K "))
        #expect(!question.isCorrect("x"))
    }

    @Test func choosingCorrectTypedAnswerRaisesScore() {
        let (model, _) = makeModel()
        model.start(mode: .typeAnswer, scope: .all)
        let question = model.current!
        let variant = question.letter.romanization.split(separator: "/")[0].trimmingCharacters(in: .whitespaces)

        #expect(model.choose(variant) == true)
        #expect(model.score == 1)
    }

    @Test func categoryScopeKeepsQuestionsInsideCategory() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .category(.basicVowel))
        #expect(model.questions.count == 10)
        #expect(model.questions.allSatisfy { $0.letter.category == .basicVowel })
    }

    @Test func questionsDoNotRepeatLetters() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        let letters = model.questions.map(\.letter.character)
        #expect(Set(letters).count == letters.count)
    }

    // MARK: Chọn đáp án

    @Test func choosingCorrectAnswerRaisesScoreOnce() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        let question = model.current!

        #expect(model.choose(question.answer) == true)
        #expect(model.score == 1)
        #expect(model.selected == question.answer)

        // Chọn lần hai bị bỏ qua.
        #expect(model.choose(question.answer) == false)
        #expect(model.score == 1)
    }

    @Test func choosingWrongAnswerDoesNotRaiseScore() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        let question = model.current!
        let wrong = question.options.first { $0 != question.answer }!

        #expect(model.choose(wrong) == false)
        #expect(model.score == 0)
        #expect(model.selected == wrong)
    }

    @Test func chooseBeforeStartDoesNothing() {
        let (model, _) = makeModel()
        #expect(model.choose("a") == false)
        #expect(model.score == 0)
        #expect(model.selected == nil)
    }

    @Test func choosingRecordsResultInProgressStore() {
        let (model, store) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        let question = model.current!

        _ = model.choose(question.answer)
        #expect(store.entry(for: question.letter).correct == 1)
        #expect(store.entry(for: question.letter).box == 1)
    }

    // MARK: Tiến trình

    @Test func advanceMovesToNextQuestionAndClearsSelection() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        _ = model.choose(model.current!.answer)
        model.advance()
        #expect(model.index == 1)
        #expect(model.selected == nil)
        #expect(model.current != nil)
    }

    @Test func finishingWholeQuizSetsIsFinishedAndNilCurrent() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)

        var correct = 0
        while let question = model.current {
            if model.choose(question.answer) { correct += 1 }
            model.advance()
        }
        #expect(model.isFinished)
        #expect(model.current == nil)
        #expect(model.score == correct)
        #expect(model.score == QuizModel.questionCount)
    }

    @Test func progressTextTracksPosition() {
        let (model, _) = makeModel()
        model.start(mode: .seeLetter, scope: .all)
        #expect(model.progressText == "1 / 10")
        model.advance()
        #expect(model.progressText == "2 / 10")
        for _ in 0..<20 { model.advance() }
        #expect(model.progressText == "10 / 10") // không vượt quá tổng
    }

    // MARK: QuizScope

    @Test func scopeAllChoicesCoversAllCasesAndIsStable() {
        #expect(QuizScope.allChoices.count == 2 + HangulCategory.allCases.count)
        #expect(QuizScope.allChoices.first == .all)
        #expect(QuizScope.allChoices.map(\.id).count == Set(QuizScope.allChoices.map(\.id)).count)
    }

    @Test func scopePoolMatchesScope() {
        let store = ProgressStore(defaults: UserDefaults(suiteName: "scope-\(UUID().uuidString)")!)
        #expect(QuizScope.all.pool(using: store).count == 40)
        #expect(QuizScope.category(.basicConsonant).pool(using: store).count == 14)
        #expect(QuizScope.due.pool(using: store).count == 40) // chưa học gì → tất cả cần ôn
    }
}
