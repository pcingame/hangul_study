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
}
