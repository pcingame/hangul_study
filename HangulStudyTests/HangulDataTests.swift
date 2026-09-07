import Testing
@testable import HangulStudy

struct HangulDataTests {
    @Test func categoryCounts() {
        #expect(HangulData.basicConsonants.count == 14)
        #expect(HangulData.basicVowels.count == 10)
        #expect(HangulData.doubleConsonants.count == 5)
        #expect(HangulData.compoundVowels.count == 11)
        #expect(HangulData.all.count == 40)
    }

    @Test func charactersAreUnique() {
        let characters = HangulData.all.map(\.character)
        #expect(Set(characters).count == characters.count)
    }

    @Test func romanizationsAreUnique() {
        let romanizations = HangulData.all.map(\.romanization)
        #expect(Set(romanizations).count == romanizations.count)
    }

    @Test func everyLetterHasSpokenAndExample() {
        for letter in HangulData.all {
            #expect(!letter.spoken.isEmpty)
            #expect(!letter.spoken.contains(" "))
            #expect(!letter.exampleWord.isEmpty)
        }
    }

    @Test func lettersInCategoryMatchCategory() {
        for category in HangulCategory.allCases {
            #expect(HangulData.letters(in: category).allSatisfy { $0.category == category })
        }
    }
}
