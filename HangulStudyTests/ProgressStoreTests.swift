import Foundation
import Testing
@testable import HangulStudy

@MainActor
struct ProgressStoreTests {
    private func makeStore() -> ProgressStore {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        return ProgressStore(defaults: defaults)
    }

    @Test func correctAnswerAdvancesLeitnerBox() {
        let store = makeStore()
        let letter = HangulData.all[0]

        store.record(letter, correct: true)
        #expect(store.entry(for: letter).box == 1)
        store.record(letter, correct: true)
        #expect(store.entry(for: letter).box == 2)
    }

    @Test func wrongAnswerResetsBox() {
        let store = makeStore()
        let letter = HangulData.all[0]

        store.record(letter, correct: true)
        store.record(letter, correct: true)
        store.record(letter, correct: false)
        #expect(store.entry(for: letter).box == 0)
        #expect(store.entry(for: letter).wrong == 1)
    }

    @Test func becomesLearnedAfterFourCorrect() {
        let store = makeStore()
        let letter = HangulData.all[0]

        for _ in 0..<4 { store.record(letter, correct: true) }
        #expect(store.entry(for: letter).isLearned)
        #expect(store.learnedCount == 1)
    }

    @Test func unseenLettersCountAsDue() {
        let store = makeStore()
        #expect(store.dueLetters.count == HangulData.all.count)

        store.record(HangulData.all[0], correct: true)
        #expect(store.dueLetters.count == HangulData.all.count - 1)
    }

    @Test func progressPersistsAcrossInstances() {
        let defaults = UserDefaults(suiteName: "test-\(UUID().uuidString)")!
        let letter = HangulData.all[0]

        let first = ProgressStore(defaults: defaults)
        first.record(letter, correct: true)

        let second = ProgressStore(defaults: defaults)
        #expect(second.entry(for: letter).box == 1)
    }
}
