import Testing
@testable import HangulStudy

@MainActor
struct QuizModelTests {
    @Test func seeLetterQuestionsAreWellFormed() {
        let model = QuizModel()
        model.start(mode: .seeLetter, scope: .all)

        #expect(model.questions.count == QuizModel.questionCount)
        for question in model.questions {
            #expect(question.options.count == 4)
            #expect(Set(question.options).count == 4)
            #expect(question.options.contains(question.answer))
            #expect(question.answer == question.letter.romanization)
        }
    }

    @Test func hearSoundQuestionsUseCharacters() {
        let model = QuizModel()
        model.start(mode: .hearSound, scope: .all)

        for question in model.questions {
            #expect(question.answer == question.letter.character)
            #expect(question.options.contains(question.letter.character))
        }
    }

    @Test func scoreCountsCorrectAnswers() {
        let model = QuizModel()
        model.start(mode: .seeLetter, scope: .all)

        var expected = 0
        while let question = model.current {
            let correct = model.choose(question.answer)
            #expect(correct)
            expected += 1
            model.advance()
        }
        #expect(model.score == expected)
        #expect(model.isFinished)
    }

    @Test func categoryScopeStaysWithinCategory() {
        let model = QuizModel()
        model.start(mode: .seeLetter, scope: .category(.basicVowel))
        #expect(!model.questions.isEmpty)
        #expect(model.questions.allSatisfy { $0.letter.category == .basicVowel })
    }
}
