import Foundation
import Testing
@testable import HangulStudy

@MainActor
struct ProgressStoreTests {

    private func makeStore() -> ProgressStore {
        ProgressStore(defaults: UserDefaults(suiteName: "progress-\(UUID().uuidString)")!)
    }

    // MARK: Trạng thái ban đầu

    @Test func unseenLetterHasEmptyProgress() {
        let store = makeStore()
        let entry = store.entry(for: HangulData.all[0])
        #expect(entry.box == 0)
        #expect(entry.correct == 0)
        #expect(entry.wrong == 0)
        #expect(entry.lastReviewed == nil)
        #expect(entry.nextReview == nil)
        #expect(!entry.isLearned)
    }

    @Test func learnedCountStartsAtZeroAndAllLettersAreDue() {
        let store = makeStore()
        #expect(store.learnedCount == 0)
        #expect(store.dueLetters.count == HangulData.all.count)
    }

    // MARK: Leitner

    @Test func correctAnswersClimbBoxesOneAtATime() {
        let store = makeStore()
        let letter = HangulData.all[0]
        for expected in 1...5 {
            store.record(letter, correct: true)
            #expect(store.entry(for: letter).box == expected)
            #expect(store.entry(for: letter).correct == expected)
        }
    }

    @Test func boxIsCappedAtFive() {
        let store = makeStore()
        let letter = HangulData.all[0]
        for _ in 0..<12 { store.record(letter, correct: true) }
        #expect(store.entry(for: letter).box == 5)
    }

    @Test func wrongAnswerResetsBoxButKeepsCounts() {
        let store = makeStore()
        let letter = HangulData.all[0]
        store.record(letter, correct: true)
        store.record(letter, correct: true)
        store.record(letter, correct: false)

        let entry = store.entry(for: letter)
        #expect(entry.box == 0)
        #expect(entry.correct == 2)
        #expect(entry.wrong == 1)
    }

    @Test func becomesLearnedAtBoxFour() {
        let store = makeStore()
        let letter = HangulData.all[0]

        store.record(letter, correct: true)
        store.record(letter, correct: true)
        store.record(letter, correct: true)
        #expect(!store.entry(for: letter).isLearned)
        store.record(letter, correct: true)
        #expect(store.entry(for: letter).isLearned)
        #expect(store.learnedCount == 1)
    }

    // MARK: Lịch ôn

    @Test func recordingSetsLastReviewedAndFutureNextReview() {
        let store = makeStore()
        let letter = HangulData.all[0]
        let before = Date()
        store.record(letter, correct: true)
        let entry = store.entry(for: letter)

        #expect(entry.lastReviewed != nil)
        #expect(entry.lastReviewed! >= before)
        #expect(entry.nextReview != nil)
        // Box 1 → ôn lại sau ~1 ngày.
        #expect(entry.nextReview! > Date().addingTimeInterval(60 * 60))
    }

    @Test func aJustReviewedLetterIsNoLongerDue() {
        let store = makeStore()
        let letter = HangulData.all[0]
        store.record(letter, correct: true)
        #expect(!store.dueLetters.contains { $0.character == letter.character })
        #expect(store.dueLetters.count == HangulData.all.count - 1)
    }

    @Test func aWrongAnswerKeepsTheLetterDue() {
        let store = makeStore()
        let letter = HangulData.all[0]
        store.record(letter, correct: false) // box 0 → nextReview = now + 0
        #expect(store.dueLetters.contains { $0.character == letter.character })
    }

    // MARK: Độc lập giữa các chữ

    @Test func lettersTrackedIndependently() {
        let store = makeStore()
        let a = HangulData.all[0]
        let b = HangulData.all[1]
        store.record(a, correct: true)
        #expect(store.entry(for: a).box == 1)
        #expect(store.entry(for: b).box == 0)
    }

    // MARK: Lưu & nạp lại

    @Test func progressPersistsAcrossInstances() {
        let defaults = UserDefaults(suiteName: "persist-\(UUID().uuidString)")!
        let letter = HangulData.all[0]

        let first = ProgressStore(defaults: defaults)
        first.record(letter, correct: true)
        first.record(letter, correct: true)

        let second = ProgressStore(defaults: defaults)
        #expect(second.entry(for: letter).box == 2)
        #expect(second.entry(for: letter).correct == 2)
    }

    @Test func resetClearsEverythingAndPersists() {
        let defaults = UserDefaults(suiteName: "reset-\(UUID().uuidString)")!
        let store = ProgressStore(defaults: defaults)
        for letter in HangulData.all.prefix(5) {
            for _ in 0..<4 { store.record(letter, correct: true) }
        }
        #expect(store.learnedCount == 5)

        store.reset()
        #expect(store.learnedCount == 0)
        #expect(store.dueLetters.count == HangulData.all.count)

        let reloaded = ProgressStore(defaults: defaults)
        #expect(reloaded.learnedCount == 0)
    }
}
