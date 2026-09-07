import Testing
@testable import HangulStudy

struct HangulDataTests {

    // MARK: Số lượng & phân loại

    @Test func categoryCounts() {
        #expect(HangulData.basicConsonants.count == 14)
        #expect(HangulData.basicVowels.count == 10)
        #expect(HangulData.doubleConsonants.count == 5)
        #expect(HangulData.compoundVowels.count == 11)
        #expect(HangulData.all.count == 40)
    }

    @Test func allIsExactlyTheFourCategoriesConcatenated() {
        let combined = HangulData.basicConsonants
            + HangulData.basicVowels
            + HangulData.doubleConsonants
            + HangulData.compoundVowels
        #expect(HangulData.all.map(\.character) == combined.map(\.character))
    }

    @Test func lettersInCategoryMatchesTheStoredArrays() {
        #expect(HangulData.letters(in: .basicConsonant).map(\.character) == HangulData.basicConsonants.map(\.character))
        #expect(HangulData.letters(in: .basicVowel).map(\.character) == HangulData.basicVowels.map(\.character))
        #expect(HangulData.letters(in: .doubleConsonant).map(\.character) == HangulData.doubleConsonants.map(\.character))
        #expect(HangulData.letters(in: .compoundVowel).map(\.character) == HangulData.compoundVowels.map(\.character))
    }

    @Test func everyLetterReportsItsOwnCategory() {
        for category in HangulCategory.allCases {
            for letter in HangulData.letters(in: category) {
                #expect(letter.category == category)
            }
        }
    }

    // MARK: Tính duy nhất

    @Test func charactersAreUnique() {
        let characters = HangulData.all.map(\.character)
        #expect(Set(characters).count == characters.count)
    }

    @Test func romanizationsAreUnique() {
        let romanizations = HangulData.all.map(\.romanization)
        #expect(Set(romanizations).count == romanizations.count)
    }

    @Test func idEqualsCharacter() {
        for letter in HangulData.all {
            #expect(letter.id == letter.character)
        }
    }

    // MARK: Nội dung từng chữ

    @Test func everyLetterIsASingleHangulJamo() {
        for letter in HangulData.all {
            #expect(letter.character.unicodeScalars.count == 1)
            let value = letter.character.unicodeScalars.first!.value
            // Khối "Hangul Compatibility Jamo".
            #expect((0x3131...0x3163).contains(value), "\(letter.character) ngoài khối jamo")
        }
    }

    @Test func fieldsAreNonEmpty() {
        for letter in HangulData.all {
            #expect(!letter.romanization.isEmpty)
            #expect(!letter.name.isEmpty)
            #expect(!letter.exampleWord.isEmpty)
            #expect(!letter.exampleRomanization.isEmpty)
            #expect(!letter.exampleMeaning(.vi).isEmpty)
            #expect(!letter.exampleMeaning(.en).isEmpty)
        }
    }

    @Test func nameHasKoreanThenRomanInParentheses() {
        for letter in HangulData.all {
            // Dạng "기역 (giyeok)" — có đúng một dấu cách trước "(".
            #expect(letter.name.contains(" ("), "\(letter.name) sai định dạng")
            #expect(letter.name.hasSuffix(")"))
        }
    }

    @Test func exampleWordContainsOrRelatesToTheLetter() {
        // Từ ví dụ là chữ Hangul đã ghép (âm tiết), không phải jamo rời.
        for letter in HangulData.all {
            for scalar in letter.exampleWord.unicodeScalars {
                #expect((0xAC00...0xD7A3).contains(scalar.value) || (0x3131...0x3163).contains(scalar.value),
                        "\(letter.exampleWord) chứa ký tự lạ")
            }
        }
    }

    // MARK: spoken (dùng cho TTS)

    @Test func spokenIsTheKoreanPartOfTheName() {
        for letter in HangulData.all {
            let spoken = letter.spoken
            #expect(!spoken.isEmpty)
            #expect(!spoken.contains(" "))
            #expect(!spoken.contains("("))
            #expect(letter.name.hasPrefix(spoken))
            // Toàn ký tự Hangul.
            for scalar in spoken.unicodeScalars {
                #expect((0xAC00...0xD7A3).contains(scalar.value) || (0x3131...0x3163).contains(scalar.value))
            }
        }
    }

    @Test func vowelSpokenIsASyllableWithSilentInitial() {
        // ㅏ → "아", ㅗ → "오"…
        let vowel = HangulData.basicVowels.first { $0.character == "ㅏ" }!
        #expect(vowel.spoken == "아")
    }

    @Test func consonantSpokenIsItsName() {
        let giyeok = HangulData.basicConsonants.first { $0.character == "ㄱ" }!
        #expect(giyeok.spoken == "기역")
    }
}
