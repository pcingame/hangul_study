import Testing
@testable import HangulStudy

struct StudyContentTests {
    @Test func bundledContentLoads() {
        #expect(StudyContent.vocabulary.count == 986)
        #expect(StudyContent.grammar.count == 70)
        #expect(StudyContent.exercises.count == 87)
        #expect(StudyContent.units == Array(1...8))
    }

    @Test func everyExerciseAnswerIsAnOption() {
        for exercise in StudyContent.exercises {
            #expect(exercise.options.contains(exercise.answer))
        }
    }

    @Test func vocabQuizHasFourDistinctOptionsIncludingAnswer() {
        for lesson in [nil] + StudyContent.lessons.prefix(3).map { Optional($0.title) } {
            let quiz = StudyContent.vocabQuiz(from: StudyContent.words(unit: nil, lesson: lesson))
            #expect(!quiz.isEmpty)
            for question in quiz {
                #expect(question.options.contains(question.answer))
                #expect(Set(question.options).count == 4)
            }
        }
    }

    @Test func everyLessonListsItsWordsInFullAndInOrder() {
        #expect(StudyContent.lessons.count == 33)
        for lesson in StudyContent.lessons {
            let words = StudyContent.words(unit: nil, lesson: lesson.title)
            #expect(words.map(\.word) == lesson.words)
        }
    }
}
